# Create the approle for cert-manager to use and assign the policy for the /sign-intermediate endpoint
module "vault-role-and-approle" {
  source                = "../vault-approle"
  role_name             = "pki-${var.app_sdlc_environment}-${var.mesh_identifier}-approle"
  linked_policies       = [resource.vault_policy.intermediate_signing_policy.name]
  app_sdlc_environment  = var.app_sdlc_environment
  vault_approle_id_path = "${var.mesh_identifier}/ISTIO_VAULT_APPROLE_ROLE_ID"
  vault_secret_id_path  = "${var.mesh_identifier}/ISTIO_VAULT_APPROLE_SECRET_ID"
}

# Policy to allow for cert-manager to only issue signed
# intermediate certificates from the specified default issuer
resource "vault_policy" "intermediate_signing_policy" {
  name   = var.intermediate_signing_policy_name
  policy = <<EOT

# Allow cert-manager on the clusters to create intermediate certificates
path "${var.pki_mount_name}/issuer/${local.default_issuer_ref}/sign-intermediate" {
  capabilities = ["create", "update"]
}

EOT
}
