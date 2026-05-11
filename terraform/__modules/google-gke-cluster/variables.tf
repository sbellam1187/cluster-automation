# GKE Cluster Module
# Creates GKE cluster with configurable node pools and security features

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zones" {
  description = "GCP zones for cluster"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "secondary_ip_range_pods" {
  description = "Secondary IP range for pods"
  type        = string
}

variable "secondary_ip_range_services" {
  description = "Secondary IP range for services"
  type        = string
}

variable "initial_node_count" {
  description = "Initial node count per zone"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum node count per zone"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum node count per zone"
  type        = number
  default     = 10
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Node disk size in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Node disk type"
  type        = string
  default     = "pd-standard"
}

variable "enable_preemptible_nodes" {
  description = "Use preemptible nodes"
  type        = bool
  default     = false
}

variable "enable_private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "Authorized networks for control plane"
  type = list(object({
    name  = string
    cidr  = string
  }))
  default = []
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "enable_shielded_nodes" {
  description = "Enable shielded nodes"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable binary authorization"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable cloud logging"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable cloud monitoring"
  type        = bool
  default     = true
}

variable "maintenance_window_start_time" {
  description = "Maintenance window start time"
  type        = string
  default     = "2026-01-01T12:00:00Z"
}

variable "maintenance_window_duration" {
  description = "Maintenance window duration in hours"
  type        = number
  default     = 4
}

variable "node_service_account_email" {
  description = "Service account email for nodes"
  type        = string
}

variable "service_account_scopes" {
  description = "Scopes for node service account"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "labels" {
  description = "GCP labels"
  type        = map(string)
  default     = {}
}
