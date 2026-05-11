# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region

  # Network configuration
  network           = var.network_name
  subnetwork        = var.subnet_name
  networking_mode   = "VPC_NATIVE"
  
  # Cluster IP ranges
  cluster_secondary_range_name  = "pods"
  services_secondary_range_name = "services"

  # Release channel
  release_channel {
    channel = "REGULAR"
  }

  # Node pool configuration
  initial_node_count = 0  # We'll manage node pool separately
  remove_default_node_pool = true

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Kubernetes version
  min_master_version = var.kubernetes_version

  # Security features
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = !var.enable_network_policy
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  # Network policy
  network_policy {
    enabled  = var.enable_network_policy
    provider = "CALICO"
  }

  # Pod security policy
  pod_security_policy_config {
    enabled = var.enable_pod_security_policy
  }

  # Binary Authorization
  binary_authorization {
    evaluation_mode = var.enable_binary_authorization ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  # Shielded nodes
  shielded_nodes {
    enable_secure_boot          = var.enable_shielded_nodes
    enable_integrity_monitoring = var.enable_shielded_nodes
  }

  # Private cluster configuration
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = false
      master_ipv4_cidr_block  = "172.16.0.0/28"
    }
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = length(var.authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr
          display_name = cidr_blocks.value.name
        }
      }
    }
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_window_start_time
      duration   = "${var.maintenance_window_duration}h"
    }
  }

  # Logging and monitoring
  logging_service    = var.enable_logging ? "logging.googleapis.com/kubernetes" : "none"
  monitoring_service = var.enable_monitoring ? "monitoring.googleapis.com/kubernetes" : "none"

  # Labels
  resource_labels = var.labels
}

# Default node pool
resource "google_container_node_pool" "primary" {
  name       = "${var.cluster_name}-pool"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.initial_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    preemptible  = var.enable_preemptible_nodes
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    service_account = var.node_service_account_email
    oauth_scopes    = var.service_account_scopes

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = var.enable_shielded_nodes
      enable_integrity_monitoring = var.enable_shielded_nodes
    }

    labels = var.labels
  }
}
