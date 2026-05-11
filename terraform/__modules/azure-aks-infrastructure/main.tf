resource "azurerm_public_ip" "external_ip" {
  count               = var.pci_cluster ? 0 : var.num_pips
  name                = format("dxclusters-externalips-%s-%s-%s-%d-%d", var.app_sdlc_environment, var.location, var.devexp_cluster_name, var.devexp_cluster_num, count.index + 1)
  resource_group_name = var.cluster_resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  public_ip_prefix_id = var.pci_cluster ? null : data.azurerm_public_ip_prefix.dx_external_ip_prefix[0].id
  tags                = local.tags
}
resource "null_resource" "previous" {}
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "60s"
}
resource "azurerm_kubernetes_cluster" "runway_ok8" {
  name                                = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
  location                            = var.location
  resource_group_name                 = var.asset_resource_group_name
  kubernetes_version                  = var.kubernetes_version
  dns_prefix                          = var.pci_cluster == true ? "kaaspci" : "notused"
  sku_tier                            = var.sku_tier
  support_plan                        = var.support_plan
  private_cluster_enabled             = (var.pci_cluster || var.private_aks) ? true : false
  private_dns_zone_id                 = (var.pci_cluster || var.private_aks) ? "None" : null
  private_cluster_public_fqdn_enabled = (var.pci_cluster || var.private_aks)
  automatic_upgrade_channel           = var.auto_patch_upgrade == true ? "patch" : null
  node_os_upgrade_channel             = var.node_upgrade_channel
  oidc_issuer_enabled                 = true
  workload_identity_enabled           = true

  auto_scaler_profile {
    scale_down_utilization_threshold = var.scale_down_utilization_threshold
    skip_nodes_with_local_storage    = false
  }
  dynamic "network_profile" {
    for_each = var.pci_cluster ? [1] : []
    content {
      network_plugin      = var.network_plugin
      network_plugin_mode = var.network_plugin == "azure" ? "overlay" : null
      pod_cidr            = var.aks_pod_cidr
      service_cidr        = var.aks_service_cidr
      dns_service_ip      = var.aks_dns_ip_address
      outbound_type       = var.outbound_type
    }
  }
  dynamic "network_profile" {
    for_each = var.pci_cluster ? [] : [1]
    content {
      load_balancer_sku   = var.loadbalancer_sku
      network_plugin      = var.network_plugin
      network_plugin_mode = var.network_plugin == "azure" ? "overlay" : null
      pod_cidr            = var.aks_pod_cidr
      service_cidr        = var.aks_service_cidr
      dns_service_ip      = var.aks_dns_ip_address
      load_balancer_profile {
        outbound_ip_address_ids  = azurerm_public_ip.external_ip[*].id
        outbound_ports_allocated = var.outbound_ports_allocated
        idle_timeout_in_minutes  = "4"
      }
    }
  }

  dynamic "linux_profile" {
    for_each = var.pci_cluster && var.legacy_pci_linux_profile != null ? [1] : []
    content {
      admin_username = var.legacy_pci_linux_profile.admin_username
      ssh_key {
        key_data = var.legacy_pci_linux_profile.ssh_key.key_data
      }
    }
  }


  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.pci_cluster && var.azuread_rbac != null ? [1] : []
    content {
      azure_rbac_enabled     = var.azuread_rbac.enabled
      admin_group_object_ids = var.azuread_rbac.admin_group_object_ids
    }
  }

  role_based_access_control_enabled = true
  identity {
    type         = "UserAssigned"
    identity_ids = [local.managed_identity_id]
  }

  tags = local.tags

  default_node_pool {
    name                         = "system"
    auto_scaling_enabled         = var.enable_auto_scaling
    node_count                   = var.default_node_count
    min_count                    = var.min_node_count
    max_count                    = var.max_node_count
    vm_size                      = var.node_vm_size
    vnet_subnet_id               = azurerm_subnet.runway_ok8.id
    max_pods                     = var.max_pod_count
    only_critical_addons_enabled = true
    os_disk_type                 = var.os_disk_type
    upgrade_settings {
      max_surge = "10%"
    }
    zones                       = lookup(var.availability_zones, var.location, [])
    orchestrator_version        = lookup(var.nodepool_orchestrator_version, "system", var.kubernetes_version)
    temporary_name_for_rotation = var.temporary_name_for_rotation
    # additional node labels for castai to pick system nodes since default agentpool cannot be used
    node_labels = var.system_node_labels
  }
  http_application_routing_enabled = false
  depends_on = [
    azurerm_subnet.runway_ok8,
    azurerm_subnet_route_table_association.runway_ok8,
    azurerm_route_table.runway_ok8,
    time_sleep.wait_60_seconds
  ]

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.auto_patch_upgrade == true && var.maintenance_window_auto_upgrade != null ? [var.maintenance_window_auto_upgrade] : []

    content {
      duration     = maintenance_window_auto_upgrade.value.duration
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      start_date   = maintenance_window_auto_upgrade.value.start_date
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      week_index   = maintenance_window_auto_upgrade.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed == null ? [] : maintenance_window_auto_upgrade.value.not_allowed

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = (var.node_upgrade_channel == "None" || var.maintenance_window_node_os == null) ? [] : [var.maintenance_window_node_os]

    content {
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      day_of_month = maintenance_window_node_os.value.day_of_month
      day_of_week  = maintenance_window_node_os.value.day_of_week
      start_date   = maintenance_window_node_os.value.start_date
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      week_index   = maintenance_window_node_os.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed == null ? [] : maintenance_window_node_os.value.not_allowed

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
}

resource "azurerm_route" "runway_ok8_onprem" {
  count                  = var.pci_cluster ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "10.0.0.0/8"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}

resource "azurerm_route" "runway_ok8_internet" {
  count               = (var.pci_cluster || var.network_plugin == "azure") ? 0 : 1
  name                = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-internet-${var.location}"
  resource_group_name = var.cluster_resource_group_name
  route_table_name    = azurerm_route_table.runway_ok8.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_route" "runway_ok8_onpremwifi" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onpremwifi-${var.location}"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "172.20.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}

resource "azurerm_route" "runway_ok8_esoa-np" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-esoa-np-${var.location}"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "172.18.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}

resource "azurerm_route" "runway_ok8_mosaic-np" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-mosaic-np-${var.location}"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "141.206.1.0/24"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
# Non-Prod Route for FAA
resource "azurerm_route" "runway_ok8_faaswimdld_np" {
  count                  = var.app_sdlc_environment == "nonprod" && var.pci_cluster == false ? 1 : 0
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-faaswimdld-np-${var.location}"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "155.178.172.214/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}

# Prod Routes (2 IPs) for FAA
resource "azurerm_route" "runway_ok8_faaswimdld_prod" {
  count                  = var.app_sdlc_environment == "prod" && var.pci_cluster == false ? 2 : 0
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-faaswimdld-prod-${count.index + 1}-${var.location}"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = element(["155.178.64.54/32", "152.123.240.184/32"], count.index)
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}

resource "azurerm_route" "runway_ok8_mosaic-p" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-mosaic-p-${var.location}"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "141.206.4.0/22"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}

# Begin - Important/Useful labels for pre-existing Kubernetes namespaces

resource "kubernetes_labels" "kube_node_lease" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-node-lease"
  }
  labels = {
    "runway.aa.com/k8s-bootstrap-component" = "true"
  }
  depends_on = [azurerm_kubernetes_cluster.runway_ok8]
}

resource "kubernetes_labels" "kube_public" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-public"
  }
  labels = {
    "runway.aa.com/k8s-bootstrap-component" = "true"
  }
  depends_on = [azurerm_kubernetes_cluster.runway_ok8]
}

resource "kubernetes_labels" "kube_system" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-system"
  }
  labels = {
    "runway.aa.com/k8s-bootstrap-component" = "true"
  }
  depends_on = [azurerm_kubernetes_cluster.runway_ok8]
}

# End - Important/Useful labels for pre-existing Kubernetes namespaces
