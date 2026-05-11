
provider "vault" {
  address      = var.vault_host_url_nonprod
  ca_cert_file = var.vault_ca_cert_file_nonprod
  namespace    = var.vault_namespace
  auth_login {
    path      = "auth/approle/login"
    namespace = var.vault_namespace

    parameters = {
      role_id   = var.vault_login_approle_role_id_nonprod
      secret_id = var.vault_login_approle_secret_id_nonprod
    }
  }
}

provider "vault" {
  alias        = "prod"
  address      = var.vault_host_url_prod
  ca_cert_file = var.vault_ca_cert_file_prod
  namespace    = var.vault_namespace

  auth_login {
    path      = "auth/approle/login"
    namespace = var.vault_namespace

    parameters = {
      role_id   = var.vault_login_approle_role_id_prod
      secret_id = var.vault_login_approle_secret_id_prod
    }
  }
}
