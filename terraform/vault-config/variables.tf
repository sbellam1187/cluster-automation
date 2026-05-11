# Hashicorp Vault
variable "vault_host_url_nonprod" {
  description = "Vault server URL - dev (nonprod)"
  type        = string
  default     = "https://vaultazedev1.secretmgmt.aa.com/"
}

variable "vault_host_url_prod" {
  description = "Vault server URL - prod"
  type        = string
  default     = "https://vaultcdc.secretmgmt.aa.com/"
}

variable "vault_namespace" {
  description = "Vault server namespace"
  type        = string
  default     = "KaaS"
}

variable "vault_ca_cert_file_nonprod" {
  description = "Vault server CA certificate - dev (nonprod)"
  type        = string
  default     = "../../KF_TrustChain.pem"
}

variable "vault_ca_cert_file_prod" {
  description = "Vault server CA certificate - prod"
  type        = string
  default     = "../../vault_secretmgmt_aa_com.pem"
}

variable "vault_login_approle_role_id_nonprod" {
  description = "Vault Approle Role ID - dev (nonprod)"
  type        = string
  sensitive   = true
}

variable "vault_login_approle_role_id_prod" {
  description = "Vault Approle Role ID - prod"
  type        = string
  sensitive   = true
}

variable "vault_login_approle_secret_id_nonprod" {
  description = "Vault Approle Secret ID - dev (nonprod)"
  type        = string
  sensitive   = true
}

variable "vault_login_approle_secret_id_prod" {
  description = "Vault Approle Secret ID - prod"
  type        = string
  sensitive   = true
}
