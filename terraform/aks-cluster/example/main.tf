################################################################################
# Azure Kubernetes Service (AKS) Infrastructure
#
# This uses the azure-aks-infrastructure module which provides:
# - Complete AKS cluster with system and general node pools
# - Custom VNets, subnets, route tables, NSGs
# - Workload Identity and OIDC issuer support
# - Rancher integration for fleet management
# - Vault integration for secrets management
# - PCI and private cluster support
# - DNS management and pod identity
# - Maintenance windows for scheduled updates
################################################################################

module "aks" {
  source = "../../__modules/azure-aks-infrastructure"

  # Application Configuration
  app_archer_id        = var.app_archer_id
  app-shortname        = var.app-shortname
  app_owner            = var.app_owner
  app_product          = var.app_product
  app_sdlc_environment = var.app_sdlc_environment
  app_security         = var.app_security
  aa_criticality       = var.aa_criticality

  # Cluster Configuration
  devexp_cluster_name = var.devexp_cluster_name
  devexp_cluster_num  = var.devexp_cluster_num
  
  # Location and Resource Groups
  location                    = var.location
  asset_resource_group_name   = var.asset_resource_group_name
  cluster_resource_group_name = var.cluster_resource_group_name

  # Network Configuration
  ets_vnet_name    = var.ets_vnet_name
  ets_subnet_name  = var.ets_subnet_name
  ets_subnet       = var.ets_subnet
  ets_next_hop_ip  = var.ets_next_hop_ip
  ingresscontroller_ip = var.ingresscontroller_ip

  # Node Pool Configuration
  node_vm_size       = var.node_vm_size
  max_pod_count      = var.max_pod_count
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
  default_node_count = var.default_node_count
  system_node_labels = var.system_node_labels
  general_node_pools = var.general_node_pools
  availability_zones = var.availability_zones

  # Kubernetes Configuration
  kubernetes_version           = var.kubernetes_version
  nodepool_orchestrator_version = var.nodepool_orchestrator_version
  enable_auto_scaling          = var.enable_auto_scaling
  loadbalancer_sku             = var.loadbalancer_sku
  auto_patch_upgrade           = var.auto_patch_upgrade
  node_upgrade_channel         = var.node_upgrade_channel

  # Network and CIDR Configuration
  aks_pod_cidr        = var.aks_pod_cidr
  aks_service_cidr    = var.aks_service_cidr
  aks_dns_ip_address  = var.aks_dns_ip_address
  network_plugin      = var.network_plugin
  outbound_type       = var.outbound_type
  service_endpoints   = var.service_endpoints

  # Load Balancer Configuration
  num_pips                     = var.num_pips
  outbound_ports_allocated     = var.outbound_ports_allocated
  temporary_name_for_rotation  = var.temporary_name_for_rotation

  # Vault Configuration
  vault_host_url                  = var.vault_host_url
  vault_namespace                 = var.vault_namespace
  vault_ca_cert_file              = var.vault_ca_cert_file
  vault_login_approle_role_id     = var.vault_login_approle_role_id
  vault_login_approle_secret_id   = var.vault_login_approle_secret_id
  vault_kaas_login_approle_role_id = var.vault_kaas_login_approle_role_id
  vault_kaas_login_approle_secret_id = var.vault_kaas_login_approle_secret_id

  # Rancher Configuration
  devexp_rancher_environment  = var.devexp_rancher_environment
  rancher_token               = var.rancher_token
  enable_rancher_registration = var.enable_rancher_registration

  # Registry Configuration
  registry_server                  = var.registry_server
  registry_username                = var.registry_username
  registry_password                = var.registry_password
  container_registry_update_container_tag = var.container_registry_update_container_tag

  # Dynatrace Configuration
  dynatrace_url = var.dynatrace_url

  # PCI and Security Configuration
  pci_cluster               = var.pci_cluster
  pci_resource_group        = var.pci_resource_group
  private_aks               = var.private_aks
  legacy_pci_linux_profile  = var.legacy_pci_linux_profile
  azuread_rbac              = var.azuread_rbac

  # Advanced Configuration
  scale_down_utilization_threshold = var.scale_down_utilization_threshold
  sku_tier                        = var.sku_tier
  support_plan                    = var.support_plan
  os_disk_type                    = var.os_disk_type
  
  # Maintenance Windows
  maintenance_window_auto_upgrade = var.maintenance_window_auto_upgrade
  maintenance_window_node_os      = var.maintenance_window_node_os

  # Istio Configuration
  create_istio_sa = var.create_istio_sa

  # P42 and User Configuration
  p42_user = var.p42_user
}
