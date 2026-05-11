################################################################################
# AWS IAM Identity Center (SSO) Setup
################################################################################

# Get the Identity Center instance (created automatically for AWS Organizations)
data "aws_ssoadmin_instances" "main" {}

locals {
  identity_store_id = data.aws_ssoadmin_instances.main.identity_store_ids[0]
  instance_arn      = data.aws_ssoadmin_instances.main.arns[0]
}

################################################################################
# Permission Set: Administrator Access
################################################################################

resource "aws_ssoadmin_permission_set" "administrator" {
  name             = "AdministratorAccess"
  description      = "Administrator access to AWS accounts"
  instance_arn     = local.instance_arn
  session_duration = "PT1H" # 1 hour
}

# Attach AWS managed policy to permission set
resource "aws_ssoadmin_managed_policy_attachment" "administrator" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

################################################################################
# Permission Set: Developer Access (Read-only + EKS)
################################################################################

resource "aws_ssoadmin_permission_set" "developer" {
  name             = "DeveloperAccess"
  description      = "Developer access with read-only and EKS permissions"
  instance_arn     = local.instance_arn
  session_duration = "PT8H" # 8 hours
}

resource "aws_ssoadmin_managed_policy_attachment" "developer_read_only" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "developer_eks" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFullAccess"
}

################################################################################
# Permission Set: DevOps Access
################################################################################

resource "aws_ssoadmin_permission_set" "devops" {
  name             = "DevOpsAccess"
  description      = "DevOps access for infrastructure and cluster management"
  instance_arn     = local.instance_arn
  session_duration = "PT12H" # 12 hours
}

resource "aws_ssoadmin_managed_policy_attachment" "devops_eks" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devops.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFullAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "devops_ec2" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devops.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "devops_iam" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devops.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "devops_logs" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devops.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

################################################################################
# Permission Set: ViewOnly
################################################################################

resource "aws_ssoadmin_permission_set" "viewer" {
  name             = "ViewerAccess"
  description      = "Read-only access for auditing and monitoring"
  instance_arn     = local.instance_arn
  session_duration = "PT4H" # 4 hours
}

resource "aws_ssoadmin_managed_policy_attachment" "viewer" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.viewer.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
