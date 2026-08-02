# we use these locals to output one of the public subnet IDs randomly
# and use it in the confgmanp of argocd to replace TEMPLATE_VAR_PUBLIC_SUBNET_ID
# for istio-gateway. This has nothing to do with the EKS cluster creation itself.
# TODO: find a better way to do this.
locals {
  # Auto-generate AAD group name from cluster name for dedicated clusters (if not explicitly provided)
  allowed_aad_groups = var.allowed_aad_groups != null ? var.allowed_aad_groups : upper(replace("AAD_${var.devexp_cluster_name}", "-", "_"))
  public_subnet_ids = {
    "us-east-1" = ["subnet-0725772ef2132c7d0", "subnet-02db7f83decd30d5a", "subnet-0ce6f5732433e736a"]
    "us-west-2" = ["subnet-04d64ecdbbf1a5ea8", "subnet-03d9cf06183c29047", "subnet-00ab9504e678ca700"]
  }
}
