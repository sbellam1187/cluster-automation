# AWS VPC Complete Module

VPC creation module for EKS - creates only VPC and Internet Gateway.

## Features

✅ VPC with configurable CIDR  
✅ Internet Gateway for public internet access  
✅ Kubernetes-ready for subnet discovery  

## Usage

```hcl
module "vpc" {
  source = "../../__modules/aws-vpc-complete"

  vpc_name   = "my-cluster-vpc"
  vpc_cidr   = "10.0.0.0/16"
  
  tags = {
    Environment = "prod"
  }
}

# Then use aws-subnets module for subnets and routing
module "subnets" {
  source = "../../__modules/aws-subnets"
  
  vpc_id = module.vpc.vpc_id
  # ... configure subnets
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | VPC name | string | - | yes |
| vpc_cidr | VPC CIDR block | string | 10.0.0.0/16 | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

- vpc_id - VPC ID
- vpc_cidr - VPC CIDR block
- internet_gateway_id - Internet Gateway ID
