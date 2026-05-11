terraform {
  required_version = ">= 1.7.4"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.6.0"
    }

  }
}
