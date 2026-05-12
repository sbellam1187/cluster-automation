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
      [local.node_network_tag]
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
    google_compute_router_nat.main,
    google_compute_firewall.gke_internal,
    google_compute_firewall.gke_master_to_node,
    google_compute_firewall.gke_health_checks,
  ]
}
