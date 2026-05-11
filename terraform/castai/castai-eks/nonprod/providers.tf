terraform {
  required_version = "1.13.5"

  required_providers {
    castai = {
      source  = "castai/castai"
      version = "8.17.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.59.0"
    }
  }
}



provider "castai" {
  api_url   = "https://api.cast.ai"
  api_token = var.castai_api_token
}
provider "aws" {
  region = var.region
}
provider "azurerm" {
  features {}
}
