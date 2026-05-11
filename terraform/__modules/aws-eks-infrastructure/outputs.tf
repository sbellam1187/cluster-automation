################################################################################
# Cluster Outputs
################################################################################

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = module.eks_cluster.cluster_version
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded cluster CA certificate"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

################################################################################
# VPC Outputs
################################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = local.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = local.public_subnet_ids
}

output "subnet_ids" {
  description = "Map of all subnet names to IDs"
  value       = module.subnets.subnet_id
}

################################################################################
# IAM Outputs
################################################################################

output "cluster_role_arn" {
  description = "EKS cluster role ARN"
  value       = module.eks_cluster_role.role_arn
}

output "node_role_arns" {
  description = "Node group role ARNs"
  value = {
    for name, role in module.node_roles :
    name => role.role_arn
  }
}

output "vpc_cni_role_arn" {
  description = "VPC CNI IAM role ARN"
  value       = module.vpc_cni_iam_role.role_arn
}

################################################################################
# Node Group Outputs
################################################################################

output "node_group_ids" {
  description = "Node group IDs"
  value = {
    for name, group in aws_eks_node_group.main :
    name => group.id
  }
}

output "node_group_statuses" {
  description = "Node group statuses"
  value = {
    for name, group in aws_eks_node_group.main :
    name => group.status
  }
}

################################################################################
# Cluster Access Outputs
################################################################################

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.eks_cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL"
  value       = module.eks_cluster.oidc_provider_url
}

################################################################################
# Summary Output
################################################################################

output "cluster_summary" {
  description = "Cluster configuration summary"
  value = {
    cluster_name           = module.eks_cluster.cluster_id
    cluster_version        = module.eks_cluster.cluster_version
    vpc_cidr               = module.vpc.vpc_cidr
    vpc_id                 = module.vpc.vpc_id
    private_subnet_count   = length(local.private_subnet_ids)
    public_subnet_count    = length(local.public_subnet_ids)
    node_group_count       = length(aws_eks_node_group.main)
    node_group_names       = keys(aws_eks_node_group.main)
    enabled_log_types      = var.cluster_log_types
  }
}
