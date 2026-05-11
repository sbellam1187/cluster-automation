# castai-eks-cluster submodule

This submodule is responsible for provisioning the CAST AI EKS cluster and its IAM resources. It is intended to be called from the
parent `castai` module (or directly from a root configuration).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| `cluster_name` | The name of the EKS cluster | `string` | n/a | yes |
| `sdlc_environment` | Cluster environment label | `string` | n/a | yes |
| `delete_nodes_on_disconnect` | Delete nodes when disconnected from CAST AI | `bool` | `true` | no |
| `vpc_id` | VPC ID for IAM resources | `string` | n/a | yes |
| `max_session_duration` | Max IAM session duration in seconds | `number` | `3600` | no |

> See the source file `variables.tf` for full comments and any additional
> context that may be present.


## Outputs

| Name | Description |
|------|-------------|
| `castai_cluster_id` | The CAST AI EKS cluster ID |
| `instance_role_arn` | ARN of IAM instance profile created for the cluster |

> Outputs are declared in `outputs.tf`.


## Usage

This submodule is normally invoked as one of two modules in the parent
`castai` module. Example (from parent):

```hcl
module "eks_cluster" {
  source = "../../../__modules/castai/castai-eks-cluster"
  cluster_name = "example"
  sdlc_environment = "nonprod"
  vpc_id = module.vpc.vpc_id
}
```

## Release & Tagging

After merging a change to this submodule, create and push a git tag:

```
v<X.Y.Z>-tf-castai-eks-cluster+pr<NNNN>
```

Use the tag when referencing the module from environment-specific
configurations (nonprod/prod). For example:

```hcl
module "eks_cluster" {
  source = "git::https://github.com/AAInternal/runway-kubernetes-cluster-automation//terraform/__modules/castai/castai-eks-cluster?ref=v1.0.0-tf-castai-eks-cluster%2Bpr6670"
  # … other inputs …
}
```

Lab / development environments should keep using a local filesystem path to
pick up un‑tagged changes immediately:

```hcl
module "eks_cluster" {
  source = "../../../__modules/castai/castai-eks-cluster"
  # …
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.30.0 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 8.17.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.30.0 |
| <a name="provider_castai"></a> [castai](#provider\_castai) | >= 8.17.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | yes |
| <a name="input_sdlc_environment"></a> [sdlc\_environment](#input\_sdlc\_environment) | Cluster environment | `string` | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC of the cluster IAM resources will created for. | `string` | yes |
| <a name="input_delete_nodes_on_disconnect"></a> [delete\_nodes\_on\_disconnect](#input\_delete\_nodes\_on\_disconnect) | Delete nodes when disconnected from CAST AI | `bool` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration (in seconds) that you want to set for the specified role. | `number` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_castai_cluster_id"></a> [castai\_cluster\_id](#output\_castai\_cluster\_id) | The CAST AI EKS cluster ID |
| <a name="output_instance_role_arn"></a> [instance\_role\_arn](#output\_instance\_role\_arn) | ARN of the instance role created for the EKS cluster |
<!-- END_TF_DOCS -->
