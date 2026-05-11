resource "aws_iam_policy" "policy" {
  name   = var.policy_name
  policy = var.policy
}
