variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-project"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway"
  type        = bool
  default     = false
}

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

variable "enable_oidc_provider" {
  description = "Enable OIDC provider for IRSA"
  type        = bool
  default     = true
}

variable "enable_private_registry" {
  description = "Enable private container registry support"
  type        = bool
  default     = false
}

variable "private_registry_url" {
  description = "Private registry URL"
  type        = string
  default     = ""
  sensitive   = true
}

variable "private_registry_username" {
  description = "Private registry username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "private_registry_password" {
  description = "Private registry password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "private_registry_email" {
  description = "Private registry email"
  type        = string
  default     = ""
  sensitive   = true
}

variable "eni_configs" {
  description = "Map of Availability Zone to ENI subnet IDs for pod networking (optional)"
  type        = map(string)
  default     = {}
  # Example:
  # {
  #   "us-east-1a" = "subnet-12345678"
  #   "us-east-1b" = "subnet-87654321"
  #   "us-east-1c" = "subnet-11223344"
  # }
}

variable "platform_admin_role_arns" {
  description = "List of IAM role ARNs to grant cluster admin access via EKS Access Entries"
  type        = list(string)
  default     = []
  # Example:
  # [
  #   "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_12345678",
  #   "arn:aws:iam::123456789012:role/github-actions-deploy-role"
  # ]
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}
