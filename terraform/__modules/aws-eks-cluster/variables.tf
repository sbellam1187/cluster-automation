variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string

}

variable "ec2_subnet_ids" {
  description = "List of subnet IDs for the node groups"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}
variable "upgrade_policy" {
  description = "Upgrade policy for the EKS cluster"
  type        = string
  default     = "STANDARD"
}

variable "eni_configs" {
  description = "Map of AZ to ENIConfig manifest spec"
  type        = map(any)
}

variable "platform_admin_role_arns" {
  type        = list(string)
  description = "List of ARNs for IAM roles to be granted platform admin access to the EKS cluster"
}

variable "node_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  type        = string
}

variable "node_groups" {
  description = "Managed node group definitions"
  type = map(object({
    desired_size         = number
    min_size             = number
    max_size             = number
    instance_types       = list(string)
    labels               = optional(map(string), {})
    node_taints          = optional(map(string), {})
    capacity_type        = optional(string, "ON_DEMAND")
    disk_size            = optional(number, 512)
    orchestrator_version = optional(string, null)
    force_update_version = optional(bool)
  }))
}

variable "pod_identity_associations" {
  description = "Map of pod identity associations to create"
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
  }))
  default = {}
}
variable "tags" {
  description = "A map of tags to assign to the EKS cluster"
  type        = map(string)
  default     = {}
}

variable "addon_configs" {
  description = "Map of addon names to their configurations"
  type = map(object({
    version                     = string
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    configuration_values        = optional(string)
  }))
}
