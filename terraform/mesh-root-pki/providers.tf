terraform {
  required_version = "1.13.5"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.6.0"
    }
  }
}

provider "vault" {
  address      = var.vault_host_url
  ca_cert_file = var.vault_ca_cert_file
  namespace    = var.vault_namespace
  auth_login {
    path      = "auth/approle/login"
    namespace = var.vault_namespace

    parameters = {
      role_id   = var.vault_login_approle_role_id
      secret_id = var.vault_login_approle_secret_id
    }
  }
}


terraform {
  backend "azurerm" {}
}
