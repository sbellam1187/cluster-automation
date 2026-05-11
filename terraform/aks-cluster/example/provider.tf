terraform {
  # If you update this you should also update .terraform-version in this directory.
  required_version = "~> 1.13.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.15.0"
    }

    rancher2 = {
      source  = "rancher/rancher2"
      version = "8.2.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }

    dns = {
      source  = "hashicorp/dns"
      version = "3.4.0"
    }
  }

  backend "azurerm" {
    # Configure these values via -backend-config flags or environment variables
    # Example: -backend-config="resource_group_name=my-rg" -backend-config="storage_account_name=mystg"
  }
}

# Local values for provider configuration
locals {
  host                   = var.pci_cluster && var.azuread_rbac != null ? module.aks.kube_admin_config[0].host : module.aks.kube_config[0].host
  client_certificate     = var.pci_cluster && var.azuread_rbac != null ? base64decode(module.aks.kube_admin_config[0].client_certificate) : base64decode(module.aks.kube_config[0].client_certificate)
  client_key             = var.pci_cluster && var.azuread_rbac != null ? base64decode(module.aks.kube_admin_config[0].client_key) : base64decode(module.aks.kube_config[0].client_key)
  cluster_ca_certificate = var.pci_cluster && var.azuread_rbac != null ? base64decode(module.aks.kube_admin_config[0].cluster_ca_certificate) : base64decode(module.aks.kube_config[0].cluster_ca_certificate)
}

# Provider configurations
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

# Data source for current subscription
data "azurerm_subscription" "current" {}
