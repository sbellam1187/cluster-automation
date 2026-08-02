output "app_sdlc_environment" {
  value       = var.app_sdlc_environment
  description = "app sdlc env"
}
output "dx_k8s_cluster_name" {
  value       = module.eks_cluster.cluster_name
  description = "cluster name"
}
output "cluster_oidc_issuer" {
  value       = module.eks_cluster.cluster_oidc_issuer
  description = "EKS cluster OIDC issuer"
}

output "cloud_provider" {
  value       = "eks"
  description = "cloud provider type"
}


output "dx_cluster_num" {
  description = "cluster number"
  value       = element(split("-", module.eks_cluster.cluster_name), 4)
}

output "public_subnet_id" {
  description = "Comma-separated list of public subnet IDs suitable for the service.beta.kubernetes.io/aws-load-balancer-subnets annotation"
  value       = join(",", local.public_subnet_ids[var.region])
}
