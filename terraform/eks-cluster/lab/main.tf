module "eks_cluster" {
  source                   = "../../__modules/aws-eks-cluster" ## Alway gets module from main
  cluster_name             = var.cluster_name
  cluster_version          = var.cluster_version
  subnet_ids               = var.eks_subnet_ids[var.region]
  ec2_subnet_ids           = var.ec2_subnet_ids[var.region]
  cluster_role_arn         = var.cluster_role_arn
  eni_configs              = var.eni_configs[var.region]
  platform_admin_role_arns = var.platform_admin_role_arns
  node_groups              = var.node_groups
  node_role_arn            = var.node_role_arn
  tags                     = var.tags
  addon_configs            = var.addon_configs

  pod_identity_associations = {
    container_registry = {
      namespace       = "container-registry-update"
      service_account = "container-registry-update-sa"
      role_arn        = "arn:aws:iam::285282426848:role/containerRegistry-tokens-podIdentity-role-nonprod"
    }
    ack-eks-controller = {
      namespace       = "ack-system"
      service_account = "ack-eks-controller"
      role_arn        = "arn:aws:iam::285282426848:role/ack-eks-podIdentity-role-nonprod"
    }
    ack-iam-controller = {
      namespace       = "ack-system"
      service_account = "ack-iam-controller"
      role_arn        = "arn:aws:iam::285282426848:role/ack-eks-podIdentity-role-nonprod"
    }
  }
}
