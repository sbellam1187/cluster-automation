################################################################################
# VPC Configuration
################################################################################

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

################################################################################
# Cluster Configuration
################################################################################

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

################################################################################
# Subnet Configuration
################################################################################

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks (used for node IPs)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "pod_subnet_cidrs" {
  description = "CIDR blocks for pod subnets, one per availability zone. Uses the CGNAT range (100.64.0.0/x) to keep pod IPs in a completely separate space from node and service IPs, avoiding VPC CIDR exhaustion. Set to an empty list to disable custom pod networking."
  type        = list(string)
  default     = ["100.64.0.0/18", "100.64.64.0/18", "100.64.128.0/18"]
}

################################################################################
# Node Group Configuration
################################################################################

variable "node_groups" {
  description = "Node group configuration"
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    disk_size      = number
    capacity_type  = string
    labels         = optional(map(string), {})
  }))
  default = {
    general = {
      desired_size   = 2
      min_size       = 1
      max_size       = 5
      instance_types = ["t3.medium"]
      disk_size      = 50
      capacity_type  = "ON_DEMAND"
      labels = {
        role = "general"
      }
    }
  }
}

################################################################################
# Add-ons and Pod Identity
################################################################################

variable "enable_cluster_logging" {
  description = "Enable EKS cluster logging"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "EKS cluster log types"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "pod_identity_associations" {
  description = "Pod identity associations for workload IAM"
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
  }))
  default = {}
}

################################################################################
# Advanced Features
################################################################################

variable "eni_configs" {
  description = "Map of AZ to ENI subnet IDs for pod networking (optional)"
  type        = map(string)
  default     = {}
}

variable "platform_admin_role_arns" {
  description = "List of IAM role ARNs to grant cluster admin access via EKS Access Entries"
  type        = list(string)
  default     = []
}

variable "enable_oidc_provider" {
  description = "Enable OIDC provider for IRSA"
  type        = bool
  default     = true
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
