################################################################################
# Cluster Information
################################################################################

output "cluster_id" {
  description = "GKE cluster ID"
  value       = module.gke.cluster_id
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = module.gke.kubernetes_version
}

output "cluster_location" {
  description = "Cluster location"
  value       = module.gke.cluster_location
}

################################################################################
# Network Information
################################################################################

output "network_name" {
  description = "VPC network name"
  value       = module.gke.network_name
}

output "subnet_name" {
  description = "Subnet name"
  value       = module.gke.subnet_name
}

output "subnet_cidr" {
  description = "Subnet primary CIDR"
  value       = module.gke.subnet_primary_cidr
}

output "secondary_ranges" {
  description = "Secondary IP ranges"
  value       = module.gke.secondary_ranges
}

################################################################################
# Service Accounts
################################################################################

output "cluster_service_account" {
  description = "GKE cluster service account"
  value       = module.gke.cluster_service_account_email
}

output "workload_identity_accounts" {
  description = "Workload Identity service accounts"
  value       = module.gke.workload_identity_service_accounts
}

output "workload_pool" {
  description = "Workload Identity pool"
  value       = module.gke.workload_pool
}

################################################################################
# Node Pools
################################################################################

output "node_pool_ids" {
  description = "Node pool IDs"
  value       = module.gke.node_pool_ids
}

output "node_pool_names" {
  description = "Node pool names"
  value       = module.gke.node_pool_names
}

output "node_pool_config" {
  description = "Node pool configurations"
  value       = module.gke.node_pool_config
}

################################################################################
# Access and Configuration
################################################################################

output "gke_auth_command" {
  description = "Command to authenticate with cluster"
  value       = module.gke.gke_auth_command
}

output "kubeconfig_context" {
  description = "kubectl context name"
  value       = module.gke.kubeconfig_context
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
}

################################################################################
# Summary
################################################################################

output "cluster_summary" {
  description = "Complete cluster configuration summary"
  value       = module.gke.cluster_summary
}
