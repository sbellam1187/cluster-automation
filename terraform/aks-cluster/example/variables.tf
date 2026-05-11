variable "app_archer_id" {
  description = "app_archer_id"
  type        = string
}

# tflint-ignore: terraform_naming_convention
variable "app-shortname" {
  description = "app-shortname"
  type        = string
}

variable "aa_criticality" {
  description = "aa criticality"
  type        = string
  default     = "vital"
}

variable "app_owner" {
  description = "app_owner"
  type        = string
}

variable "app_product" {
  description = "app_product"
  type        = string
}

variable "app_sdlc_environment" {
  description = "app_sdlc_environment"
  type        = string
}

variable "auto_patch_upgrade" {
  description = "automatic patch upgrade"
  type        = bool
  default     = false
}

variable "node_upgrade_channel" {
  description = "automatic os upgrade on Nodes"
  type        = string
  default     = "None"
}

variable "app_security" {
  description = "app_security"
  type        = string
}

variable "devexp_cluster_name" {
  description = "devexp_cluster_name"
  type        = string
}

variable "devexp_cluster_num" {
  description = "devexp_cluster_num"
  type        = string
}

variable "dynatrace_url" {
  description = "dynatrace saas urls"
  type        = map(string)
  default = {
    "lab"     = "https://aa-nonprod.live.dynatrace.com"
    "nonprod" = "https://aa-nonprod.live.dynatrace.com"
    "prod"    = "https://aa-prod.live.dynatrace.com"
  }
}

# Hashicorp Vault
variable "vault_host_url" {
  description = "Vault server URL"
  type        = string
  default     = "https://vaultcdc.secretmgmt.aa.com/"
}

variable "vault_namespace" {
  description = "Vault server namespace"
  type        = string
  default     = "automation"
}

variable "vault_ca_cert_file" {
  description = "Vault server CA certificate"
  type        = string
  default     = "../../vault_secretmgmt_aa_com.pem"
}

variable "vault_login_approle_role_id" {
  description = "Vault Approle Role ID"
  type        = string
  sensitive   = true
}

variable "vault_login_approle_secret_id" {
  description = "Vault Approle Secret ID"
  type        = string
  sensitive   = true
}

variable "vault_kaas_login_approle_role_id" {
  description = "Vault Approle Role ID"
  type        = string
  sensitive   = true
}

variable "vault_kaas_login_approle_secret_id" {
  description = "Vault Approle Secret ID"
  type        = string
  sensitive   = true
}
# Default (system) node pool information
variable "max_pod_count" {
  description = "max_pod_count"
  type        = number
}

variable "node_vm_size" {
  description = "node_vm_size"
  type        = string
}

variable "min_node_count" {
  description = "min_node_count"
  type        = number
}

variable "max_node_count" {
  description = "max_node_count"
  type        = number
}

variable "default_node_count" {
  description = "default_node_count"
  type        = number
  default     = null
}

variable "system_node_labels" {
  description = "custom node labels for system nodepool"
  type        = map(string)
  default = {
    "aa_castai_agentpool" = "system"
  }
}

# Workload node pool configs and cluster size
variable "general_node_pools" {
  description = "A map of objects describing the general-purpose node pools that will be configured for this cluster."
  type = map(object({
    vm_size                     = optional(string, "Standard_D8ds_v4")
    orchestrator_version        = optional(string)
    enable_auto_scaling         = optional(bool, true)
    node_count                  = optional(number, 1)
    max_count                   = optional(number, 30)
    min_count                   = optional(number, 0)
    max_pods                    = optional(number, 60)
    node_labels                 = optional(map(string), {})
    node_taints                 = optional(list(string), [])
    vm_max_map_count            = optional(number)
    os_disk_size_gb             = optional(number)
    os_disk_type                = optional(string)
    priority                    = optional(string, "Regular")
    eviction_policy             = optional(string)
    spot_max_price              = optional(number)
    max_surge_count             = optional(number, 1)
    temporary_name_for_rotation = optional(string)
    tags                        = optional(map(string))
  }))
  default = {}
}

# Locations for nodepools within a region
# EASTUS has 3 AZs
# WESTUS has none
# The RIGHT thing would be to have a data
# source from azurerm that provides AZs based
# location ... and if needed, based on a SKU
# of a VM that we're using for the nodepool.
# I found nothing that matched this as data
# source in Terraform with the azurerm provider.
variable "availability_zones" {
  description = "availability_zones"
  type        = map(list(string))
  default     = {}
}

variable "location" {
  description = "location"
  type        = string
}

# None cluster resources go here, like keyvaults, storage acocunts
variable "asset_resource_group_name" {
  description = "asset_resource_group_name"
  type        = string
}


# ok8 cluster resources go here, like node pools
variable "cluster_resource_group_name" {
  description = "cluster_resource_group_name"
  type        = string
}


# Network stuff
variable "ets_subnet_name" {
  description = "ets_subnet_name"
  type        = map(any)
}

# Private IP for the ingress controller
variable "ingresscontroller_ip" {
  description = "ingresscontroller_ip"
  type        = map(any)
  default     = {}
}

variable "ets_vnet_name" {
  description = "ets_subnet_name"
  type        = map(any)
}

variable "ets_next_hop_ip" {
  description = "ets_subnet_name"
  type        = map(any)
}

variable "enable_auto_scaling" {
  description = "enable_auto_scaling"
  type        = bool
}

variable "loadbalancer_sku" {
  description = "loadbalancer_sku"
  type        = string
}


variable "kubernetes_version" {
  description = "kubernetes_version"
  type        = string
  default     = "1.24.10"
}

