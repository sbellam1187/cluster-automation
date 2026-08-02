variable "region" {
  description = "AWS region"
  type        = string
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "app_sdlc_environment" {
  description = "SDLC environment"
  type        = string
  default     = "nonprod"
}
variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.33"
}


variable "eks_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = map(list(string))
  default = {
    us-east-1 = ["subnet-07d9bd4058dc224e3", "subnet-0a4030378a154e9ea", "subnet-053cc34bc8a390ea8"]
    us-west-2 = ["subnet-01051032e2d9abe19", "subnet-0ae3eec3ccbf2daab", "subnet-03e9f0d8467272de4"]
  }
}

variable "ec2_subnet_ids" {
  description = "Map of EC2 node group subnet IDs by subnet profile"
  type        = map(list(string))
  default = {
    us-east-1 = ["subnet-073e43aaa05775b54", "subnet-0f89a7d3ed5106eac", "subnet-00fa3988948f75d8f"]
    us-west-2 = ["subnet-04ea4f1522aa26a39", "subnet-0ec7cd02d8602ed8f", "subnet-0dbba337005a87614"]
  }
}

variable "platform_admin_role_arns" {
  description = "List of IAM role ARNs for platform admins"
  type        = list(string)
  default     = ["arn:aws:iam::285282426848:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_4090616ff50ecd8e"]
}
variable "cluster_role_arn" {
  description = "IAM role for the EKS cluster"
  type        = string
  default     = "arn:aws:iam::285282426848:role/eks-cluster-role-nonprod"
}
variable "node_role_arn" {
  description = "IAM role for the EKS worker nodes"
  type        = string
  default     = "arn:aws:iam::285282426848:role/ec2-eks-role-nonprod"
}

variable "node_groups" {
  type = map(object({
    desired_size         = optional(number, 2)
    disk_size            = optional(number, 512)
    min_size             = optional(number, 2)
    max_size             = optional(number, 10)
    instance_types       = optional(list(string), ["t3.medium"])
    labels               = optional(map(string))
    node_taints          = optional(map(string), {})
    orchestrator_version = optional(string, null)
    force_update_version = optional(bool)
  }))
  description = "Managed node group definitions"
  default     = {}
}
variable "eni_configs" {
  description = "ENI config subnet IDs per AZ, keyed by subnet profile (eastus/westus)"
  type        = map(map(string))
  default = {
    us-east-1 = {
      "us-east-1a" = "subnet-0cb12be324c70fdb6"
      "us-east-1b" = "subnet-04183a8f0e2333fc3"
      "us-east-1c" = "subnet-04f611519784bfe95"
    }
    us-west-2 = {
      "us-west-2a" = "subnet-0701b357698cffa6e"
      "us-west-2b" = "subnet-071c60af85d0af7bf"
      "us-west-2c" = "subnet-00683838a31704a16"
    }
  }
}

variable "addon_configs" {
  description = "Map of addon names to their configurations"
  type = map(object({
    version                     = string
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    configuration_values        = optional(string)
  }))

  default = {
    "vpc-cni" = {
      version              = "v1.20.4-eksbuild.2"
      configuration_values = <<-EOT
      {
        "env": {
          "ENI_CONFIG_LABEL_DEF": "topology.kubernetes.io/zone",
          "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true",
          "ENABLE_PREFIX_DELEGATION": "true"
        }
      }
      EOT
    }
    "metrics-server" = {
      version              = "v0.8.1-eksbuild.6"
      configuration_values = <<-EOT
      {
        "nodeSelector": {
          "agentpool": "gen02"
        },
        "tolerations": [
          {
            "operator": "Exists",
            "effect": "NoSchedule"
          },
          {
            "operator": "Exists",
            "effect": "NoExecute"
          }
        ]
      }
      EOT
    }
    "eks-pod-identity-agent" = {
      version = "v1.3.10-eksbuild.3"
    }
    "aws-mountpoint-s3-csi-driver" = {
      version              = "v2.5.0-eksbuild.1"
      configuration_values = <<-EOT
      {
        "controller": {
          "nodeSelector": {
            "agentpool": "gen02"
          },
          "tolerations": [
            {
              "operator": "Exists",
              "effect": "NoSchedule"
            },
            {
              "operator": "Exists",
              "effect": "NoExecute"
            }
          ]
        }
      }
      EOT
    }
    "kube-proxy" = {
      version = "v1.34.6-eksbuild.2"
    }
    "coredns" = {
      version              = "v1.12.4-eksbuild.10"
      configuration_values = <<-EOT
      {
        "nodeSelector": {
          "agentpool": "gen02"
        },
        "tolerations": [
          {
            "operator": "Exists",
            "effect": "NoSchedule"
          },
          {
            "operator": "Exists",
            "effect": "NoExecute"
          }
        ]
      }
      EOT
    }
  }
}

variable "enable_rancher_registration" {
  description = "flag to enable/disable rancher registration"
  type        = bool
  default     = true
}
variable "allowed_aad_groups" {
  description = "allowed_aad_groups"
  type        = string
  default     = null
}

variable "runway_status" {
  description = "Status of the cluster for Runway to identify (active/inactive)"
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "inactive"], var.runway_status)
    error_message = "runway_status must be either \"active\" or \"inactive\"."
  }
}

# variables for rancher registration and container registry
variable "devexp_cluster_name" {
  description = "short name of the cluster"
  type        = string
  default     = ""
}

variable "container_registry_update_container_tag" {
  description = "container tag to use for updating images in the container registry"
  type        = string
  default     = "v4.1.0"
}
variable "registry_username" {
  description = "registry username"
  type        = string
}
variable "registry_password" {
  description = "registry password"
  type        = string
  sensitive   = true
}
variable "rancher_token" {
  description = "token to connect to rancher"
  type        = string
  sensitive   = true
}
variable "tags" {
  description = "A map of tags to assign to the EKS cluster"
  type        = map(string)
  default = {
    "aa-app-shortname"    = "KaaS",
    "aa-sdlc-environment" = "nonprod"
  }
}
variable "vault_login_approle_role_id" {
  description = "Vault Approle Role ID for automation namespace login"
  type        = string
  sensitive   = true
}

variable "vault_login_approle_secret_id" {
  description = "Vault Approle Secret ID for automation namespace login"
  type        = string
  sensitive   = true
}

variable "vault_kaas_login_approle_role_id" {
  description = "Vault Approle Role ID for KaaS namespace login"
  type        = string
  sensitive   = true
}

variable "vault_kaas_login_approle_secret_id" {
  description = "Vault Approle Secret ID for KaaS namespace login"
  type        = string
  sensitive   = true
}
