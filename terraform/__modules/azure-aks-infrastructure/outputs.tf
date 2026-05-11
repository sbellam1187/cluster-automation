output "aa_network_rg_name" {
  description = "aa_network_rg_name"
  value       = var.cluster_resource_group_name
}

output "app_sdlc_environment" {
  description = "app_sdlc_environment"
  value       = var.app_sdlc_environment
}

output "app_security" {
  description = "app_security"
  value       = var.app_security
}

output "auto_scaling_enabled" {
  description = "auto_scaling_enabled"
  value       = var.enable_auto_scaling
}

output "cluster_fqdn" {
  description = "cluster_fqdn"
  value       = azurerm_kubernetes_cluster.runway_ok8.fqdn
}

output "oidc_issuer_url" {
  description = "oidc_issuer_url"
  value       = azurerm_kubernetes_cluster.runway_ok8.oidc_issuer_url
}

output "federated_cred_id" {
  description = "ID for Federated Credential"
  value       = azurerm_federated_identity_credential.workload_identity.id
}

output "cluster_subnet" {
  description = "cluster_subnet"
  value       = azurerm_subnet.runway_ok8.name
}

output "dx_cluster_name" {
  description = "dx_cluster_name"
  value       = var.devexp_cluster_name
}

output "dx_cluster_num" {
  description = "dx_cluster_num"
  value       = var.devexp_cluster_num
}

output "dx_k8s_cluster_name" {
  description = "dx_k8s_cluster_name"
  value       = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
}

output "dx_k8s_rancher_environment" {
  description = "dx_k8s_rancher_environment"
  value       = var.devexp_rancher_environment
}

output "dx_next_hop_ip" {
  description = "dx_next_hop_ip"
  value       = var.ets_next_hop_ip[var.location]
}

output "dx_resource_group_name" {
  description = "dx_resource_group_name"
  value       = var.asset_resource_group_name
}

output "dx_subnet_name" {
  description = "dx_subnet_name"
  value       = var.ets_subnet_name[var.location]
}

output "ingresscontroller_ip" {
  description = "ingresscontroller_ip"
  value       = lookup(var.ingresscontroller_ip, var.location, "")
}

output "dx_subnet" {
  description = "dx_subnet"
  value       = var.ets_subnet[var.location]
}

output "dx_vnet_name" {
  description = "dx_vnet_name"
  value       = var.ets_vnet_name[var.location]
}

output "dynatrace_endpoint" {
  description = "this is the dynatrace url based on the environment"
  value       = var.dynatrace_url[var.app_sdlc_environment]
}

output "configured_general_node_pools" {
  description = "configured_general_node_pools"
  value = {
    for k, np in azurerm_kubernetes_cluster_node_pool.general_node_pools :
    k => ({
      vm_size            = np.vm_size
      kubernetes_version = np.orchestrator_version
      priority           = np.priority
      autoscale_enabled  = np.auto_scaling_enabled
  }) }
}

output "http_application_routing_zone_name" {
  description = "http_application_routing_zone_name"
  value       = azurerm_kubernetes_cluster.runway_ok8.http_application_routing_zone_name
}

output "kaas_app_archer_id" {
  description = "kaas_app_archer_id"
  value       = var.app_archer_id
}

output "kaas_app_owner" {
  description = "kaas_app_owner"
  value       = var.app_owner
}

output "kaas_app_product" {
  description = "kaas_app_product"
  value       = var.app_product
}

output "kaas_app_shortname" {
  description = "kaas_app_shortname"
  value       = var.app-shortname
}

output "kubernetes_version_nodepool_system" {
  description = "kubernetes_version_nodepool_system"
  value       = try(var.nodepool_orchestrator_version["system"], "")
}

output "kubernetes_version" {
  description = "kubernetes_version"
  value       = var.kubernetes_version
}

output "location" {
  description = "location"
  value       = var.location
}

output "node_vm_size" {
  description = "node_vm_size"
  value       = var.node_vm_size
}

output "pci_cluster" {
  description = "pci_cluster"
  value       = var.pci_cluster
}

output "rancher_cluster_id" {
  description = "rancher_cluster_id"
  value       = try(module.rancher_fleet_registration[0].rancher_cluster_id, "")
}

output "rancher_upstream_url" {
  description = "rancher_upstream_url"
  value       = var.rancher_url[var.app_sdlc_environment]
}

output "rancher_upstream_ip" {
  description = "rancher_upstream_ip"
  value       = var.rancher_ip[var.app_sdlc_environment]
}

output "rancher_upstream_cluster_name" {
  description = "rancher_upstream_cluster_name"
  value       = var.rancher_cluster_name[var.app_sdlc_environment]
}

output "rancher_upstream_resource_group_name" {
  description = "rancher_upstream_resource_group_name"
  value       = var.rancher_resource_group_name[var.app_sdlc_environment]
}

output "tf_rancher_register_cluster" {
  description = "tf_rancher_register_cluster"
  value       = var.enable_rancher_registration
}

# Below are DNS outputs
output "private_fqdn" {
  description = "Private FQDN for the cluster"
  value       = var.pci_cluster == true ? data.azurerm_kubernetes_cluster.runway_ok8[0].private_fqdn : ""
}

output "private_endpoint_private_ip" {
  description = "Private IP for the private endpoint"
  value       = var.pci_cluster == true ? data.azurerm_private_endpoint_connection.pci_cluster_pe[0].private_service_connection[0].private_ip_address : ""
}

output "cloud_provider" {
  value       = "aks"
  description = "cloud provider type"
}
