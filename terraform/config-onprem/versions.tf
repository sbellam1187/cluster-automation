# RKE2 version
terraform {
  required_version = ">= 1.7.4"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.0.2"
    }
  }
  backend "azurerm" {}
}
