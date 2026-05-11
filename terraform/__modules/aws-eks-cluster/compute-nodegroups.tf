resource "aws_eks_node_group" "ng_pool" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = each.key
  version         = each.value.orchestrator_version
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.ec2_subnet_ids

  disk_size = each.value.disk_size
  tags      = var.tags

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }
  instance_types = each.value.instance_types
  labels         = each.value.labels
  dynamic "taint" {
    for_each = lookup(each.value, "node_taints", {})
    content {
      key    = each.value.node_taints.key
      value  = each.value.node_taints.value
      effect = each.value.node_taints.effect
    }
  }

  depends_on           = [helm_release.raw_eni_config]
  capacity_type        = each.value.capacity_type
  force_update_version = lookup(each.value, "force_update_version", false) # Default false if not specified, this is added to support pod eviction failures
}
