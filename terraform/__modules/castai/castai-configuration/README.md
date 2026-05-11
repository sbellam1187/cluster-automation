# castai-configuration submodule

This submodule manages CAST AI configuration objects such as workload scaling
policies, node configurations/templates, autoscaler settings, and rebalancing
schedules. It requires an existing CAST AI cluster (identified by its ID) and
so is normally applied after the `castai-eks-cluster` module.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| `castai_cluster_id` | CAST AI cluster ID | `string` | n/a | yes |
| `castai_workload_scaling_policies` | Map of workload scaling policies | `any` | `{}` | no |
| `scaling_policy_order` | Ordered list of policy keys | `list(string)` | `[]` | no |
| `vpc_id` | VPC for cluster IAM resources | `string` | `null` | no |
| `aks_cluster_name` | AKS cluster name (optional) | `string` | `null` | no |
| `aks_resource_group_name` | AKS resource group name | `string` | `null` | no |
| `eks_cluster_name` | EKS cluster name (optional) | `string` | `null` | no |
| `castai_node_autoscale_enable` | Enable CastAI node autoscaling | `bool` | `false` | no |
| `castai_autoscaler_settings` | CastAI autoscaler settings map | `any` | `{}` | no |
| `castai_node_configurations` | Map of node configurations | `any` | `{}` | no |
| `castai_default_node_configuration_name` | Default configuration name | `string` | `"aa_castai_node_conf_default"` | no |
| `castai_node_templates` | Map of node templates | `any` | `{}` | no |
| `castai_rebalancing_schedule` | Map of rebalancing schedules | `any` | `{}` | no |
| `instance_profile_arn` | IAM instance profile ARN | `string` | `null` | no |

> Refer to `variables.tf` for extended comments and details.


## Outputs

This submodule doesn’t expose any outputs. All results are managed through the
CAST AI API and are represented in the Terraform state.


## Usage

Invoked from the parent module after the cluster exists. Pass the cluster ID and
any desired configuration maps:

```hcl
module "castai_config" {
  source = "../../../__modules/castai/castai-configuration"
  castai_cluster_id = module.eks_cluster.castai_cluster_id
  castai_workload_scaling_policies = var.scaling_policies
  castai_node_autoscale_enable = true
  # … other configuration inputs …
}
```
## Release & Tagging

Tag changes using the pattern:

```
v<X.Y.Z>-tf-castai-configuration+pr<NNNN>
```

Push the tag and use it in non‑lab Terraform configurations. For example:

```hcl
module "castai_config" {
  source = "git::https://github.com/AAInternal/runway-kubernetes-cluster-automation//terraform/__modules/castai/castai-configuration?ref=v1.0.0-tf-castai-configuration%2Bpr6680"
  # … other inputs …
}
```

Lab modules should continue to reference the local path for rapid iteration:

```hcl
module "castai_config" {
  source = "../../../__modules/castai/castai-configuration"
  # …
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.30.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.59.0 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 8.17.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.30.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.59.0 |
| <a name="provider_castai"></a> [castai](#provider\_castai) | >= 8.17.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_castai_cluster_id"></a> [castai\_cluster\_id](#input\_castai\_cluster\_id) | CAST AI cluster ID | `string` | yes |
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | k8s clusters name | `string` | no |
| <a name="input_aks_resource_group_name"></a> [aks\_resource\_group\_name](#input\_aks\_resource\_group\_name) | aks cluster resource group name | `string` | no |
| <a name="input_castai_autoscaler_settings"></a> [castai\_autoscaler\_settings](#input\_castai\_autoscaler\_settings) | Settings for CastAI autoscaler | `any` | no |
| <a name="input_castai_default_node_configuration_name"></a> [castai\_default\_node\_configuration\_name](#input\_castai\_default\_node\_configuration\_name) | Name of the default node configuration | `string` | no |
| <a name="input_castai_node_autoscale_enable"></a> [castai\_node\_autoscale\_enable](#input\_castai\_node\_autoscale\_enable) | Variable to specify the condition to enable CAST AI node autoscaling | `bool` | no |
| <a name="input_castai_node_configurations"></a> [castai\_node\_configurations](#input\_castai\_node\_configurations) | Map of node configurations to create | `any` | no |
| <a name="input_castai_node_templates"></a> [castai\_node\_templates](#input\_castai\_node\_templates) | Map of node templates to create | `any` | no |
| <a name="input_castai_rebalancing_schedule"></a> [castai\_rebalancing\_schedule](#input\_castai\_rebalancing\_schedule) | Map of CastAI rebalancing schedules to create | `any` | no |
| <a name="input_castai_workload_scaling_policies"></a> [castai\_workload\_scaling\_policies](#input\_castai\_workload\_scaling\_policies) | Map of workload scaling policies configuration | `any` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | EKS cluster name | `string` | no |
| <a name="input_instance_profile_arn"></a> [instance\_profile\_arn](#input\_instance\_profile\_arn) | instance profile role arn | `string` | no |
| <a name="input_scaling_policy_order"></a> [scaling\_policy\_order](#input\_scaling\_policy\_order) | List of policy keys in desired order (keys from castai\_workload\_scaling\_policies map). If empty, uses natural order. | `list(string)` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC of the cluster IAM resources will created for. | `string` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
