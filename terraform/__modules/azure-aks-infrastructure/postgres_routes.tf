
resource "azurerm_route" "azure_managed_dbs_central_us_23_99_160_139" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-23_99_160_139"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "23.99.160.139/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_central_us_52_182_136_37" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-52_182_136_37"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "52.182.136.37/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_central_us_52_182_136_38" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-52_182_136_38"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "52.182.136.38/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_central_us_13_67_215_62" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_67_215_62"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.67.215.62/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_east_us_40_71_8_203" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-40_71_8_203"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "40.71.8.203/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_east_us_40_71_83_113" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-40_71_83_113"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "40.71.83.113/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_east_us_40_121_158_30" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-40_121_158_30"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "40.121.158.30/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_east_us_191_238_6_43" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-191_238_6_43"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "191.238.6.43/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_east_us_2_40_70_144_38" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-40_70_144_38"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "40.70.144.38/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_east_us_2_52_167_105_38" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-52_167_105_38"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "52.167.105.38/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_east_us_2_52_177_185_181" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-52_177_185_181"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "52.177.185.181/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_north_central_us_52_162_104_35" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-52_162_104_35"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "52.162.104.35/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_north_central_us_52_162_104_36" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-52_162_104_36"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "52.162.104.36/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_north_central_us_23_96_178_199" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-23_96_178_199"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "23.96.178.199/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_south_central_us_104_214_16_39" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-104_214_16_39"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "104.214.16.39/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_south_central_us_20_45_120_0" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-20_45_120_0"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "20.45.120.0/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_south_central_us_13_66_62_124" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_66_62_124"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.66.62.124/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_south_central_us_23_98_162_75" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-23_98_162_75"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "23.98.162.75/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_central_us_13_78_145_25" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_78_145_25"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.78.145.25/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_central_us_52_161_100_158" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-52_161_100_158"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "52.161.100.158/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_13_86_216_212" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_86_216_212"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.86.216.212/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_13_86_217_212" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_86_217_212"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.86.217.212/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_104_42_238_205" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-104_42_238_205"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "104.42.238.205/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_23_99_34_75" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-23_99_34_75"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "23.99.34.75/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_2_13_66_226_202" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_66_226_202"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.66.226.202/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_2_13_66_136_192" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_66_136_192"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.66.136.192/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_2_13_66_136_195" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-13_66_136_195"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "13.66.136.195/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
resource "azurerm_route" "azure_managed_dbs_west_us_3_20_150_184_2" {
  count                  = (var.pci_cluster) ? 0 : 1
  name                   = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-onprem-${var.location}-20_150_184_2"
  resource_group_name    = var.cluster_resource_group_name
  route_table_name       = azurerm_route_table.runway_ok8.name
  address_prefix         = "20.150.184.2/32"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ets_next_hop_ip[var.location]
}
