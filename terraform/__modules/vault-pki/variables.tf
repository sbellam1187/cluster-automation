variable "mesh_identifier" {
  description = "The unique identifier for a given mesh"
  type        = string
}

variable "pki_mount_name" {
  description = "The name of the pki in vault"
  type        = string
}

variable "app_sdlc_environment" {
  description = "Software dev lifecycle environment E.G lab|nonprod|prod"
  type        = string
}

variable "root_issuers" {
  description = "The issuers associated with a given PKI mount. The Common Name of a given cert will be the Key in the map"

  # The default issuer defines which issuer can sign any intermediate certificates.
  # Only one issuer may be considered the default at any given time.
  # The auth policy assigned to the PKI role will only contain the default issuers
  # /sign-intermediate endpoint rendering the other issuers effectively moot
  type = map(object({
    default_issuer = bool

    # IMPORTANT: Once the cert is created the TTL can not be updated. Terraform will tell you 
    # it will update the certificate in place but it will not actually do it. 
    # bug report here https://github.com/hashicorp/terraform-provider-vault/issues/2415
    cert_ttl_days = number
  }))

  validation {
    condition     = length([for k, v in var.root_issuers : k if v.default_issuer == true]) == 1
    error_message = "You must have only 1 defaut issuer"
  }
}

variable "intermediate_signing_policy_name" {
  description = "Name of the Vault policy that allows access to the issuers /sign-intermediate endpoint"
  type        = string
}
