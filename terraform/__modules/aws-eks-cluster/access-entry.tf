resource "aws_eks_access_entry" "platform_admin" {
  for_each      = toset(var.platform_admin_role_arns)
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "platform_admin" {
  for_each      = toset(var.platform_admin_role_arns)
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}