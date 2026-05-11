################################################################################
# VPC Network
################################################################################

resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id

  description = "VPC network for ${var.cluster_name} cluster"
}

################################################################################
# Subnet with Secondary IP Ranges (for pods and services)
################################################################################

resource "google_compute_subnetwork" "main" {
  name          = "${var.cluster_name}-subnet"
  ip_cidr_range = var.subnet_primary_cidr
  region        = var.region
  network       = google_compute_network.main.id
  project       = var.project_id

  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = var.subnet_secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  depends_on = [google_compute_network.main]
}

################################################################################
# Cloud NAT for Private Nodes
################################################################################

resource "google_compute_router" "main" {
  count   = var.enable_private_cluster ? 1 : 0
  name    = "${var.cluster_name}-router"
  region  = var.region
  project = var.project_id
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  count                              = var.enable_private_cluster ? 1 : 0
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.main[0].name
  region                             = google_compute_router.main[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

################################################################################
# Service Account for GKE Cluster
################################################################################

resource "google_service_account" "gke_cluster" {
  account_id   = "${var.cluster_name}-cluster"
  display_name = "GKE Cluster Service Account - ${var.cluster_name}"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_cluster_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_cluster.email}"
}

resource "google_project_iam_member" "gke_cluster_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_cluster.email}"
}

################################################################################
# Service Account for Workload Identity
################################################################################

resource "google_service_account" "workload_identity" {
  for_each     = toset(var.workload_identity_namespaces)
  account_id   = "${var.cluster_name}-wi-${each.value}"
  display_name = "Workload Identity - ${var.cluster_name} / ${each.value}"
  project      = var.project_id
}

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
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Master authorized networks (allow all by default, restrict in production)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = "0${var.maintenance_window_hour}:00"
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

################################################################################
# Node Pools
################################################################################

resource "google_container_node_pool" "pools" {
  for_each = var.node_pools

  name       = "${var.cluster_name}-${each.key}"
  location   = google_container_cluster.main.location
  cluster    = google_container_cluster.main.name
  project    = var.project_id
  node_count = try(each.value.node_count, null)

  # Scaling configuration
  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  # Node management
  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }

  # Node configuration
  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.disk_size_gb
    disk_type       = each.value.disk_type
    preemptible     = each.value.preemptible
    oauth_scopes    = each.value.oauth_scopes
    service_account = google_service_account.gke_cluster.email

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded instance options
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Labels for nodes
    labels = merge(
      each.value.labels,
      {
        "gke-nodepool" = each.key
        "cluster-name" = var.cluster_name
      }
    )

    # Network tags
    tags = concat(
      each.value.tags,
      var.tags,
      ["${var.cluster_name}-node"]
    )

    # Taints
    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_container_cluster.main,
    google_compute_router_nat.main
  ]
}

################################################################################
# Kubernetes Service Accounts and Workload Identity Binding
################################################################################

resource "kubernetes_service_account" "workload_identity" {
  for_each = google_service_account.workload_identity

  metadata {
    name      = "workload-identity-sa"
    namespace = each.key

    annotations = {
      "iam.gke.io/gcp-service-account" = each.value.email
    }
  }

  depends_on = [
    google_container_cluster.main
  ]
}

resource "google_service_account_iam_member" "workload_identity" {
  for_each = google_service_account.workload_identity

  service_account_id = each.value.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.key}/workload-identity-sa]"
}
