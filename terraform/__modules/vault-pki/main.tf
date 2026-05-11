locals {
  # Find the currently configured default issuer, only one issuer may be a default at a time so we can safely
  # assume there is only a single entry in the filtered list
  default_issuer_name = "${[for k, v in var.root_issuers : k if v.default_issuer == true][0]}-issuer"

  # Find the issuer ref for a given default issuer by comparing the issuer name in the list of issuers to the configured default
  # there should only be one so we can safely grab out the index zero
  default_issuer_ref = [for k, v in vault_pki_secret_backend_issuer.issuers : v.issuer_ref if v.issuer_name == local.default_issuer_name][0]

  seconds_in_minutes = 60
  seconds_in_hours   = local.seconds_in_minutes * 60
  seconds_in_days    = local.seconds_in_hours * 24
}

# WARNING: ==================================
# Some of the resources have the lifecycle hook "prevent_destroy" on them
# This is needed becuase the destruction of those resources leads to permanent loss
# of the root certificate signing key. 
# Due to the severity of this action destruction of these resources is not allowed under any circumstances"
# --
# After a root rotation the clusters will not have the ability to generate intermediate certificates from a given root 
# due to the fact the associated policy only allows access to the /sign-intermediate endpoint of the configured DEFAULT issuer.
# --
# If for some reason there is a need to deprecate and remove a given issuer, certificates or mount. It should be done manually or outside of a terraform apply
# with terraform state update commands run to notify terraform of this action. 
# ==================================


resource "vault_mount" "pki" {
  path        = var.pki_mount_name
  type        = "pki"
  description = "Certificate CA for mesh '${var.mesh_identifier}' in '${var.app_sdlc_environment}' environment"

  # This value must be set for vault to respect an individual root certificates 
  # requested ttl value. We hardcode it to ten years here as the largest possible cert
  # we can provision
  max_lease_ttl_seconds = local.seconds_in_days * 364 * 10

  lifecycle {
    prevent_destroy = true
  }
}

# Loop over the configured root issuers creating an issuer and an accompanying root certificate
resource "vault_pki_secret_backend_issuer" "issuers" {
  for_each    = var.root_issuers
  backend     = vault_pki_secret_backend_root_cert.root_certificates[each.key].backend
  issuer_ref  = vault_pki_secret_backend_root_cert.root_certificates[each.key].issuer_id
  issuer_name = "${each.key}-issuer"

  # https://developer.hashicorp.com/vault/api-docs/secret/pki#leaf_not_after_behavior
  leaf_not_after_behavior = "err"

  lifecycle {
    prevent_destroy = true
  }
}

# Generate the Root Certificate for an issuer to be used by downstream clusters as
# an issuer does not create an associated certificate by default
resource "vault_pki_secret_backend_root_cert" "root_certificates" {
  for_each           = var.root_issuers
  backend            = vault_mount.pki.path
  type               = "internal"
  common_name        = "${var.pki_mount_name}-${each.key}"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"

  # Some future proofing, this might be a bit overkill
  key_bits = 4096

  # We are not doing hostname validations with these certificates 
  # so we should exclude the CommonName from the Subject Alt Names section
  # https://developer.hashicorp.com/vault/api-docs/secret/pki#exclude_cn_from_sans
  exclude_cn_from_sans = true

  # Set the root certificates ttl per issuer
  # Prod should be long lived, nonprods should be much shorter
  ttl = each.value.cert_ttl_days * local.seconds_in_days

  lifecycle {
    prevent_destroy = true
  }
}


# Configure the default issuer so that 'default-issuer' shows up as the tag in the vault ui PKI issuers tab
resource "vault_pki_secret_backend_config_issuers" "config" {
  backend = vault_mount.pki.path
  default = local.default_issuer_ref

  # We hardcode the default in the tfvars so we do not want vault to auto increment it
  default_follows_latest_issuer = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_kv_secret_v2" "secret_sign_intermediate_path" {
  mount = "secrets"
  name  = "bootstrap/k8s/${var.app_sdlc_environment}/${var.mesh_identifier}/ISTIO_VAULT_PKI_SIGN_INTERMEDIATE_PATH"

  custom_metadata {
    max_versions = 10
  }

  data_json = jsonencode(
    {
      value = "${var.pki_mount_name}/issuer/${local.default_issuer_ref}/sign-intermediate"
    }
  )

  depends_on = [vault_pki_secret_backend_issuer.issuers]

  # NOTE: We are explicitly NOT adding the prevent_destroy lifecycle hook to the secret path
  # This is because if this secret path is destroyed it DOES NOT irrevocably destroy the root signing key
  # lifecycle {
  #   prevent_destroy = true
  # }
}
