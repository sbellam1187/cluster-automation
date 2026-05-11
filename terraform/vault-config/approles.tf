resource "vault_approle_auth_backend_role" "k8s_bootstrap_read_only_prod" {
  provider                = vault.prod
  backend                 = vault_auth_backend.approle_prod.path
  role_name               = "k8s_bootstrap_read_only"
  token_policies          = ["default", "k8s_bootstrap_read_only"]
  secret_id_bound_cidrs   = []
  secret_id_num_uses      = 0
  secret_id_ttl           = 0
  token_bound_cidrs       = []
  token_explicit_max_ttl  = 0
  token_max_ttl           = 2400
  token_no_default_policy = false
  token_num_uses          = 0
  token_period            = 0
  token_ttl               = 1200
}

resource "vault_approle_auth_backend_role" "kaas_full_vault_admin_prod" {
  provider                = vault.prod
  backend                 = vault_auth_backend.approle_prod.path
  role_name               = "kaas_full_vault_admin"
  token_policies          = ["default", "kaas_full_vault_admin"]
  secret_id_bound_cidrs   = []
  secret_id_num_uses      = 0
  secret_id_ttl           = 0
  token_bound_cidrs       = []
  token_explicit_max_ttl  = 0
  token_max_ttl           = 2400
  token_no_default_policy = false
  token_num_uses          = 0
  token_period            = 0
  token_ttl               = 1200
}
resource "vault_approle_auth_backend_role" "kaas_vault_readonly_lab" {
  provider                = vault.prod
  backend                 = vault_auth_backend.approle_prod.path
  role_name               = "kaas_vault_readonly_lab"
  token_policies          = ["default", "k8s_bootstrap_read_only"]
  secret_id_bound_cidrs   = []
  secret_id_num_uses      = 0
  secret_id_ttl           = 0
  token_bound_cidrs       = []
  token_explicit_max_ttl  = 0
  token_max_ttl           = 2400
  token_no_default_policy = false
  token_num_uses          = 0
  token_period            = 0
  token_ttl               = 1200
}

resource "vault_approle_auth_backend_role" "kaas_vault_readonly_nonprod" {
  provider                = vault.prod
  backend                 = vault_auth_backend.approle_prod.path
  role_name               = "kaas_vault_readonly_nonprod"
  token_policies          = ["default", "k8s_bootstrap_read_only"]
  secret_id_bound_cidrs   = []
  secret_id_num_uses      = 0
  secret_id_ttl           = 0
  token_bound_cidrs       = []
  token_explicit_max_ttl  = 0
  token_max_ttl           = 2400
  token_no_default_policy = false
  token_num_uses          = 0
  token_period            = 0
  token_ttl               = 1200
}

resource "vault_approle_auth_backend_role" "kaas_vault_readonly_prod" {
  provider                = vault.prod
  backend                 = vault_auth_backend.approle_prod.path
  role_name               = "kaas_vault_readonly_prod"
  token_policies          = ["default", "k8s_bootstrap_read_only"]
  secret_id_bound_cidrs   = []
  secret_id_num_uses      = 0
  secret_id_ttl           = 0
  token_bound_cidrs       = []
  token_explicit_max_ttl  = 0
  token_max_ttl           = 2400
  token_no_default_policy = false
  token_num_uses          = 0
  token_period            = 0
  token_ttl               = 1200
}
