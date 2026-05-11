
terraform {
  # If you update this you should also update .terraform-version in this directory.
  required_version = "~> 1.7.4"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~>3.24"
    }
  }

  backend "azurerm" {
    storage_account_name = "dxrunwayp001"
    resource_group_name  = "dx-runway-core-prod"
    container_name       = "tfstate"
    key                  = "kaas-vault-namespace-management"
    subscription_id      = "e540da57-5250-45d5-9c19-74c5de18d0ab"
    tenant_id            = "49793faf-eb3f-4d99-a0cf-aef7cce79dc1"
    client_id            = "dc7c7757-e290-4284-9603-5a97c02eca03"
  }
}
