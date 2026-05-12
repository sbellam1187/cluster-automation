################################################################################
# GCP Configuration
################################################################################

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

################################################################################
# Cluster Configuration
################################################################################

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  validation {
    condition     = length(var.cluster_name) >= 1 && length(var.cluster_name) <= 40
    error_message = "Cluster name must be 1-40 characters."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version (empty for latest)"
  type        = string
  default     = ""
}

variable "cluster_location" {
  description = "Cluster location type: 'regional' or 'zonal'"
  type        = string
  default     = "regional"
  validation {
    condition     = contains(["regional", "zonal"], var.cluster_location)
    error_message = "Must be 'regional' or 'zonal'"
  }
}

################################################################################
# Network Configuration
################################################################################

variable "network_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_primary_cidr" {
  description = "Primary subnet CIDR (used for node IPs)"
  type        = string
  default     = "10.1.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for pod IPs. Must not overlap with network_cidr, subnet_primary_cidr, or services_cidr."
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR range for service (ClusterIP) IPs. Must not overlap with network_cidr, subnet_primary_cidr, or pods_cidr."
  type        = string
  default     = "10.8.0.0/20"
}

################################################################################
# GKE Features
################################################################################

variable "enable_private_cluster" {
  description = "Enable private GKE cluster"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable Kubernetes network policies"
  type        = bool
  default     = true
}

variable "enable_http_load_balancing" {
  description = "Enable HTTP load balancing add-on"
  type        = bool
  default     = true
}

variable "enable_network_policy_addon" {
  description = "Enable Network Policy add-on"
  type        = bool
  default     = true
}

variable "enable_cloud_logging" {
  description = "Enable Cloud Logging"
  type        = bool
  default     = true
}

variable "enable_cloud_monitoring" {
  description = "Enable Cloud Monitoring"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization"
  type        = bool
  default     = false
}

################################################################################
# Node Pool Configuration
################################################################################

variable "node_pools" {
  description = "Node pool configuration"
  type = map(object({
    node_count       = optional(number, 1)
    min_node_count   = number
    max_node_count   = number
    machine_type     = string
    disk_size_gb     = optional(number, 50)
    disk_type        = optional(string, "pd-standard")
    preemptible      = optional(bool, false)
    auto_repair      = optional(bool, true)
    auto_upgrade     = optional(bool, true)
    oauth_scopes     = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
    labels           = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags = optional(list(string), [])
  }))
  default = {
    general = {
      min_node_count = 1
      max_node_count = 5
      machine_type   = "n2-standard-2"
      disk_size_gb   = 50
      labels = {
        workload = "general"
      }
    }
  }
}

################################################################################
# Maintenance Windows
################################################################################

variable "maintenance_window_day" {
  description = "Day of week for maintenance (0=Sunday)"
  type        = number
  default     = 3
}

variable "maintenance_window_hour" {
  description = "Hour of day for maintenance (UTC)"
  type        = number
  default     = 2
}

################################################################################
# RBAC
################################################################################

variable "cluster_admin_users" {
  description = "Users with cluster admin role"
  type        = list(string)
  default     = []
}

variable "cluster_edit_users" {
  description = "Users with cluster edit role"
  type        = list(string)
  default     = []
}

variable "cluster_view_users" {
  description = "Users with cluster view role"
  type        = list(string)
  default     = []
}

################################################################################
# Workload Identity
################################################################################

variable "workload_identity_namespaces" {
  description = "Namespaces for workload identity setup"
  type        = list(string)
  default     = ["default", "kube-system"]
}

################################################################################
# Labels and Tags
################################################################################

variable "labels" {
  description = "GKE cluster labels"
  type        = map(string)
  default = {
    managed-by = "terraform"
  }
}

variable "resource_labels" {
  description = "Resource labels for GCP resources"
  type        = map(string)
  default = {
    managed-by = "terraform"
  }
}

variable "tags" {
  description = "Network tags"
  type        = list(string)
  default     = []
}
