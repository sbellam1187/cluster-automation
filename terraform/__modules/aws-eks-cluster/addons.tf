resource "aws_eks_addon" "addon" {
  for_each = var.addon_configs

  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = each.key
  addon_version               = each.value.version
  configuration_values        = each.value.configuration_values == null ? null : jsonencode(jsondecode(each.value.configuration_values))
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
}
