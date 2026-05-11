# IAM Module

This module creates IAM roles and policies required for EKS clusters and managed node groups.  
- Cluster role with `AmazonEKSClusterPolicy`
- Node role with `AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryReadOnly`, and `AmazonEKS_CNI_Policy`.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>6.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | assume role policy | `string` | yes |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | maximum session duration in seconds (e.g., 7200 for 2 hours). Required for long-running operations like EKS deployments | `number` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | list of policy ARNs to attach to the role | `list(string)` | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | name of the role | `string` | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags to apply to the role | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | role arn |
<!-- END_TF_DOCS -->
