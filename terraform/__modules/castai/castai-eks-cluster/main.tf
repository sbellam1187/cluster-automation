resource "castai_eks_cluster" "eks_cluster" {
  account_id                 = data.aws_caller_identity.current.account_id
  region                     = data.aws_region.current.region
  name                       = data.aws_eks_cluster.eks.id
  assume_role_arn            = aws_iam_role.cast_role.arn
  delete_nodes_on_disconnect = var.delete_nodes_on_disconnect
}
resource "castai_eks_clusterid" "cluster_id" {
  account_id   = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.region
  cluster_name = var.cluster_name
}
resource "castai_eks_user_arn" "castai_user_arn" {
  cluster_id = castai_eks_clusterid.cluster_id.id
}
