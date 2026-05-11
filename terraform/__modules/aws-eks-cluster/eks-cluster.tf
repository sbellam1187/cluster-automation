resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn
  tags     = var.tags


  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids              = var.subnet_ids
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  upgrade_policy {
    support_type = var.upgrade_policy
  }
  bootstrap_self_managed_addons = true

}
