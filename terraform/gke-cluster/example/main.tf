################################################################################
# Google Kubernetes Engine (GKE) Infrastructure
#
# This uses the google-gke-infrastructure module which provides:
# - VPC network with secondary ranges for pods and services
# - Private GKE cluster with Cloud NAT for node egress
# - Workload Identity for pod-to-GCP service account mapping
# - Multiple node pools with auto-scaling
# - Network policies and RBAC configuration
# - Cloud Logging and Cloud Monitoring integration
# - Shielded Nodes for enhanced security
################################################################################

module "gke" {
  source = "../../__modules/google-gke-infrastructure"

  # GCP Configuration
  project_id = var.project_id
  region     = var.region

  # Cluster Configuration
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  cluster_location   = var.cluster_location

  # Network Configuration
  network_name            = "${var.cluster_name}-network"
  network_cidr            = var.network_cidr
  subnet_primary_cidr     = var.subnet_primary_cidr
  enable_private_cluster  = var.enable_private_cluster
  enable_network_policy   = var.enable_network_policy

  # Node Pools
  node_pools = var.node_pools

  # Features and Add-ons
  enable_http_load_balancing = var.enable_http_load_balancing
  enable_network_policy_addon = var.enable_network_policy_addon
  enable_cloud_logging       = var.enable_cloud_logging
  enable_cloud_monitoring    = var.enable_cloud_monitoring
  enable_workload_identity   = var.enable_workload_identity
  enable_shielded_nodes      = var.enable_shielded_nodes
  enable_binary_authorization = var.enable_binary_authorization

  # Maintenance Windows
  maintenance_window_day  = var.maintenance_window_day
  maintenance_window_hour = var.maintenance_window_hour

  # RBAC
  cluster_admin_users = var.cluster_admin_users
  cluster_edit_users  = var.cluster_edit_users
  cluster_view_users  = var.cluster_view_users

  # Workload Identity
  workload_identity_namespaces = var.workload_identity_namespaces

  # Labels and Tags
  labels           = var.labels
  resource_labels  = var.resource_labels
  tags             = var.tags
}
