locals {
  iam_policy_prefix = "arn:aws:iam::${data.aws_partition.current.partition}:policy"

  castai_instance_profile_policy_list = {
    AmazonEKSWorkerNodePolicy          = "${local.iam_policy_prefix}/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "${local.iam_policy_prefix}/AmazonEC2ContainerRegistryReadOnly"
    AmazonEKS_CNI_Policy               = "${local.iam_policy_prefix}/AmazonEKS_CNI_Policy"
    AmazonEBSCSIDriverPolicy           = "${local.iam_policy_prefix}/service-role/AmazonEBSCSIDriverPolicy"
    AmazonSSMManagedInstanceCore       = "${local.iam_policy_prefix}/AmazonSSMManagedInstanceCore"
  }
}

resource "aws_iam_role_policy_attachment" "castai_iam_policy_attachment" {
  role       = aws_iam_role.cast_role.name
  policy_arn = aws_iam_policy.castai_iam_policy.arn
}

resource "aws_iam_role" "cast_role" {
  name               = "${var.cluster_name}-castaiCluster-role-${var.sdlc_environment}"
  assume_role_policy = data.aws_iam_policy_document.cast_assume_role_policy.json
}

resource "aws_iam_policy" "castai_iam_policy" {
  name   = "${var.cluster_name}-castaiCluster-policy-${var.sdlc_environment}"
  policy = data.castai_eks_settings.eks.iam_policy_json
}

resource "aws_iam_role_policy" "castai_role_iam_policy" {
  name   = "${var.cluster_name}-castaiCluster-rolepolicy-${var.sdlc_environment}"
  role   = aws_iam_role.cast_role.name
  policy = data.castai_eks_settings.eks.iam_user_policy_json
}
resource "aws_iam_role_policy_attachment" "castai_iam_readonly_policy_attachment" {
  for_each = {
    AmazonEC2ReadOnlyAccess = "${local.iam_policy_prefix}/AmazonEC2ReadOnlyAccess",
    IAMReadOnlyAccess       = "${local.iam_policy_prefix}/IAMReadOnlyAccess",
  }
  role       = aws_iam_role.cast_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "instance_profile_role" {
  name                 = "${var.cluster_name}-castaiNode-role-${var.sdlc_environment}"
  max_session_duration = var.max_session_duration
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.cluster_name}-castaiNode-profile-${var.sdlc_environment}"
  role = aws_iam_role.instance_profile_role.name
}
resource "aws_iam_role_policy_attachment" "castai_instance_profile_policy" {
  for_each = local.castai_instance_profile_policy_list

  role       = aws_iam_instance_profile.instance_profile.role
  policy_arn = each.value
}

resource "aws_eks_access_entry" "access_entry" {
  cluster_name  = data.aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.instance_profile_role.arn
  type          = "EC2_LINUX"
}
