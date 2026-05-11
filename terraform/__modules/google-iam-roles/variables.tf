# Google IAM Roles Module
# Creates service accounts and manages IAM roles

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_account_name" {
  description = "Service account name"
  type        = string
}

variable "display_name" {
  description = "Service account display name"
  type        = string
  default     = ""
}

variable "roles" {
  description = "List of IAM roles to grant to service account"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "GCP labels"
  type        = map(string)
  default     = {}
}
