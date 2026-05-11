################################################################################
# Cluster Outputs
################################################################################

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.aws_eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.aws_eks.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = module.aws_eks.cluster_version
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.aws_eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded cluster CA certificate"
  value       = module.aws_eks.cluster_certificate_authority_data
  sensitive   = true
}

################################################################################
# VPC Outputs
################################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.aws_eks.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.aws_eks.vpc_cidr
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.aws_eks.internet_gateway_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.aws_eks.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.aws_eks.public_subnet_ids
}

output "subnet_ids" {
  description = "Map of all subnet names to IDs"
  value       = module.aws_eks.subnet_ids
}

################################################################################
# IAM Outputs
################################################################################

output "cluster_role_arn" {
  description = "EKS cluster role ARN"
  value       = module.aws_eks.cluster_role_arn
}

output "node_role_arns" {
  description = "Node group role ARNs"
  value       = module.aws_eks.node_role_arns
}

output "vpc_cni_role_arn" {
  description = "VPC CNI IAM role ARN"
  value       = module.aws_eks.vpc_cni_role_arn
}

################################################################################
# Node Group Outputs
################################################################################

output "node_group_ids" {
  description = "Node group IDs"
  value       = module.aws_eks.node_group_ids
}

output "node_group_statuses" {
  description = "Node group statuses"
  value       = module.aws_eks.node_group_statuses
}

################################################################################
# OIDC Provider Outputs
################################################################################

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.aws_eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL"
  value       = module.aws_eks.oidc_provider_url
}

################################################################################
# kubectl Configuration
################################################################################

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.aws_eks.cluster_id}"
}

output "kubeconfig_summary" {
  description = "Kubeconfig summary"
  value = {
    cluster_name = module.aws_eks.cluster_id
    endpoint     = module.aws_eks.cluster_endpoint
    region       = var.aws_region
  }
}

################################################################################
# Summary Output
################################################################################

output "cluster_summary" {
  description = "Cluster summary"
  value       = module.aws_eks.cluster_summary
}

