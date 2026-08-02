# we use these locals to output public subnet IDs and use it in the configmap of
# argocd to replace TEMPLATE_VAR_PUBLIC_SUBNET_ID with a comma-separated list of public subnet IDs
# for the istio-gateway ELB (as required by the aws-load-balancer-subnets Service annotation).
# This has nothing to do with the EKS cluster creation itself.
# TODO: find a better way to do this.
locals {
  # Auto-generate AAD group name from cluster name for dedicated clusters (if not explicitly provided)
  allowed_aad_groups = var.allowed_aad_groups != null ? var.allowed_aad_groups : upper(replace("AAD_${var.devexp_cluster_name}", "-", "_"))
  public_subnet_ids = {
    "us-east-1" = ["subnet-085dbba92ebc5f6e9", "subnet-07482c307b5062d67", "subnet-034d99c5c8ec1214d"]
    "us-west-2" = ["subnet-02b21e9038af74d8a", "subnet-0af589248f2ac676a", "subnet-0eaa7de9689d65e52"]
  }
}
