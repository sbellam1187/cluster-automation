# Environment and Application Variables
variable "castai_cluster_id" {
  description = "CAST AI cluster ID"
  type        = string
}
variable "castai_workload_scaling_policies" {
  description = "Map of workload scaling policies configuration"
  type        = any
  default     = {}
}

variable "scaling_policy_order" {
  description = "List of policy keys in desired order (keys from castai_workload_scaling_policies map). If empty, uses natural order."
  type        = list(string)
  default     = []
}
variable "vpc_id" {
  type        = string
  description = "VPC of the cluster IAM resources will created for."
  default     = null
}
variable "aks_cluster_name" {
  description = "k8s clusters name"
  default     = null
  type        = string
}
variable "aks_resource_group_name" {
  default     = null
  type        = string
  description = "aks cluster resource group name"
}
variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = null
}
variable "castai_node_autoscale_enable" {
  description = "Variable to specify the condition to enable CAST AI node autoscaling"
  type        = bool
  default     = false
}

variable "castai_autoscaler_settings" {
  description = "Settings for CastAI autoscaler"
  type        = any
  default     = {}
}

# castai node configurations variables
variable "castai_node_configurations" {
  type        = any
  description = "Map of node configurations to create"
  default     = {}
}

variable "castai_default_node_configuration_name" {
  type        = string
  description = "Name of the default node configuration"
  default     = "aa_castai_node_conf_default"
}
variable "castai_node_templates" {
  type        = any
  description = "Map of node templates to create"
  default     = {}
}

variable "castai_rebalancing_schedule" {
  type        = any
  description = "Map of CastAI rebalancing schedules to create"
  default     = {}
}
variable "instance_profile_arn" {
  type        = string
  default     = null
  description = "instance profile role arn"
}
