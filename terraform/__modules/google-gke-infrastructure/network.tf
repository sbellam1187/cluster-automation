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
# Network Firewall Rules
################################################################################

resource "google_compute_firewall" "gke_internal" {
  count   = var.enable_firewall_rules ? 1 : 0
  name    = "${var.cluster_name}-allow-internal"
  network = google_compute_network.main.name
  project = var.project_id

  description = "Allow internal cluster communication for nodes, pods, and control plane"

  direction     = "INGRESS"
  source_ranges = local.internal_source_ranges
  target_tags   = [local.node_network_tag]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "gke_master_to_node" {
  count   = var.enable_firewall_rules ? 1 : 0
  name    = "${var.cluster_name}-allow-master"
  network = google_compute_network.main.name
  project = var.project_id

  description = "Allow GKE control plane access to node kubelet and webhook ports"

  direction     = "INGRESS"
  source_ranges = [var.master_ipv4_cidr]
  target_tags   = [local.node_network_tag]

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }
}

resource "google_compute_firewall" "gke_health_checks" {
  count   = var.enable_firewall_rules ? 1 : 0
  name    = "${var.cluster_name}-allow-hc"
  network = google_compute_network.main.name
  project = var.project_id

  description = "Allow Google Cloud Load Balancer health checks to NodePort services"

  direction     = "INGRESS"
  source_ranges = var.health_check_source_ranges
  target_tags   = [local.node_network_tag]

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
}
