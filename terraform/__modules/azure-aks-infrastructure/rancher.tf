module "rancher_fleet_registration" {
  source = "../__modules/rancher_register"
  count  = var.enable_rancher_registration ? 1 : 0
  additional_labels = {
    "azure.workload.identity/use" = "true"
  }

  cluster_name                            = azurerm_kubernetes_cluster.runway_ok8.name
  cloud_provider                          = "aks"
  dx_cluster_name                         = var.devexp_cluster_name
  app_sdlc_environment                    = var.app_sdlc_environment
  location                                = var.location
  container_registry_update_container_tag = var.container_registry_update_container_tag
  registry_password                       = var.registry_password
  registry_server                         = var.registry_server
  registry_username                       = var.registry_username
}
