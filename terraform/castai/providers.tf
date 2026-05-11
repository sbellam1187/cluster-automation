terraform {
  required_version = ">= 1.7.4"

  backend "azurerm" {
    # Backend configuration will be provided via -backend-config
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.15.0"
    }
    castai = {
      source  = "castai/castai"
      version = "7.73.1" ## or the version you want
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "azurerm" {
  features {}
}

provider "castai" {
  api_url   = var.castai_api_url
  api_token = var.castai_api_token
}

provider "kubernetes" {
  host                   = local.host
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}
