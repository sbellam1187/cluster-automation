################################################################################
# Consolidated AWS EKS Infrastructure
#
# This uses the aws-eks-infrastructure module which provides:
# - VPC creation and Internet Gateway
# - Public and private subnets across multiple AZs
# - IAM roles for cluster, nodes, and pod identity
# - EKS cluster with add-ons and logging
# - Managed node groups with auto-scaling
# - Pod identity associations for workload IAM
################################################################################

module "aws_eks" {
  source = "../../__modules/aws-eks-infrastructure"

  # Cluster Configuration
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  # VPC Configuration
  vpc_name             = "${var.cluster_name}-vpc"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # Node Groups
  node_groups = var.node_groups

  # Cluster Logging
  enable_cluster_logging = var.enable_cluster_logging
  cluster_log_types      = var.cluster_log_types

  # Advanced Features
  eni_configs              = var.eni_configs
  platform_admin_role_arns = var.platform_admin_role_arns
  pod_identity_associations = var.pod_identity_associations

  # Tags
  tags = var.tags
}
