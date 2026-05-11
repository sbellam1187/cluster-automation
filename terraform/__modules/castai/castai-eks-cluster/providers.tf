terraform {
  required_version = "~> 1.13"
  required_providers {
    castai = {
      source  = "castai/castai"
      version = ">= 8.17.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.30.0"
    }
  }
}
