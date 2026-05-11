variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
variable "sdlc_environment" {
  type        = string
  description = "Cluster environment"
}

variable "delete_nodes_on_disconnect" {
  description = "Delete nodes when disconnected from CAST AI"
  type        = bool
  default     = true
}

### CAST AI EKS Cluster IAM variables

variable "vpc_id" {
  type        = string
  description = "VPC of the cluster IAM resources will created for."
}
variable "max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role."
  type        = number
  default     = 3600
}
