################################################################################
# GKE Cluster
################################################################################

resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.cluster_location == "regional" ? var.region : var.zones[0]
  project  = var.project_id

  # Cluster version
  min_master_version = var.kubernetes_version != "" ? var.kubernetes_version : null

  # Network configuration
  network            = google_compute_network.main.name
  subnetwork         = google_compute_subnetwork.main.name
  networking_mode    = "VPC_NATIVE"
  initial_node_count = 0 # We manage nodes via node pools

  # IP allocation policy for secondary ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = var.subnet_secondary_ranges["pods"].range_name
    services_secondary_range_name = var.subnet_secondary_ranges["services"].range_name
  }

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = var.enable_private_cluster
    enable_private_endpoint = false # Allow public endpoint for kubectl access
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  # Master authorized networks
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = local.effective_master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = format("%02d:00", var.maintenance_window_hour)
    }
  }

  # Logging and monitoring
  logging_service    = var.enable_cloud_logging ? "logging.googleapis.com/kubernetes" : "none"
  monitoring_service = var.enable_cloud_monitoring ? "monitoring.googleapis.com/kubernetes" : "none"

  # Addons
  addons_config {
    http_load_balancing {
      disabled = !var.enable_http_load_balancing
    }

    network_policy_config {
      disabled = !var.enable_network_policy_addon
    }
  }

  # Network policy
  network_policy {
    enabled  = var.enable_network_policy
    provider = "PROVIDER_UNSPECIFIED"
  }

  # Cluster labels
  resource_labels = var.resource_labels

  # Security settings
  enable_shielded_nodes = var.enable_shielded_nodes

  binary_authorization {
    evaluation_mode = var.enable_binary_authorization ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  # Cluster resource labels
  labels = var.labels

  # Service account for cluster
  service_account = google_service_account.gke_cluster.email

  # Allow sufficient time for cluster creation
  provisioning_config {
    boot_disk_kms_key = null
  }

  depends_on = [
    google_compute_subnetwork.main,
    google_service_account.gke_cluster
  ]

  lifecycle {
    ignore_changes = [
      min_master_version,
      node_pool,
    ]
  }
}
