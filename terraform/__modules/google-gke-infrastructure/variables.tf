################################################################################
# GCP Project and Network
################################################################################

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

################################################################################
# Cluster Configuration
################################################################################

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version (or empty for latest)"
  type        = string
  default     = ""
}

variable "cluster_location" {
  description = "Regional (multi-zone) or zonal cluster location"
  type        = string
  default     = "regional"
  validation {
    condition     = contains(["regional", "zonal"], var.cluster_location)
    error_message = "cluster_location must be 'regional' or 'zonal'"
  }
}

variable "zones" {
  description = "Availability zones for zonal clusters"
  type        = list(string)
  default     = []
}

################################################################################
# Network Configuration
################################################################################

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "network_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_primary_cidr" {
  description = "Primary subnet CIDR for pods"
  type        = string
  default     = "10.1.0.0/20"
}

variable "subnet_secondary_ranges" {
  description = "Secondary IP ranges for pods and services"
  type = map(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = {
    pods = {
      range_name    = "pods"
      ip_cidr_range = "10.4.0.0/14"
    }
    services = {
      range_name    = "services"
      ip_cidr_range = "10.8.0.0/20"
    }
  }
}

variable "enable_private_cluster" {
  description = "Enable private cluster (nodes have only private IPs)"
  type        = bool
  default     = true
}

variable "master_ipv4_cidr" {
  description = "CIDR block for the GKE control plane"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to access the GKE control plane endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [{
    cidr_block   = "10.0.0.0/8"
    display_name = "enterprise-private"
  }]
}

variable "enable_network_policy" {
  description = "Enable Kubernetes network policy"
  type        = bool
  default     = true
}

variable "enable_firewall_rules" {
  description = "Create baseline enterprise firewall rules for GKE nodes and health checks"
  type        = bool
  default     = true
}

variable "health_check_source_ranges" {
  description = "Source ranges allowed for Google Cloud load balancer health checks"
  type        = list(string)
  default     = ["35.191.0.0/16", "130.211.0.0/22"]
}

################################################################################
# GKE Add-ons and Features
################################################################################

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
  description = "Enable Workload Identity for pod-to-GCP service account mapping"
  type        = bool
  default     = true
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes (GKE security hardening)"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization"
  type        = bool
  default     = false
}

variable "maintenance_window_day" {
  description = "Day of week for maintenance window (0=Sunday)"
  type        = number
  default     = 3 # Wednesday
}

variable "maintenance_window_hour" {
  description = "Hour of day for maintenance window (UTC)"
  type        = number
  default     = 2
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
# Workload Identity Configuration
################################################################################

variable "workload_identity_enabled" {
  description = "Enable workload identity for pod-to-GSA mapping (kept for compatibility with existing callers)"
  type        = bool
  default     = true
}

variable "workload_identity_namespaces" {
  description = "Kubernetes namespaces for workload identity setup"
  type        = list(string)
  default     = ["default", "kube-system"]
}

################################################################################
# RBAC and Access Control
################################################################################

variable "cluster_admin_users" {
  description = "List of users/service accounts to grant cluster admin role"
  type        = list(string)
  default     = []
}

variable "cluster_edit_users" {
  description = "List of users/service accounts to grant cluster edit role"
  type        = list(string)
  default     = []
}

variable "cluster_view_users" {
  description = "List of users/service accounts to grant cluster view role"
  type        = list(string)
  default     = []
}

################################################################################
# Tags and Labels
################################################################################

variable "labels" {
  description = "GKE cluster labels"
  type        = map(string)
  default     = {}
}

variable "resource_labels" {
  description = "Resource labels for GCP resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Network tags"
  type        = list(string)
  default     = []
}
