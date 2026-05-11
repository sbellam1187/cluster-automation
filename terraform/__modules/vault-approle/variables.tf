variable "role_name" {
  description = "Name of the approle"
  type        = string
}

variable "linked_policies" {
  type        = list(string)
  description = "Name of the policies to be associated with this approle"
}

variable "app_sdlc_environment" {
  description = "Software dev lifecycle environment E.G lab|nonprod|prod"
  type        = string
}

variable "vault_approle_id_path" {
  type        = string
  description = "Secret path for the approle id in vault"

}

variable "vault_secret_id_path" {
  type        = string
  description = "Secret path for the approle secret id in vault"
}
