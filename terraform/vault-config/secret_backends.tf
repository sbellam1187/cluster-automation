# prod

resource "vault_kv_secret_backend_v2" "secrets_prod" {
  provider = vault.prod
  mount    = "secrets"
}
