data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_iam_policy_document" "cast_assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [castai_eks_user_arn.castai_user_arn.arn]
    }
  }
}

# castai eks settings (provides required iam policies)
data "castai_eks_settings" "eks" {
  account_id = data.aws_caller_identity.current.account_id
  vpc        = var.vpc_id
  region     = data.aws_region.current.region
  cluster    = var.cluster_name
}
