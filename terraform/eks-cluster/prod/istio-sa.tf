##This is the module to create istio-system namespace and service account
## The kubernetes host and ca_certs are for the host on which we create the service account
module "istio_sa" {
  providers = {
    vault = vault.KaaS
  }
  source               = "../../__modules/k8s_serviceaccount"
  namespace            = "istio-system"
  service_account_name = "istio-reader-service-account"
  app_sdlc_environment = "prod"
  secret_path          = "istio/${var.cluster_name}"
  kubernetes_host      = module.eks_cluster.cluster_endpoint
  kubernetes_ca_cert   = module.eks_cluster.cluster_certificate_authority
  additional_labels = {
    "topology.istio.io/network" = "network-${var.cluster_name}"
  }
}
