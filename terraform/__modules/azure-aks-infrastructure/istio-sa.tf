##This is the module to create istio-system namespace and service account
## The kubernetes host and ca_certs are for the host on which we create the service account
module "istio_sa" {
  count = var.create_istio_sa ? 1 : 0
  providers = {
    vault = vault.KaaS
  }
  source               = "../__modules/k8s_serviceaccount"
  namespace            = "istio-system"
  service_account_name = "istio-reader-service-account"
  app_sdlc_environment = var.app_sdlc_environment
  secret_path          = "istio/${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
  kubernetes_host      = local.host
  kubernetes_ca_cert   = base64encode(local.cluster_ca_certificate)
  additional_labels = {
    "topology.istio.io/network" = "network-${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
  }
}
