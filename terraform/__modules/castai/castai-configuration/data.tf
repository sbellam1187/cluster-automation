data "castai_workload_scaling_policy_order" "cluster" {
  cluster_id = var.castai_cluster_id
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  count               = var.aks_resource_group_name != null ? 1 : 0
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group_name
}

data "aws_eks_cluster" "eks_cluster" {
  count = var.eks_cluster_name != null ? 1 : 0
  name  = var.eks_cluster_name
}

data "aws_subnets" "eks_ec2_only" {
  count = var.vpc_id != null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["*-ec2"]
  }
}
