module "vault" {
  source               = "../../__modules/vault"
  depends_on           = [module.eks_cluster]
  app_sdlc_environment = var.app_sdlc_environment
  cluster_name         = module.eks_cluster.cluster_name
  kubernetes_host      = module.eks_cluster.cluster_endpoint
  kubernetes_ca_cert   = base64decode(module.eks_cluster.cluster_certificate_authority)
}
