################################################################################
# VPC Module - Creates only VPC and Internet Gateway
################################################################################

module "vpc" {
  source = "../aws-vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  tags     = var.tags
}

################################################################################
# Subnets Module - Creates subnets and route tables
################################################################################

module "subnets" {
  source = "../aws-subnets"

  vpc_id          = module.vpc.vpc_id
  public_rt_name  = "${var.cluster_name}-public-rt"

  subnets = merge(
    {
      for idx, cidr in var.public_subnet_cidrs :
      "${var.cluster_name}-public-${idx + 1}" => {
        cidr_block        = cidr
        availability_zone = local.azs[idx % length(local.azs)]
        type              = "public"
      }
    },
    {
      for idx, cidr in var.private_subnet_cidrs :
      "${var.cluster_name}-private-${idx + 1}" => {
        cidr_block        = cidr
        availability_zone = local.azs[idx % length(local.azs)]
        type              = "private"
      }
    }
  )

  public_routes = {
    default = {
      destination_cidr_block = "0.0.0.0/0"
      gateway_id             = module.vpc.internet_gateway_id
    }
  }

  depends_on = [module.vpc]
}

################################################################################
# IAM Role for EKS Cluster
################################################################################

module "eks_cluster_role" {
  source = "../aws-iam-roles"

  role_name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]

  tags = var.tags
}

################################################################################
# IAM Roles for Node Groups
################################################################################

module "node_roles" {
  for_each = var.node_groups

  source = "../aws-iam-roles"

  role_name = "${var.cluster_name}-${each.key}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = var.tags
}

################################################################################
# Instance Profiles for Node Groups
################################################################################

resource "aws_iam_instance_profile" "node" {
  for_each = module.node_roles

  name_prefix = "${var.cluster_name}-${each.key}-"
  role        = each.value.role_name
}

################################################################################
# IAM Role for VPC CNI Pod Identity
################################################################################

module "vpc_cni_iam_role" {
  source = "../aws-iam-roles"

  role_name = "${var.cluster_name}-vpc-cni-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  policy_arns = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]

  tags = var.tags
}

################################################################################
# EKS Cluster
################################################################################

module "eks_cluster" {
  source = "../aws-eks-cluster"

  cluster_name             = var.cluster_name
  cluster_version          = var.cluster_version
  cluster_role_arn         = module.eks_cluster_role.role_arn
  subnet_ids               = concat(local.private_subnet_ids, local.public_subnet_ids)
  eni_configs              = var.eni_configs
  platform_admin_role_arns = var.platform_admin_role_arns
  
  # Pod Identity Associations for workload IAM
  pod_identity_associations = merge(
    {
      vpc_cni = {
        namespace       = "kube-system"
        service_account = "aws-node"
        role_arn        = module.vpc_cni_iam_role.role_arn
      }
    },
    var.pod_identity_associations
  )
  
  tags = var.tags

  depends_on = [
    module.eks_cluster_role,
    module.subnets
  ]
}

################################################################################
# EKS Managed Node Groups
################################################################################

resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = module.eks_cluster.cluster_id
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = module.node_roles[each.key].role_arn
  subnet_ids      = local.private_subnet_ids
  version         = var.cluster_version

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size
  capacity_type  = each.value.capacity_type

  labels = each.value.labels

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${each.key}-node-group"
    }
  )

  depends_on = [
    module.node_roles,
    module.eks_cluster
  ]

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Data Sources for Availability Zones
################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# Locals
################################################################################

locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)
  
  # Extract private subnet IDs from subnets module
  private_subnet_ids = [
    for name, id in module.subnets.subnet_id : id
    if contains([for idx, _ in var.private_subnet_cidrs : "${var.cluster_name}-private-${idx + 1}"], name)
  ]
  
  # Extract public subnet IDs from subnets module
  public_subnet_ids = [
    for name, id in module.subnets.subnet_id : id
    if contains([for idx, _ in var.public_subnet_cidrs : "${var.cluster_name}-public-${idx + 1}"], name)
  ]
}
