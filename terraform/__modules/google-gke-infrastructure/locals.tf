locals {
  node_network_tag = "${var.cluster_name}-node"
  workload_identity_enabled = var.enable_workload_identity && var.workload_identity_enabled
  workload_identity_namespaces = local.workload_identity_enabled ? toset(var.workload_identity_namespaces) : toset([])

  internal_source_ranges = distinct(concat(
    [var.subnet_primary_cidr, var.master_ipv4_cidr],
    [for secondary_range in values(var.subnet_secondary_ranges) : secondary_range.ip_cidr_range]
  ))
}
