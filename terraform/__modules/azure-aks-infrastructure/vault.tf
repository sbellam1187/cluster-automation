module "vault" {
  source               = "../__modules/vault"
  app_sdlc_environment = var.app_sdlc_environment
  cluster_name         = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
  kubernetes_host      = local.host
  kubernetes_ca_cert   = local.cluster_ca_certificate
}
