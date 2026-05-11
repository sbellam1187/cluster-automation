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
| test_N_EA_10.218.64.0_19_VPC| vpc-04f33088d2bf9974a   | 10.218.64.0/19  | us-east-1     |



### Subnet Details - us-east-1(N. Virginia)

| Subnet Name               | Subnet Type | CIDR Block     | Availability Zone | Purpose                      |
|---------------------------|-------------|----------------|-------------------|------------------------------|
| test-dev-us-east-1a-ec2    | Private     | 10.218.64.0/23   | us-east-1a        | Worker Nodes  |
| test-dev-us-east-1b-ec2    | Private     | 10.218.66.0/23   | us-east-1b        | Worker Nodes  |
| test-dev-us-east-1c-ec2     | Private      | 10.218.68.0/23 | us-east-1c        | Worker Nodes  |
| test-dev-us-east-1a-pods    | Private     | 100.64.0.0/18   | us-east-1a        | Pods    |
| test-dev-us-east-1b-pods    | Private     | 100.64.64.0/18   | us-east-1b       | Pods   |
| test-dev-us-east-1c-pods     | Private      | 100.64.128.0/18 | us-east-1c      | Pods  |
| test-dev-us-east-1a-xeni    | Private     | 10.218.70.0/25   | us-east-1a        | cluster administration traffic  |
| test-dev-us-east-1b-xeni    | Private     | 10.218.70.128/25   | us-east-1b       | cluster administration traffic  |
| test-dev-us-east-1c-xeni     | Private      | 10.218.71.0/25 | us-east-1c      | cluster administration traffic  |
| test-dev-us-east-1a-public    | Public     | 10.218.72.0/25   | us-east-1a        | Load Balancers  |
| test-dev-us-east-1b-public    | Public     | 10.218.72.128/25   | us-east-1b       | Load Balancers  |
| test-dev-us-east-1c-public     | Public      | 10.218.73.0/25 | us-east-1c      | Load Balancers  |
| test-dev-us-east-1a_tgw_snet    | Private     | 10.218.94.0/28   | us-east-1a        | Transit Gateway  |
| test-dev-us-east-1b_tgw_snet    | Private     | 10.218.94.16/28   | us-east-1b       | Transit Gateway  |
| test-dev-us-east-1c_tgw_snet     | Private      | 10.218.94.32/28 | us-east-1c      | Transit Gateway  |
