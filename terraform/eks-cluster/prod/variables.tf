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
  default     = "prod"
}
variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "eks_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "ec2_subnet_ids" {
  description = "List of subnet IDs for the EC2 node groups"
  type        = list(string)
}

variable "platform_admin_role_arns" {
  description = "List of IAM role ARNs for platform admins"
  type        = list(string)
  default     = ["arn:aws:iam::045755618773:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_b6a167905d19cc9f"]
}
variable "cluster_role_arn" {
  description = "IAM role for the EKS cluster"
  type        = string
  default     = "arn:aws:iam::045755618773:role/eks-cluster-role-prod"
}
variable "node_role_arn" {
  description = "IAM role for the EKS worker nodes"
  type        = string
  default     = "arn:aws:iam::045755618773:role/ec2-eks-role-prod"
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
  type        = map(any)
  description = "Mapping from AZ name to subnet ID for pod ENIConfig"
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
# variables for rancher registration and container registry
variable "devexp_cluster_name" {
  description = "short name of the cluster"
  type        = string
  default     = ""
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
    "aa-sdlc-environment" = "prod"
  }
}
variable "vault_login_approle_role_id" {
  description = "Vault Approle Role ID"
  type        = string
  sensitive   = true
}

variable "vault_login_approle_secret_id" {
  description = "Vault Approle Secret ID"
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
