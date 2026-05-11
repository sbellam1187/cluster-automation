resource "azurerm_kubernetes_cluster_node_pool" "general_node_pools" {
  for_each = var.general_node_pools

  name                        = each.key
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.runway_ok8.id
  vnet_subnet_id              = azurerm_subnet.runway_ok8.id
  zones                       = lookup(var.availability_zones, var.location, [])
  vm_size                     = each.value.vm_size
  orchestrator_version        = each.value.orchestrator_version == "" ? var.kubernetes_version : each.value.orchestrator_version
  auto_scaling_enabled        = each.value.enable_auto_scaling
  node_count                  = each.value.node_count
  max_count                   = each.value.max_count
  min_count                   = each.value.min_count
  max_pods                    = each.value.max_pods
  node_labels                 = each.value.node_labels
  node_taints                 = each.value.node_taints
  os_disk_size_gb             = each.value.os_disk_size_gb
  temporary_name_for_rotation = each.value.temporary_name_for_rotation
  os_disk_type                = each.value.os_disk_type
  priority                    = each.value.priority
  eviction_policy             = each.value.priority == "Spot" ? (each.value.eviction_policy != "" ? each.value.eviction_policy : "Delete") : null
  spot_max_price              = each.value.priority == "Spot" ? (each.value.spot_max_price != null ? each.value.spot_max_price : -1) : null
  # Cluster autoscaler will change the node amount in these node pools,
  # so the real value should be ignored to avoid permanent plan diffs.
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
  # Apply this sysctl configuration only for the gen01 node pool when
  # vm_max_map_count is explicitly set for that node pool.
  dynamic "linux_os_config" {
    for_each = (each.value.vm_max_map_count != null && each.key == "gen01") ? [1] : []
    content {
      sysctl_config {
        vm_max_map_count = each.value.vm_max_map_count
      }
    }
  }

  dynamic "upgrade_settings" {
    for_each = each.value.priority == "Spot" ? [] : [1]
    content {
      max_surge = each.value.max_surge_count
    }
  }

  tags = merge(local.tags, each.value.tags)
}
