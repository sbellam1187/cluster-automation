locals {
  host                   = var.pci_cluster && var.azuread_rbac != null ? azurerm_kubernetes_cluster.runway_ok8.kube_admin_config[0].host : azurerm_kubernetes_cluster.runway_ok8.kube_config[0].host
  client_certificate     = var.pci_cluster && var.azuread_rbac != null ? base64decode(azurerm_kubernetes_cluster.runway_ok8.kube_admin_config[0].client_certificate) : base64decode(azurerm_kubernetes_cluster.runway_ok8.kube_config[0].client_certificate)
  client_key             = var.pci_cluster && var.azuread_rbac != null ? base64decode(azurerm_kubernetes_cluster.runway_ok8.kube_admin_config[0].client_key) : base64decode(azurerm_kubernetes_cluster.runway_ok8.kube_config[0].client_key)
  cluster_ca_certificate = var.pci_cluster && var.azuread_rbac != null ? base64decode(azurerm_kubernetes_cluster.runway_ok8.kube_admin_config[0].cluster_ca_certificate) : base64decode(azurerm_kubernetes_cluster.runway_ok8.kube_config[0].cluster_ca_certificate)
}

provider "azuread" {
  tenant_id = data.azurerm_subscription.current.tenant_id
}

provider "azurerm" {
  features {}
}

provider "rancher2" {
  api_url   = var.rancher_url[var.app_sdlc_environment]
  token_key = var.rancher_token
}

provider "kubernetes" {
  host                   = local.host
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
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

provider "vault" {
  alias        = "KaaS"
  address      = var.vault_host_url
  ca_cert_file = var.vault_ca_cert_file
  namespace    = "KaaS"
  auth_login {
    path      = "auth/approle/login"
    namespace = "KaaS"

    parameters = {
      role_id   = var.vault_kaas_login_approle_role_id
      secret_id = var.vault_kaas_login_approle_secret_id
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = local.host
    client_certificate     = local.client_certificate
    client_key             = local.client_key
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}