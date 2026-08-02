# EKS Subnets Terraform Module

This Terraform root module provisions AWS subnets specifically designed for Amazon EKS (Elastic Kubernetes Service) clusters. It creates multiple subnet types across availability zones to support various EKS networking requirements including public access, private compute nodes, and pod networking.

---

## Overview

The `eks-subnets` root module creates a comprehensive subnet architecture for EKS clusters, supporting:

- **Public subnets** for load balancers and NAT gateways
- **EC2 subnets** for EKS worker nodes
- **Pod subnets** for custom pod networking (CNI)
- **xENI subnets** - Kubernetes API server uses these Cross-Account ENIs to communicate with nodes deployed on the customer-managed cluster VPC subnets

The root module uses tfvars file for environment-aware configuration to create subnets across multiple availability zones.

---

## Nonprod

### VPC Details

| Name           | VPC ID         | CIDR Block     | Region        |
|----------------|----------------|---------------|---------------|
| AA_KAAS_N_EA_10.218.64.0_19_VPC| vpc-04f33088d2bf9974a   | 10.218.64.0/19  | us-east-1     |
| AA_KAAS_N_WE_10.219.64.0_19_VPC| vpc-01d736f3291515ffd  | 10.219.64.0/19  | us-west-2     |


### Subnet Details - us-east-1(N. Virginia)

| Subnet Name               | Subnet Type | CIDR Block     | Availability Zone | Purpose                      |
|---------------------------|-------------|----------------|-------------------|------------------------------|
| kaas-nonprod-us-east-1a-ec2    | Private     | 10.218.64.0/23   | us-east-1a        | Worker Nodes  |
| kaas-nonprod-us-east-1b-ec2    | Private     | 10.218.66.0/23   | us-east-1b        | Worker Nodes  |
| kaas-nonprod-us-east-1c-ec2     | Private      | 10.218.68.0/23 | us-east-1c        | Worker Nodes  |
| kaas-nonprod-us-east-1a-pods    | Private     | 100.64.0.0/18   | us-east-1a        | Pods    |
| kaas-nonprod-us-east-1b-pods    | Private     | 100.64.64.0/18   | us-east-1b       | Pods   |
| kaas-nonprod-us-east-1c-pods     | Private      | 100.64.128.0/18 | us-east-1c      | Pods  |
| kaas-nonprod-us-east-1a-xeni    | Private     | 10.218.70.0/25   | us-east-1a        | cluster administration traffic  |
| kaas-nonprod-us-east-1b-xeni    | Private     | 10.218.70.128/25   | us-east-1b       | cluster administration traffic  |
| kaas-nonprod-us-east-1c-xeni     | Private      | 10.218.71.0/25 | us-east-1c      | cluster administration traffic  |
| kaas-nonprod-us-east-1a-public    | Public     | 10.218.72.0/25   | us-east-1a        | Load Balancers  |
| kaas-nonprod-us-east-1b-public    | Public     | 10.218.72.128/25   | us-east-1b       | Load Balancers  |
| kaas-nonprod-us-east-1c-public     | Public      | 10.218.73.0/25 | us-east-1c      | Load Balancers  |
| kaas-nonprod-us-east-1a_tgw_snet    | Private     | 10.218.94.0/28   | us-east-1a        | Transit Gateway  |
| kaas-nonprod-us-east-1b_tgw_snet    | Private     | 10.218.94.16/28   | us-east-1b       | Transit Gateway  |
| kaas-nonprod-us-east-1c_tgw_snet     | Private      | 10.218.94.32/28 | us-east-1c      | Transit Gateway  |


### Subnet Details - us-west-2 (Oregon)

| Subnet Name               | Subnet Type | CIDR Block     | Availability Zone | Purpose                      |
|---------------------------|-------------|----------------|-------------------|------------------------------|
| kaas-nonprod-us-west-2a-ec2    | Private     | 10.219.64.0/23   | us-west-2a        | Worker Nodes  |
| kaas-nonprod-us-west-2b-ec2    | Private     | 10.219.66.0/23   | us-west-2b        | Worker Nodes  |
| kaas-nonprod-us-west-2c-ec2     | Private      | 10.219.68.0/23 | us-west-2c        | Worker Nodes  |
| kaas-nonprod-us-west-2a-pods    | Private     | 100.64.0.0/18   | us-west-2a        | Pods    |
| kaas-nonprod-us-west-2b-pods    | Private     | 100.64.64.0/18   | us-west-2b       | Pods   |
| kaas-nonprod-us-west-2c-pods     | Private      | 100.64.128.0/18 | us-west-2c      | Pods  |
| kaas-nonprod-us-west-2a-xeni    | Private     | 10.219.70.0/25   | us-west-2a        | cluster administration traffic  |
| kaas-nonprod-us-west-2b-xeni    | Private     | 10.219.70.128/25   | us-west-2b       | cluster administration traffic  |
| kaas-nonprod-us-west-2c-xeni     | Private      | 10.219.71.0/25 | us-west-2c      | cluster administration traffic  |
| kaas-nonprod-us-west-2a-public    | Public     | 10.219.72.0/25   | us-west-2a        | Load Balancers  |
| kaas-nonprod-us-west-2b-public    | Public     | 10.219.72.128/25   | us-west-2b       | Load Balancers  |
| kaas-nonprod-us-west-2c-public     | Public      | 10.219.73.0/25 | us-west-2c      | Load Balancers  |
| kaas-nonprod-us-west-2a_tgw_snet    | Private     | 10.219.94.0/28   | us-west-2a        | Transit Gateway  |
| kaas-nonprod-us-west-2b_tgw_snet    | Private     | 10.219.94.16/28   | us-west-2b       | Transit Gateway  |
| kaas-nonprod-us-west-2c_tgw_snet     | Private      | 10.219.94.32/28 | us-west-2c      | Transit Gateway  |

