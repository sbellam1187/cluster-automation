resource "aws_eks_pod_identity_association" "pod_identities" {
  for_each = var.pod_identity_associations

  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn
  depends_on      = [aws_eks_addon.eks_pod_identity_agent]
}
