variable "resource_group_name" {
  description = "Default resource group name that the server will be created in."
  type        = string
}

variable "secondary_rg_name" {
  description = "resource group name that the secondary replica server will be created in."
  type        = string
  default     = null
}

variable "server_name" {
  description = "Name of the server to create"
  type        = string
}

variable "sku_name" {
  description = "Specifies the SKU Name for this PostgreSQL Server. The name of the SKU, follows the tier + family + cores pattern (B:Basic, GP:General Purpose, MO:Memory Optimized _Gen5_ 1,2,4,16,32,64)"
  type        = string
}

variable "database_version" {
  description = "Specifies the version of PostgreSQL to use. Valid values are 11, 12, and 13."
  type        = string
  default     = 13
}

variable "storage_mb" {
  description = "Max storage allowed for a server. Possible values are between 32768 MB(32.77 gigabytes) and 33554432 MB(33.5TB) for the Basic SKU."
  type        = number
  default     = 32768
}

# variable "backup_retention_days" {
#   description = "Backup retention days for the server, supported values are between 7 and 35 days"
#   type        = number
#   default     = 7
# }

variable "admin_username" {
  description = "The Administrator Login for the PostgreSQL Server."
  type        = string
}


# Database variables
variable "postgresql_db_name" {
  description = "Specifies the name of the PostgreSQL Database, which needs to be a valid PostgreSQL identifier. Changing this forces a new resource to be created"
  type        = list(string)
  default     = null
}


variable "user_supplied_pw" {
  description = "Specifies an admin password for the postgresdql server "
  type        = string
  default     = null
}

variable "postgresql_db_collation" {
  description = "Specifies the Collation for the PostgreSQL Database, which needs to be a valid PostgreSQL Collation"
  type        = string
  default     = "en_US.utf8"
}

variable "postgresql_db_charset" {
  description = "Specifies the Charset for the PostgreSQL Database, which needs to be a valid PostgreSQL Charset. Changing this forces a new resource to be created"
  type        = string
  default     = "utf8"
}

# Keyvault variables
variable "keyvault_name" {
  description = "key vault to store secrets in"
  default     = null
  type        = string
}

# variable "azpostgresql_adm_secrets_name" {
#   description = "name of the secret key to store in key vault secret"
#   default     = null
#   type        = string
# }

# Firewall rule variables
variable "firewall_rules" {
  description = "The properties of each firewall rules, specified as a map of objects.  See the tests for samples of how to pass values."
  type        = any
  default     = {}
  # For example:
  # firewall_rules = {
  #   rule1 = {
  #     start_ip_address   = "172.10.10.10"
  #     end_ip_address = "172.10.10.50" #If it is not an ip range this values shoulde be equal to start ip address.
  #   }
  #   rule2 {
  #     ...
  #   }
  # }
}

# Virtual network rule variable
# variable "virtual_network_rules" {
#   description = "The properties of each network rules, specified as a map of objects.  See the tests for samples of how to pass values."
#   type        = any
#   default     = {}
#   # For example:
#   # network_rules = {
#   #   rule1 = {
#   #     subnet_id   = "Subnet id for the virtual network accessibility"
#   #   }
#   #   rule2 {
#   #     ...
#   #   }
#   # }
# }

variable "high_availability" {
  description = "This property enables or disables high availability. Note that for some SKUs high availability is not available (such as \"burstable\" tier)."
  type        = bool
  default     = true
}

variable "create_mode" {
  description = "Specify the creation mode"
  type        = string
  default     = "Default"
}

variable "replica_location" {
  description = "the location where we need to have the replication server created"
  type        = string
  default     = null
}

variable "vnet_primary_rg_name" {
  description = "resource group name where you have the primary vnet defined"
  type        = string
  default     = null
}

variable "vnet_secondary_rg_name" {
  description = "resource group name where you have the secondary vnet defined"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "virtual network for the primary instance"
  type        = string
  default     = null
}

variable "snet_name" {
  description = "subnet name for the primary instance"
  type        = string
  default     = null
}

variable "vnet_name_secondary" {
  description = "virtual network name for the replcia instance"
  type        = string
  default     = null
}

variable "snet_name_secondary" {
  description = "subnet name for the secondary instance"
  type        = string
  default     = null
}

variable "aa-dns-subscription-id" {
  description = "azure subscription id of ets-hub subscription"
  type        = string
  default     = "16e932f5-8a58-4441-9219-2b4a673b7415"
}

variable "aa-tenant-id" {
  description = "AA azure tenant ID"
  type        = string
  default     = "49793faf-eb3f-4d99-a0cf-aef7cce79dc1"
}
# variable "aadgroupname" {
#   description = "Name of AAD Group that will have admin priviledges"
#   type        = string
# }
