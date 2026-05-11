output "identity_store_id" {
  description = "Identity Store ID"
  value       = local.identity_store_id
}

output "instance_arn" {
  description = "Identity Center instance ARN"
  value       = local.instance_arn
}

output "administrator_permission_set_arn" {
  description = "Administrator permission set ARN"
  value       = aws_ssoadmin_permission_set.administrator.arn
}

output "developer_permission_set_arn" {
  description = "Developer permission set ARN"
  value       = aws_ssoadmin_permission_set.developer.arn
}

output "devops_permission_set_arn" {
  description = "DevOps permission set ARN"
  value       = aws_ssoadmin_permission_set.devops.arn
}

output "viewer_permission_set_arn" {
  description = "Viewer permission set ARN"
  value       = aws_ssoadmin_permission_set.viewer.arn
}

output "permission_sets" {
  description = "All permission sets"
  value = {
    administrator = aws_ssoadmin_permission_set.administrator.arn
    developer     = aws_ssoadmin_permission_set.developer.arn
    devops        = aws_ssoadmin_permission_set.devops.arn
    viewer        = aws_ssoadmin_permission_set.viewer.arn
  }
}
