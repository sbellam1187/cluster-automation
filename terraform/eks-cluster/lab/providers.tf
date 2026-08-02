terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "8.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
  }
  required_version = "1.13.5"
}

provider "aws" {
  region = var.region
}

provider "rancher2" {
  api_url   = "https://master-drke.ok8s.aa.com"
  token_key = var.rancher_token
}
provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
    command     = "aws"
  }
}
provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
      command     = "aws"
    }
  }
}
provider "vault" {
  address      = "https://vaultcdc.secretmgmt.aa.com/"
  ca_cert_file = "../../../vault_secretmgmt_aa_com.pem"
  namespace    = "automation"
  auth_login {
    path      = "auth/approle/login"
    namespace = "automation"

    parameters = {
      role_id   = var.vault_login_approle_role_id
      secret_id = var.vault_login_approle_secret_id
    }
  }
}

provider "vault" {
  alias        = "KaaS"
  address      = "https://vaultcdc.secretmgmt.aa.com/"
  ca_cert_file = "../../../vault_secretmgmt_aa_com.pem"
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