---

## Prod

### VPC Details

| Name           | VPC ID         | CIDR Block     | Region        |
|----------------|----------------|---------------|---------------|
| AA_KAAS_P_EA_10.218.160.0_19_VPC| vpc-0e297549887e3bfa4   | 10.218.160.0/19  | us-east-1     |
| AA_KAAS_P_WE_10.219.160.0_19_VPC| vpc-089c76fb40a216e11  | 10.219.160.0/19  | us-west-2     |

### Subnet Details - us-east-1(N. Virginia)

| Subnet Name               | Subnet Type | CIDR Block     | Availability Zone | Purpose                      |
|---------------------------|-------------|----------------|-------------------|------------------------------|
| kaas-prod-us-east-1a-ec2    | Private     | 10.218.160.0/23   | us-east-1a        | Worker Nodes  |
| kaas-prod-us-east-1b-ec2    | Private     | 10.218.162.0/23   | us-east-1b        | Worker Nodes  |
| kaas-prod-us-east-1c-ec2     | Private      | 10.218.164.0/23 | us-east-1c        | Worker Nodes  |
| kaas-prod-us-east-1a-pods    | Private     | 100.64.0.0/18   | us-east-1a        | Pods    |
| kaas-prod-us-east-1b-pods    | Private     | 100.64.64.0/18   | us-east-1b       | Pods   |
| kaas-prod-us-east-1c-pods     | Private      | 100.64.128.0/18 | us-east-1c      | Pods  |
| kaas-prod-us-east-1a-xeni    | Private     | 10.218.166.0/25   | us-east-1a        | cluster administration traffic  |
| kaas-prod-us-east-1b-xeni    | Private     | 10.218.166.128/25   | us-east-1b       | cluster administration traffic  |
| kaas-prod-us-east-1c-xeni     | Private      | 10.218.167.0/25 | us-east-1c      | cluster administration traffic  |
| kaas-prod-us-east-1a-public    | Public     | 10.218.168.0/25   | us-east-1a        | Load Balancers  |
| kaas-prod-us-east-1b-public    | Public     | 10.218.168.128/25   | us-east-1b       | Load Balancers  |
| kaas-prod-us-east-1c-public     | Public      | 10.218.169.0/25 | us-east-1c      | Load Balancers  |
| kaas-prod-us-east-1a_tgw_snet    | Private     | 10.218.190.0/28   | us-east-1a        | Transit Gateway  |
| kaas-prod-us-east-1b_tgw_snet    | Private     | 10.218.190.16/28   | us-east-1b       | Transit Gateway  |
| kaas-prod-us-east-1c_tgw_snet     | Private      | 10.218.190.32/28 | us-east-1c      | Transit Gateway  |

### Subnet Details - us-west-2 (Oregon)

| Subnet Name               | Subnet Type | CIDR Block     | Availability Zone | Purpose                      |
|---------------------------|-------------|----------------|-------------------|------------------------------|
| kaas-prod-us-west-2a-ec2    | Private     | 10.219.160.0/23   | us-west-2a        | Worker Nodes  |
| kaas-prod-us-west-2b-ec2    | Private     | 10.219.162.0/23   | us-west-2b        | Worker Nodes  |
| kaas-prod-us-west-2c-ec2     | Private      | 10.219.164.0/23 | us-west-2c        | Worker Nodes  |
| kaas-prod-us-west-2a-pods    | Private     | 100.64.0.0/18   | us-west-2a        | Pods    |
| kaas-prod-us-west-2b-pods    | Private     | 100.64.64.0/18   | us-west-2b       | Pods   |
| kaas-prod-us-west-2c-pods     | Private      | 100.64.128.0/18 | us-west-2c      | Pods  |
| kaas-prod-us-west-2a-xeni    | Private     | 10.219.166.0/25   | us-west-2a        | cluster administration traffic  |
| kaas-prod-us-west-2b-xeni    | Private     | 10.219.166.128/25   | us-west-2b       | cluster administration traffic  |
| kaas-prod-us-west-2c-xeni     | Private      | 10.219.167.0/25 | us-west-2c      | cluster administration traffic  |
| kaas-prod-us-west-2a-public    | Public     | 10.219.168.0/25   | us-west-2a        | Load Balancers  |
| kaas-prod-us-west-2b-public    | Public     | 10.219.168.128/25   | us-west-2b       | Load Balancers  |
| kaas-prod-us-west-2c-public     | Public      | 10.219.169.0/25 | us-west-2c      | Load Balancers  |
| kaas-prod-us-west-2a_tgw_snet    | Private     | 10.219.190.0/28   | us-west-2a        | Transit Gateway  |
| kaas-prod-us-west-2b_tgw_snet    | Private     | 10.219.190.16/28   | us-west-2b       | Transit Gateway  |
| kaas-prod-us-west-2c_tgw_snet     | Private      | 10.219.190.32/28 | us-west-2c      | Transit Gateway  |

---
