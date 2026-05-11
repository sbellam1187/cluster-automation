terraform {
  required_version = ">=0.14.11"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.42.0"
    }
  }

  # Backend remote state
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  skip_provider_registration = "true"
}

provider "azurerm" {
  alias                      = "aa-ets-hub"
  tenant_id                  = var.aa-tenant-id
  subscription_id            = var.aa-dns-subscription-id
  skip_provider_registration = true
  features {}
}

provider "azuread" {
}

provider "vault" {
  address = ""
}