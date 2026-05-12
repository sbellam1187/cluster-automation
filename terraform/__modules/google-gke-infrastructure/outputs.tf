################################################################################
# GKE Cluster Outputs
################################################################################

output "cluster_id" {
  description = "GKE cluster ID"
  value       = google_container_cluster.main.id
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.main.name
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = google_container_cluster.main.location
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.main.endpoint
  sensitive   = true
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = google_container_cluster.main.master_version
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (base64 encoded)"
  value       = google_container_cluster.main.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

################################################################################
# Network Outputs
################################################################################

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.main.name
}

output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.main.id
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.main.name
}

output "subnet_id" {
  description = "Subnet ID"
  value       = google_compute_subnetwork.main.id
}

output "subnet_primary_cidr" {
  description = "Subnet primary CIDR block"
  value       = google_compute_subnetwork.main.ip_cidr_range
}

output "secondary_ranges" {
  description = "Secondary IP ranges"
  value = {
    for range in google_compute_subnetwork.main.secondary_ip_range :
    range.range_name => range.ip_cidr_range
  }
}

################################################################################
# Service Account Outputs
################################################################################

output "cluster_service_account_email" {
  description = "GKE cluster service account email"
  value       = google_service_account.gke_cluster.email
}

output "cluster_service_account_id" {
  description = "GKE cluster service account ID"
  value       = google_service_account.gke_cluster.unique_id
}

output "workload_identity_service_accounts" {
  description = "Workload Identity service accounts"
  value = {
    for name, sa in google_service_account.workload_identity :
    name => sa.email
  }
}

################################################################################
# Node Pool Outputs
################################################################################

output "node_pool_ids" {
  description = "Node pool IDs"
  value = {
    for name, pool in google_container_node_pool.pools :
    name => pool.id
  }
}

output "node_pool_names" {
  description = "Node pool names"
  value = {
    for name, pool in google_container_node_pool.pools :
    name => pool.name
  }
}

output "node_pool_config" {
  description = "Node pool configuration details"
  value = {
    for name, pool in google_container_node_pool.pools :
    name => {
      machine_type = pool.node_config[0].machine_type
      disk_size_gb = pool.node_config[0].disk_size_gb
      auto_scaling = {
        min_node_count = pool.autoscaling[0].min_node_count
        max_node_count = pool.autoscaling[0].max_node_count
      }
    }
  }
}

################################################################################
# Workload Identity Outputs
################################################################################

output "workload_pool" {
  description = "Workload Identity Pool (project.svc.id.goog)"
  value       = "${var.project_id}.svc.id.goog"
}

output "workload_identity_enabled" {
  description = "Workload Identity enabled status"
  value       = true
}

################################################################################
# Firewall Outputs
################################################################################

output "firewall_rule_names" {
  description = "Firewall rule names created for GKE networking"
  value = {
    internal       = try(google_compute_firewall.gke_internal[0].name, null)
    master_to_node = try(google_compute_firewall.gke_master_to_node[0].name, null)
    health_checks  = try(google_compute_firewall.gke_health_checks[0].name, null)
  }
}

################################################################################
# Access and Authentication Outputs
################################################################################

output "gke_auth_command" {
  description = "Command to authenticate with GKE cluster"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --region ${google_container_cluster.main.location} --project ${var.project_id}"
}

output "kubeconfig_context" {
  description = "Kubectl context name"
  value       = "gke_${var.project_id}_${google_container_cluster.main.location}_${google_container_cluster.main.name}"
}

################################################################################
# Summary Output
################################################################################

output "cluster_summary" {
  description = "Comprehensive cluster configuration summary"
  value = {
    cluster_name                 = google_container_cluster.main.name
    cluster_location             = google_container_cluster.main.location
    kubernetes_version           = google_container_cluster.main.master_version
    project_id                   = var.project_id
    network_name                 = google_compute_network.main.name
    subnet_cidr                  = google_compute_subnetwork.main.ip_cidr_range
    private_cluster              = var.enable_private_cluster
    workload_identity_enabled    = true
    network_policy_enabled       = var.enable_network_policy
    http_load_balancing_enabled  = var.enable_http_load_balancing
    cloud_logging_enabled        = var.enable_cloud_logging
    cloud_monitoring_enabled     = var.enable_cloud_monitoring
    shielded_nodes_enabled       = var.enable_shielded_nodes
    node_pool_count              = length(google_container_node_pool.pools)
    node_pool_names              = keys(google_container_node_pool.pools)
    cluster_service_account      = google_service_account.gke_cluster.email
    workload_pool                = "${var.project_id}.svc.id.goog"
  }
}
