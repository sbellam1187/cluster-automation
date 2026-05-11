terraform {
  required_version = ">= 1.7.4"

  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~>8.2"
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
