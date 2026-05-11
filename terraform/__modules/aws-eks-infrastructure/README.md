# AWS EKS Infrastructure Module

Complete AWS EKS infrastructure module - VPC, subnets, IAM roles, and EKS cluster in one place.

## Features

✅ **VPC** - Configurable CIDR with Internet Gateway  
✅ **Subnets** - Auto-distributed across AZs (public + private)  
✅ **IAM Roles** - Cluster, node, and pod identity roles  
✅ **EKS Cluster** - Full-featured cluster with logging and OIDC  
✅ **Node Groups** - Multi-group support with auto-scaling  
✅ **Pod Identity** - Built-in workload IAM with defaults for VPC CNI  
✅ **Add-ons** - vpc-cni, coredns, kube-proxy, metrics-server, pod-identity-agent  

## Usage

```hcl
module "eks" {
  source = "../../__modules/aws-eks-infrastructure"

  # Cluster basics
  cluster_name    = "my-cluster"
  cluster_version = "1.29"
  
  # VPC & Networking
  vpc_name            = "my-vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  # Node Groups
  node_groups = {
    general = {
      desired_size   = 2
      min_size       = 1
      max_size       = 5
      instance_types = ["t3.medium"]
      disk_size      = 50
      capacity_type  = "ON_DEMAND"
      labels = {
        role = "general"
      }
    }
  }
  
  # Pod Identity for additional workloads
  pod_identity_associations = {
    external_dns = {
      namespace       = "kube-system"
      service_account = "external-dns"
      role_arn        = aws_iam_role.external_dns.arn
    }
  }
  
  tags = {
    Environment = "prod"
  }
}
```

## Inputs

### Cluster Configuration
- `cluster_name` - EKS cluster name (required)
- `cluster_version` - Kubernetes version (default: 1.29)

### VPC & Networking
- `vpc_name` - VPC name (required)
- `vpc_cidr` - VPC CIDR block (default: 10.0.0.0/16)
- `availability_zones` - Custom AZ list (default: auto-select 3)
- `public_subnet_cidrs` - Public subnet CIDRs (default: 3x /24)
- `private_subnet_cidrs` - Private subnet CIDRs (default: 3x /24)

### Node Groups
- `node_groups` - Map of node group configurations

### Advanced
- `eni_configs` - ENI subnet mapping for pod networking (optional)
- `platform_admin_role_arns` - IAM roles to grant cluster admin (optional)
- `pod_identity_associations` - Additional pod identity associations (optional)
- `enable_cluster_logging` - Enable control plane logging (default: true)
- `cluster_log_types` - Log types to enable (default: all)

### Tags
- `tags` - Map of tags to apply to all resources

## Outputs

### Cluster
- `cluster_id` - EKS cluster ID
- `cluster_endpoint` - Cluster endpoint URL
- `cluster_version` - Kubernetes version
- `cluster_arn` - Cluster ARN

### VPC & Networking
- `vpc_id` - VPC ID
- `vpc_cidr` - VPC CIDR block
- `internet_gateway_id` - IGW ID
- `private_subnet_ids` - Private subnet IDs list
- `public_subnet_ids` - Public subnet IDs list
- `subnet_ids` - Map of all subnet names to IDs

### IAM
- `cluster_role_arn` - Cluster role ARN
- `node_role_arns` - Node group role ARNs map
- `vpc_cni_role_arn` - VPC CNI pod identity role ARN

### Node Groups
- `node_group_ids` - Node group IDs
- `node_group_statuses` - Node group statuses

### Access
- `oidc_provider_arn` - OIDC provider ARN
- `oidc_provider_url` - OIDC provider URL

### Summary
- `cluster_summary` - Complete cluster configuration summary

## Design

This module consolidates AWS infrastructure for EKS, replacing the need to call:
- `aws-vpc-complete` (VPC only)
- `aws-subnets` (subnet management)
- `aws-iam-roles` (multiple role modules)
- `aws-eks-cluster` (cluster creation)

**Single call, complete infrastructure.**

## Module Naming

- **aws-eks-cluster** - Component module: Creates just the EKS cluster + add-ons
- **aws-eks-infrastructure** - Stack module: Complete VPC + subnets + IAM + cluster
