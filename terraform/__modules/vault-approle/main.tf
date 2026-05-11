data "vault_auth_backend" "approle" {
  path = "approle"
}

resource "vault_approle_auth_backend_role" "kaas_vault_approle" {
  backend   = data.vault_auth_backend.approle.path
  role_name = var.role_name

  token_policies = var.linked_policies

  secret_id_bound_cidrs = []
  secret_id_num_uses    = 0
  secret_id_ttl         = 0

  token_bound_cidrs       = []
  token_explicit_max_ttl  = 0
  token_max_ttl           = 2400
  token_no_default_policy = false
  token_num_uses          = 0
  token_period            = 0
  token_ttl               = 1200
}

# Generate a secret_id for the AppRole
resource "vault_approle_auth_backend_role_secret_id" "kaas_vault_approle_secret_id" {
  backend   = data.vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.kaas_vault_approle.role_name
}

# Store the secret_id in Vault KV
resource "vault_kv_secret_v2" "approle_secret_id" {
  mount = "secrets"
  name  = "bootstrap/k8s/${var.app_sdlc_environment}/${var.vault_secret_id_path}"

  custom_metadata {
    max_versions = 10
  }

  data_json = jsonencode(
    {
      value = vault_approle_auth_backend_role_secret_id.kaas_vault_approle_secret_id.secret_id
    }
  )
}

resource "vault_kv_secret_v2" "approle_id" {
  mount = "secrets"
  name  = "bootstrap/k8s/${var.app_sdlc_environment}/${var.vault_approle_id_path}"

  custom_metadata {
    max_versions = 10
  }

  data_json = jsonencode(
    {
      value = vault_approle_auth_backend_role.kaas_vault_approle.role_id
    }
  )
}
