variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "environment" {
  description = "Deployment environment (e.g., prod, nonprod)"
  type        = string
  default     = "nonprod"
}
variable "pod_policy_arns" {
  description = "Permission Policies for Pod Identity"
  type        = list(string)
  default     = []
}
variable "github_arn" {
  description = "Github OIDC Identifier Name"
  type        = string
  default     = "arn:aws:iam::285282426848:oidc-provider/token.actions.githubusercontent.com"
}
variable "velero_s3_bucket_name" {
  description = "Name of the S3 bucket for Velero backups"
  type        = string
}
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}
