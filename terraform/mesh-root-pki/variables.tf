variable "mesh_identifier" {
  description = "The unique identifier for a given mesh"
  type        = string
}

variable "app_sdlc_environment" {
  description = "Software dev lifecycle environment E.G lab|nonprod|prod"
  type        = string
}

variable "root_issuers" {
  description = "The issuers associated with a given PKI mount. The Common Name of a given cert will be the Key in the map"
  type = map(object({
    default_issuer = bool
    cert_ttl_days  = number
  }))

  validation {
    condition     = length([for k, v in var.root_issuers : k if v.default_issuer == true]) == 1
    error_message = "You must have exactly one defaut issuer"
  }
}

variable "vault_host_url" {
  description = "Vault server URL"
  type        = string
  default     = "https://vaultcdc.secretmgmt.aa.com/"
}

variable "vault_namespace" {
  description = "Vault server namespace"
  type        = string
  default     = "KaaS"
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
