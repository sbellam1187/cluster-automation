# Google VPC Module
# Creates VPC network and subnets for GKE clusters

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
}

variable "secondary_ranges" {
  description = "Secondary IP ranges for pods and services"
  type = object({
    pods     = string
    services = string
  })
}

variable "enable_private_google_access" {
  description = "Enable Private Google Access"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "tags" {
  description = "GCP labels"
  type        = map(string)
  default     = {}
}

locals {
  network_name = var.network_name
  subnet_name  = var.subnet_name
}