variable "nodepool_orchestrator_version" {
  description = "nodepool_orchestrator_version"
  type        = map(any)
  default     = {}
}

# Variables for cluster cidrs
# For the most part, these don't need to be changed
variable "aks_pod_cidr" {
  description = "aks_pod_cidr"
  type        = string
  default     = "192.168.0.0/18"
}

variable "aks_service_cidr" {
  description = "aks_service_cidr"
  type        = string
  default     = "192.168.248.0/21"
}

variable "aks_dns_ip_address" {
  description = "aks_dns_ip_address"
  type        = string
  default     = "192.168.248.10"
}

variable "ets_subnet" {
  description = "ets_subnet"
  type        = map(any)
}

variable "devexp_rancher_environment" {
  description = "devexp_rancher_environment"
  type        = string
  default     = ""
}

variable "rancher_token" {
  description = "rancher_token"
  type        = string
  sensitive   = true
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


variable "enable_rancher_registration" {
  description = "enable_rancher_registration"
  type        = bool
  default     = true
}

variable "rancher_url" {
  description = "rancher_url"
  type        = map(string)
  default = {
    "lab"     = "https://master-drke.ok8s.aa.com"
    "nonprod" = "https://master-nprke.ok8s.aa.com"
    "prod"    = "https://master-rke.ok8s.aa.com"
  }
}

variable "rancher_cluster_name" {
  description = "rancher_cluster_name"
  type        = map(string)
  default = {
    "lab"     = "rancher-sb-aks-103-eastus"
    "nonprod" = "rancher-np-aks-100-eastus"
    "prod"    = "rancher-p-aks-100-eastus"
  }
}

variable "rancher_resource_group_name" {
  description = "rancher_resource_group_name"
  type        = map(string)
  default = {
    "lab"     = "rancher-master-aks-sandbox-rg-eastus"
    "nonprod" = "rancher-master-aks-np-rg-eastus"
    "prod"    = "rancher-master-aks-p-rg-eastus"
  }
}

# FIXME: A better approach would be to get these from the DNS provider
# https://registry.terraform.io/providers/hashicorp/dns/latest/docs
variable "rancher_ip" {
  description = "rancher_ip"
  type        = map(string)
  default = {
    "lab"     = "10.25.65.139"
    "nonprod" = "10.25.86.11"
    "prod"    = "10.25.200.11"
  }
}

variable "container_registry_update_container_tag" {
  type        = string
  description = "The image tag to use for the container registry update container."
  default     = "v4.1.0"
}

variable "num_pips" {
  description = "Insert number of PIP for AKS cluster"
  type        = string
  default     = "1"
}

variable "outbound_ports_allocated" {
  description = "Insert number of PIP for AKS cluster"
  type        = string
  default     = "0"
}

variable "temporary_name_for_rotation" {
  type        = string
  default     = "tempnodepool"
  description = "(Optional) Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing"
}

variable "pci_resource_group" {
  description = "Resource group for the PCI cluster"
  type        = string
  default     = "dx-runway-core-prod-pci"
}

variable "pci_cluster" {
  description = "Boolean indicating if the cluster is for PCI"
  type        = bool
  default     = false
}

variable "private_aks" {
  description = "Boolean indicating if the cluster is Private or not"
  type        = bool
  default     = false
}

variable "p42_user" {
  type        = string
  description = "This value is used to name the rancher fleet cluster group."
  default     = "Z2115051"
}

variable "service_endpoints" {
  description = "List of service endpoints to be associated with the subnet"
  type        = list(string)
  default     = ["Microsoft.Storage", "Microsoft.Sql"]
}

variable "legacy_pci_linux_profile" {
  description = "Linux profile data used by legacy imported PCI clusters"
  type = object({
    admin_username = string
    ssh_key = object({
      key_data = string
    })
  })
  default = null
}

variable "azuread_rbac" {
  description = "Sets the Azure Active Directory Role Based Access Control block in the AKS cluster definition"
  type = object({
    enabled                = bool
    managed                = bool
    admin_group_object_ids = list(string)
  })
  default = null
}

variable "network_plugin" {
  description = "Network plugin to use for networking. Currently supported values are azure, kubenet and none. Changing this forces a new resource to be created."
  type        = string
  default     = "kubenet"
}

variable "support_plan" {
  description = "support_plan by default its is KubernetesOfficial and we can change it to AKSLongTermSupport"
  type        = string
  default     = "KubernetesOfficial"
}

variable "scale_down_utilization_threshold" {
  description = " Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to 0.5"
  type        = number
  default     = 0.5

}
variable "sku_tier" {
  description = "sku_tier by default its is Standard and we can change it to Basic/Premium"
  type        = string
  default     = "Standard"

}
variable "outbound_type" {
  description = "Specifies the outbound type for the AKS cluster. Use 'userDefinedRouting' for PCI clusters and 'loadBalancer' for others."
  type        = string
  default     = "loadBalancer"
}

variable "os_disk_type" {
  description = "The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed"
  type        = string
  default     = "Managed"
}

variable "maintenance_window_auto_upgrade" {
  description = "Scheduled maintenance window for the automatic upgrade of the Kubernetes control plane (API server and system components)"
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = number
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(set(object({
      end   = string
      start = string
    })))
  })
  default = null
}

variable "maintenance_window_node_os" {
  description = "Scheduled maintenance window for the automatic upgrade of worker node OS patches, including security and kernel updates"
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = number
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(set(object({
      end   = string
      start = string
    })))
  })
  default = null
}
variable "create_istio_sa" {
  description = "create Istio ServiceAccount"
  type        = bool
  default     = false
}
