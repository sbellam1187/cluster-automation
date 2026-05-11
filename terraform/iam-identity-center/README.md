# AWS IAM Identity Center (SSO) Setup

Terraform configuration to set up AWS IAM Identity Center with multiple permission sets for EKS cluster access.

## Prerequisites

- AWS Organization enabled
- Identity Center already enabled (created automatically in most AWS accounts)
- Terraform >= 1.0
- AWS Provider >= 5.0

## Features

✅ **Administrator Access** - Full AWS permissions  
✅ **Developer Access** - Read-only + EKS permissions  
✅ **DevOps Access** - Infrastructure management (EKS, EC2, IAM, CloudWatch)  
✅ **Viewer Access** - Read-only for auditing  

## Usage

```hcl
terraform init
terraform plan
terraform apply
```

## Permission Sets

### AdministratorAccess
- Full AWS access
- Session duration: 1 hour

### DeveloperAccess
- Read-only access
- EKS full access
- Session duration: 8 hours

### DevOpsAccess
- EKS, EC2, IAM, CloudWatch full access
- Session duration: 12 hours

### ViewerAccess
- Read-only access
- Session duration: 4 hours

## Getting the SSO Role ARN

After creating permission sets, users will be assigned to accounts with a permission set. The SSO role ARN format is:

```
arn:aws:iam::ACCOUNT_ID:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_PermissionSetName_PERMISSION_SET_ID
```

### Find Your SSO Role ARNs

```bash
aws iam list-roles --query "Roles[?contains(Arn, 'AWSReservedSSO')].Arn" --output text
```

## Using with EKS Cluster

Add the SSO role ARN to your EKS cluster's `platform_admin_role_arns`:

```hcl
# In eks-cluster/example/terraform.tfvars
platform_admin_role_arns = [
  "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_abcd1234"
]
```

## Next Steps

1. Create users/groups in Identity Center
2. Assign users to permission sets
3. Assign permission sets to AWS accounts
4. Users can access AWS through the Identity Center portal
5. Use the SSO role ARN for EKS cluster access

## Outputs

- `instance_arn` - Identity Center instance ARN
- `identity_store_id` - Identity Store ID
- `permission_sets` - Map of all permission set ARNs
