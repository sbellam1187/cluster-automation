resource "azurerm_subnet" "runway_ok8" {
  name                              = var.pci_cluster ? var.ets_subnet_name[var.location] : "${var.devexp_cluster_name}-${var.devexp_cluster_num}-subnet-${var.location}"
  resource_group_name               = var.cluster_resource_group_name
  virtual_network_name              = var.ets_vnet_name[var.location]
  address_prefixes                  = [var.ets_subnet[var.location]]
  private_endpoint_network_policies = "Enabled"
  service_endpoints                 = var.service_endpoints
}

resource "azurerm_subnet_network_security_group_association" "non_pci_nsg_association" {
  count                     = var.pci_cluster && var.app_sdlc_environment == "prod" ? 0 : 1
  subnet_id                 = azurerm_subnet.runway_ok8.id
  network_security_group_id = data.azurerm_network_security_group.non_pci_nsg[0].id
}

resource "azurerm_subnet_network_security_group_association" "prod_pci_nsg_association" {
  count                     = var.app_sdlc_environment == "prod" && var.pci_cluster ? 1 : 0
  subnet_id                 = azurerm_subnet.runway_ok8.id
  network_security_group_id = data.azurerm_network_security_group.pci_nsg[0].id
}

resource "azurerm_subnet_route_table_association" "runway_ok8" {
  subnet_id      = azurerm_subnet.runway_ok8.id
  route_table_id = azurerm_route_table.runway_ok8.id
}

resource "azurerm_route_table" "runway_ok8" {
  name                          = var.pci_cluster ? "kaas-runway-pci-aks-${var.devexp_cluster_num}-${var.location}-rt" : "${var.devexp_cluster_name}-${var.devexp_cluster_num}-rt-${var.location}"
  location                      = var.location
  resource_group_name           = var.pci_cluster && var.app_sdlc_environment == "prod" ? var.pci_resource_group : var.cluster_resource_group_name
  bgp_route_propagation_enabled = false

  tags = local.tags

  # Conditional route specific to PCI cluster
  dynamic "route" {
    for_each = var.pci_cluster ? [1] : []
    content {
      name                   = "kaas-runway-pci-aks-${var.devexp_cluster_num}-${var.location}-rt-route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
    }
  }
}
