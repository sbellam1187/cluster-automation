# VPC Network
resource "google_compute_network" "vpc" {
  name                    = local.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Subnet with secondary IP ranges for pods and services
resource "google_compute_subnetwork" "subnet" {
  name                    = local.subnet_name
  project                 = var.project_id
  region                  = var.region
  network                 = google_compute_network.vpc.id
  ip_cidr_range           = var.subnet_cidr
  private_ip_google_access = var.enable_private_google_access

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.secondary_ranges.pods
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.secondary_ranges.services
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

# Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "${local.network_name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT for private GKE nodes
resource "google_compute_router_nat" "nat" {
  name                               = "${local.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
