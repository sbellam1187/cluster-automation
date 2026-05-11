module "vault-pki" {
  source                           = "../__modules/vault-pki"
  pki_mount_name                   = "pki-${var.app_sdlc_environment}-${var.mesh_identifier}"
  app_sdlc_environment             = var.app_sdlc_environment
  root_issuers                     = var.root_issuers
  intermediate_signing_policy_name = "pki-${var.app_sdlc_environment}-${var.mesh_identifier}-policy"
  mesh_identifier                  = var.mesh_identifier
}
