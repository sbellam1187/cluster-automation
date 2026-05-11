# CAST AI EKS Root Module

This directory serves as the root folder for CAST AI EKS cluster automation. It orchestrates the deployment and configuration of CAST AI resources by invoking the dedicated submodules:

- `castai-eks-cluster` – Provisions the EKS cluster and required IAM resources
- `castai-configuration` – Manages CAST AI configuration objects (scaling policies, node templates, autoscaler, etc.)

## Structure

This folder contains three subfolders, each representing a root module for a specific environment:

- `lab/`
- `nonprod/`
- `prod/`

Each environment folder contains its own Terraform configuration, variables, and backend settings as needed.

## Usage

The root modules typically calls the submodules as follows:

```hcl
module "eks_cluster" {
  source = "../../__modules/castai/castai-eks-cluster"
  # ... pass required inputs ...
}

module "castai_config" {
  source = "../../__modules/castai/castai-configuration"
  castai_cluster_id = module.eks_cluster.castai_cluster_id
  # ... pass configuration inputs ...
}
```

> For nonprod and prod, update the `source` to use a Git URL with a specific tag (see submodule READMEs for details).

## Promotion Workflow

- **Lab**: Use local paths for rapid iteration and testing.
- **Nonprod**: After successful lab validation, update the module `source` to reference the tested tag.
- **Prod**: Promote the tag from nonprod after final validation.

This workflow ensures changes are tested and controlled as they move through environments.

## References

- [castai-eks-cluster/README.md](../../__modules/castai/castai-eks-cluster/README.md)
- [castai-configuration/README.md](../../__modules/castai/castai-configuration/README.md)

See those documents for details on inputs, outputs, and release/tagging strategy.
