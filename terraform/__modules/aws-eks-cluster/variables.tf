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
variable "cni_custom_config" {
  description = "Custom configuration for the VPC CNI plugin"
  type        = string
  default     = <<EOF
{
  "env": {
    "ENI_CONFIG_LABEL_DEF": "topology.kubernetes.io/zone",
    "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true"
  }
}
EOF
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

variable "vpc_cni_version" {
  description = "vpc_cni addon compatible version as per controlplane version"
  type        = string
  default     = "v1.20.4-eksbuild.2"
}

variable "metrics_server_version" {
  description = "metrics_server addon compatible version as per controlplane version"
  type        = string
  default     = "v0.8.1-eksbuild.6"
}

variable "eks_pod_identity_agent_version" {
  description = "eks_pod_identity_agent addon compatible version as per controlplane version"
  type        = string
  default     = "v1.3.10-eksbuild.3"
}

variable "aws_mountpoint_s3_csi_driver_version" {
  description = "aws_mountpoint_s3_csi_driver addon compatible version as per controlplane version"
  type        = string
  default     = "v2.5.0-eksbuild.1"
}

variable "kube_proxy_version" {
  description = "kube-proxy addon compatible version as per controlplane version"
  type        = string
  default     = "v1.34.6-eksbuild.2"
}

variable "coredns_version" {
  description = "coredns addon compatible version as per controlplane version"
  type        = string
  default     = "v1.12.4-eksbuild.10"
}
