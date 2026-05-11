variable "app_sdlc_environment" {
  description = "app_sdlc_environment"
  type        = string
}
variable "cloud_provider" {
  description = "cloud provider of the cluster"
  type        = string
}
variable "runway_status" {
  description = "status of the cluster for runway to identify"
  type        = string
  default     = "active"
}
variable "location" {
  description = "location"
  type        = string
}
# Rancher variables
variable "rancher_url" {
  description = "rancher_url"
  type        = map(string)
  default = {
    "lab"     = "https://master-drke.ok8s.aa.com"
    "nonprod" = "https://master-nprke.ok8s.aa.com"
    "prod"    = "https://master-rke.ok8s.aa.com"
  }
}

variable "azad_mgmt_group_owner" {
  description = "azad_mgmt_group_owner"
  type        = map(string)
  default = {
    "lab"     = "AAD_KPAAS_RANCHER_N"
    "nonprod" = "AAD_KPAAS_RANCHER_N"
  }
}

variable "azad_mgmt_group_reader" {
  description = "azad_mgmt_group_reader"
  type        = map(string)
  default = {
    "lab"     = "AAD_READONLY_KPAAS_RANCHER_N"
    "nonprod" = "AAD_READONLY_KPAAS_RANCHER_N"
    "prod"    = "AAD_READONLY_KPAAS_RANCHER_P"
  }
}

variable "azad_mgmt_group_admin_reader" {
  description = "azad_mgmt_group_admin_reader"
  type        = string
  default     = "AAD_KPAAS_RANCHER_P" # this is only for prod
}

variable "azad_runway_automation_zaccount" {
  description = "azad_runway_automation_zaccount"
  type        = map(string)
  default = {
    "lab"     = "Z2095621"
    "nonprod" = "Z2095621"
    "prod"    = "Z2095621"
  }
}

# OCI Image Registry variables
variable "registry_server" {
  description = "registry_server"
  type        = string
  default     = "docker.aa.com"
}

variable "registry_username" {
  description = "registry_username"
  type        = string
}

variable "registry_password" {
  description = "registry_password"
  type        = string
  sensitive   = true
}

variable "registry_email" {
  # Optional
  description = "registry_email"
  type        = string
  default     = ""
}



variable "cluster_name" {
  description = "full cluster name"
  type        = string
}
variable "dx_cluster_name" {
  description = "short name of the cluster"
  type        = string
}

variable "container_registry_update_container_tag" {
  type        = string
  description = "The image tag to use for the container registry update container."
}

variable "env_based_namespace_tolerations" {
  description = "A list of default tolerations that should be passed into k8s namespaces created via Terraform"
  type        = map(string)
  default = {
    "lab"     = "[{\"operator\": \"Exists\", \"key\": \"SystemWorkload\"},{\"operator\":\"Equal\",\"effect\":\"NoSchedule\",\"key\":\"kubernetes.azure.com/scalesetpriority\",\"value\":\"spot\"}]"
    "nonprod" = "[{\"operator\": \"Exists\", \"key\": \"SystemWorkload\"}]"
    "prod"    = "[{\"operator\": \"Exists\", \"key\": \"SystemWorkload\"}]"
  }
}

variable "env_based_pod_tolerations" {
  type        = map(list(map(string)))
  description = "A list of tolerations that should be passed into k8s pods created via Terraform"
  default = {
    lab = [
      {
        key      = "node-role.kubernetes.io/controlplane"
        value    = "true"
        effect   = "NoSchedule"
        operator = null
      },
      {
        key      = "CriticalAddonsOnly"
        value    = "true"
        effect   = "NoSchedule"
        operator = null
      },
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
        effect   = "NoSchedule"
        value    = null
      },
      {
        key      = "node-role.kubernetes.io/master"
        operator = "Exists"
        effect   = "NoSchedule"
        value    = null
      },
      {
        operator = "Equal"
        effect   = "NoSchedule"
        key      = "kubernetes.azure.com/scalesetpriority"
        value    = "spot"
      }
    ]
    nonprod = [
      {
        key      = "node-role.kubernetes.io/controlplane"
        value    = "true"
        effect   = "NoSchedule"
        operator = null
      },
      {
        key      = "CriticalAddonsOnly"
        value    = "true"
        effect   = "NoSchedule"
        operator = null
      },
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
        effect   = "NoSchedule"
        value    = null
      },
      {
        key      = "node-role.kubernetes.io/master"
        operator = "Exists"
        effect   = "NoSchedule"
        value    = null
      }
    ]
    prod = [
      {
        key      = "node-role.kubernetes.io/controlplane"
        value    = "true"
        effect   = "NoSchedule"
        operator = null
      },
      {
        key      = "CriticalAddonsOnly"
        value    = "true"
        effect   = "NoSchedule"
        operator = null
      },
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
        effect   = "NoSchedule"
        value    = null
      },
      {
        key      = "node-role.kubernetes.io/master"
        operator = "Exists"
        effect   = "NoSchedule"
        value    = null
      }
    ]
  }
}
variable "node_selector_annotation" {
  description = "node_selector_annotation"
  type        = string
  default     = "agentpool=gen02"
}

variable "additional_labels" {
  description = "Additional labels to apply to Kubernetes resources"
  type        = map(string)
  default     = {}
}
