module "rancher_fleet_registration" {
  source                                  = "../../__modules/rancher_register"
  count                                   = var.enable_rancher_registration ? 1 : 0
  depends_on                              = [module.eks_cluster]
  cluster_name                            = module.eks_cluster.cluster_name
  cloud_provider                          = "eks"
  dx_cluster_name                         = var.devexp_cluster_name
  allowed_aad_groups                      = local.allowed_aad_groups
  runway_status                           = var.runway_status
  app_sdlc_environment                    = "prod"
  location                                = var.region
  container_registry_update_container_tag = var.container_registry_update_container_tag
  registry_password                       = var.registry_password
  registry_username                       = var.registry_username
}
