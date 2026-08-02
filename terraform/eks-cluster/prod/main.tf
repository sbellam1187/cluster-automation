module "eks_cluster" {
  source                   = "git::https://github.com/AAInternal/runway-kubernetes-cluster-automation//terraform/__modules/aws-eks-cluster?ref=v3.0.0-tf-eks-cluster%2Bpr7730"
  cluster_name             = var.cluster_name
  cluster_version          = var.cluster_version
  subnet_ids               = var.eks_subnet_ids
  ec2_subnet_ids           = var.ec2_subnet_ids
  cluster_role_arn         = var.cluster_role_arn
  eni_configs              = var.eni_configs
  platform_admin_role_arns = var.platform_admin_role_arns
  node_groups              = var.node_groups
  node_role_arn            = var.node_role_arn
  tags                     = var.tags
  addon_configs            = var.addon_configs

  pod_identity_associations = {
    container_registry = {
      namespace       = "container-registry-update"
      service_account = "container-registry-update-sa"
      role_arn        = "arn:aws:iam::045755618773:role/containerRegistry-tokens-podIdentity-role-prod"
    }
    ack-eks-controller = {
      namespace       = "ack-system"
      service_account = "ack-eks-controller"
      role_arn        = "arn:aws:iam::045755618773:role/ack-eks-podIdentity-role-prod"
    }
    ack-iam-controller = {
      namespace       = "ack-system"
      service_account = "ack-iam-controller"
      role_arn        = "arn:aws:iam::045755618773:role/ack-eks-podIdentity-role-prod"
    }
  }
}
