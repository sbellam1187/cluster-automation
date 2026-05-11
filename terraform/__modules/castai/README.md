# Terraform `castai` Module

This Terraform module encapsulates the resources required to provision and configure a
[CAST AI](https://cast.ai/) enabled EKS cluster. It is split into two logical
sub-modules:

1. **Castai EKS cluster** - Creates a Castai EKS Cluster
2. **Castai config** - Applies CAST AI specific configurations such as cluster options, workload scaling policies, node templates, and any additional CAST AI resources.

The root module that consumes this module will declare two `module` blocks:
one for `eks_cluster` and one for `config`. This separation allows you to
reuse the configuration module against either an existing cluster or a newly
created one.

## Usage

This module directory is _not_ self-contained: it delegates to two
subdirectories (`eks_cluster` and `config`) which each contain their own
Terraform configuration. As a result, you cannot point a `module` block at
`../../../__modules/castai` directly. Instead, the consuming code should declare two
separate module blocks, for example:

```hcl
module "eks_cluster" {
  source = "../../../__modules/castai/eks_cluster"
  cluster_name = "example"
  region       = "us-east-1"
  vpc_id       = module.vpc.vpc_id
  # additional eks inputs …
}

module "castai_config" {
  source = "../../../__modules/castai/config"
  cluster_name       = module.eks_cluster.cluster_name
  cluster_endpoint   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = module.eks_cluster.cluster_ca_certificate
  castai_api_key     = var.castai_api_key
  castai_project_id  = var.castai_project_id
  # configuration inputs …
}
```
> **Note:** The root module that consumes this module should set up the castai EKS
> cluster first, then pass outputs (such as `cluster_name`, `instance_role_arn `) to the configuration block.

---

## Submodule documentation

Input variables and outputs for each component live in the respective
subdirectory. See:

* [`castai-eks-cluster/README.md`](./eks_cluster/README.md) – EKS cluster provisioning
* [`castai-configuration/README.md`](./config/README.md) – CAST AI configuration objects

> For release strategy and environment-specific sourcing, consult the
> individual submodule README files (`castai-eks-cluster/README.md` and
> `castai-configuration/README.md`). Each contains detailed notes about
> tagging, lab vs nonprod/prod sourcing, and version promotion.
