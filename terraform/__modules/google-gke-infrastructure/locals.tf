locals {
  node_network_tag = "${var.cluster_name}-node"
  effective_master_authorized_networks = length(var.master_authorized_networks) > 0 ? var.master_authorized_networks : [{
    cidr_block   = var.subnet_primary_cidr
    display_name = "cluster-subnet"
  }]

  internal_source_ranges = distinct(concat(
    [var.subnet_primary_cidr, var.master_ipv4_cidr],
    [for secondary_range in values(var.subnet_secondary_ranges) : secondary_range.ip_cidr_range]
  ))
}
