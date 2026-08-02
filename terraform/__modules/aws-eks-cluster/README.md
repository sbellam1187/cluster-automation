# AWS EKS Cluster Terraform Module

This module provisions AWS EKS cluster, including core infrastructure and operational components. It is designed for clarity and maintainability, with each major component defined in a separate file. The module is intended to be called by a root module (`terraform/eks-cluster/<env>`), and expects key inputs such as VPC ID, subnet IDs, and IAM role ARNs.

---

## Features

- **EKS Cluster**: Provisions the EKS control plane in an existing VPC and subnets.
- **Add-ons**: This module explicitly manages all add-ons via `aws_eks_addon` resources with configurable, pinned versions. Managed add-ons include: VPC CNI, CoreDNS, kube-proxy (core), plus Metrics Server, EKS Pod Identity Agent, and S3 CSI Driver. Add-on versions must be reviewed and updated explicitly as part of the cluster upgrade process; they are not automatically advanced by the module.
- **Access Entry**: Manages EKS access entries for IAM roles, enabling fine-grained access control. Eg: K8s roles.
- **Compute Node Group**: Creates managed node groups for cluster compute capacity, supporting scaling and multiple instance types.
- **ENIConfig**: Deploys ENIConfig custom resources for enabling pods to use secondary cidr()

---

## Add-on Version Management

**Critical Note**: EKS clusters with `bootstrap_self_managed_addons = true` will install core add-ons (VPC CNI, CoreDNS, kube-proxy) but **will NOT upgrade their versions** when the cluster is upgraded. This creates a security risk where clusters may run outdated add-on versions with known vulnerabilities.

**Solution**: This module explicitly manages all add-ons via `aws_eks_addon` resources with:
- Manual version control via configurable variables for precise version management
- Conflict resolution settings (`OVERWRITE`) for seamless updates
- Explicit version pinning to ensure consistent deployments across environments

---

## File Structure & Component Purpose

- **cluster.tf**  
  Provisions the EKS cluster resource.  
  Inputs: VPC ID, subnet IDs, IAM role ARN, cluster version, etc.  
  Outputs: Cluster endpoint,Cluster ID, CA certificate, Security group ID,Node group ID and Cluster OIDC url.

- **addons.tf**  
  Installs and configures EKS add-ons using the `aws_eks_addon` resource. Uses manual version specification via variables for precise control:
  - **Core EKS add-ons**: VPC CNI, CoreDNS, kube-proxy (require explicit management for version upgrades)
  - **Additional add-ons**: Metrics Server, EKS Pod Identity Agent, S3 CSI Driver
  Each addon version is specified through variables (e.g., `var.coredns_version`, `var.kube_proxy_version`) with `OVERWRITE` conflict resolution for seamless updates.

- **access_entry.tf**  
  Manages EKS access entries (`aws_eks_access_entry`) for specified IAM roles.  
  Ensures that platform administrators and other roles have the required access.

- **nodegroup.tf**  
  Provisions one or more managed node groups (`aws_eks_node_group`).  
  Inputs: Node group name, subnet IDs, node IAM role ARN, scaling config, instance types.

- **eniconfig.tf**  
  Deploys ENIConfig custom resources using the Helm provider.  
  Maps subnets and cluster security groups to availability zones for pods custom cidr networking.
  **Note:** ENIConfig CRD must be present in the cluster, which is installed by the VPC CNI add-on.

- **variables.tf**  
  Declares all input variables required by the module, including VPC/subnet IDs, IAM role ARNs, node group settings, add-on versions, and ENIConfig mappings.

- **outputs.tf**  
  Exposes key outputs such as cluster endpoint, CA certificate, node group details, and ENIConfig status for use by the root module.

---

## Dependency Order

The module enforces a strict dependency order:
IAM Roles (external) → EKS Cluster → Add-ons → Access Entry → ENIConfig → Compute Node Group

1. **EKS Cluster**  
   The control plane is created first, as all other resources depend on its existence. Cluster resource depends on IAM Roles which are created before the cluster creation using separate pipeline.

2. **Add-ons**  
   Add-ons are installed only after the cluster is available.

3. **Access Entry**  
   Access entries are created after the cluster, ensuring IAM roles can interact with the cluster.

4. **ENIConfig**  
   ENIConfig resources are deployed after the cluster and VPC CNI plugin, ENIConfig CRD comes from the VPC CNI plugin.

5. **Compute Node Group**  
   Node groups are provisioned after the cluster,addons, ENIConfig and required IAM roles are available.
   This will make sure when workloads are deployed , the pods take IPs from configured secondary cidr from ENIConfig.

This order is enforced using `depends_on` attributes and by referencing outputs from earlier resources in later ones.

---

## Usage

This module is intended to be called by a root module (`terraform/eks-cluster/<env>`). Example usage:

```hcl
module "eks_cluster" {
  source              = "./__modules/aws-eks-cluster"
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  cluster_role_arn    = var.cluster_role_arn
  node_role_arn       = var.node_role_arn
  addons_config       = var.addons_config
  access_roles        = var.access_roles
  node_groups         = var.node_groups
  eni_configs         = var.eni_configs
  # ...other variables...
}
```

---

## Best Practices

- **Separation of Concerns**: Each component is defined in a separate file for clarity and maintainability.
- **Explicit Dependencies**: Resource creation order is enforced using `depends_on` and output references.
- **Modular Inputs**: All configuration is passed via variables, allowing for flexible and reusable deployments.
- **Secure IAM**: IAM roles and access entries are managed as code for auditability and least privilege.
- **Scalable Compute**: Node groups support scaling and multiple instance types.
- **Advanced Networking**: ENIConfig resources enable fine-grained control over pod networking.

---
# AWS EKS Cluster Terraform Module

This module provisions a complete AWS EKS cluster, including core infrastructure and operational components. It is designed for clarity and maintainability, with each major component defined in a separate file. The module is intended to be called by a root module (`terraform/eks-cluster`), and expects key inputs such as VPC ID, subnet IDs, and IAM role ARNs.

---

## Features

- **EKS Cluster**: Provisions the EKS control plane in an existing VPC and subnets.
- **Add-ons**: This module manages EKS add-ons using `aws_eks_addon` resources to ensure version consistency and security patch deployment. Managed add-ons: VPC CNI, CoreDNS, kube-proxy, Metrics Server, EKS Pod Identity Agent, S3 CSI Driver.
- **Access Entry**: Manages EKS access entries for IAM roles, enabling fine-grained access control.
- **Compute Node Group**: Creates managed node groups for cluster compute capacity, supporting scaling and multiple instance types.
- **ENIConfig**: Deploys ENIConfig custom resources for advanced networking, mapping subnets and security groups to availability zones.

---

## File Structure & Component Purpose

- **cluster.tf**  
  Provisions the EKS cluster resource.  
  Inputs: VPC ID, subnet IDs, IAM role ARN, cluster version, etc.  
  Outputs: Cluster endpoint, CA certificate, security group ID.

- **addons.tf**  
  Installs and configures EKS add-ons using the `aws_eks_addon` resource.  
  Supports version pinning and custom configuration for each add-on.

- **access_entry.tf**  
  Manages EKS access entries (`aws_eks_access_entry`) for specified IAM roles.  
  Ensures that platform administrators and other roles have the required access.

- **nodegroup.tf**  
  Provisions one or more managed node groups (`aws_eks_node_group`).  
  Inputs: Node group name, subnet IDs, node IAM role ARN, scaling config, instance types.

- **eniconfig.tf**  
  Deploys ENIConfig custom resources using the Kubernetes provider or Helm.  
  Maps subnets and security groups to availability zones for advanced networking.

- **variables.tf**  
  Declares all input variables required by the module, including VPC/subnet IDs, IAM role ARNs, node group settings, add-on versions, and ENIConfig mappings.

- **outputs.tf**  
  Exposes key outputs such as cluster endpoint, CA certificate, node group details, and ENIConfig status for use by the root module.

---

## Dependency Order

The module enforces a strict dependency order to ensure reliable provisioning:

1. **EKS Cluster**  
   The control plane is created first, as all other resources depend on its existence.

2. **Add-ons**  
   Add-ons are installed only after the cluster is available, using explicit `depends_on` where necessary.

3. **Access Entry**  
   Access entries are created after the cluster, ensuring IAM roles can interact with the cluster.

4. **Compute Node Group**  
   Node groups are provisioned after the cluster and required IAM roles are available.

5. **ENIConfig**  
   ENIConfig resources are deployed after the cluster and node groups, using the Kubernetes provider configured with cluster outputs.

This order is enforced using `depends_on` attributes and by referencing outputs from earlier resources in later ones.

---

## Usage

This module is intended to be called by a root module. Example usage:

```hcl
module "eks_cluster" {
  source              = "./__modules/aws-eks-cluster"
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  cluster_role_arn    = var.cluster_role_arn
  node_role_arn       = var.node_role_arn
  addons_config       = var.addons_config
  access_roles        = var.access_roles
  node_groups         = var.node_groups
  eni_configs         = var.eni_configs
  # ...other variables...
}
```

---

## Outputs

- `cluster_endpoint`: The API endpoint for the EKS cluster.
- `cluster_ca_certificate`: The base64-encoded CA certificate for the cluster.
- `cluster_security_group_id`: The security group ID for the cluster control plane.
- `nodegroup_details`: Information about the created node groups.
- `eniconfig_status`: Status and details of ENIConfig resources.

---

## Best Practices

- **Separation of Concerns**: Each component is defined in a separate file for clarity and maintainability.
- **Explicit Dependencies**: Resource creation order is enforced using `depends_on` and output references.
- **Modular Inputs**: All configuration is passed via variables, allowing for flexible and reusable deployments.
- **Secure IAM**: IAM roles and access entries are managed as code for auditability and least privilege.
- **Scalable Compute**: Node groups support scaling and multiple instance types.
- **Advanced Networking**: ENIConfig resources enable fine-grained control over pod networking.

---

## Requirements

- Terraform 1.13 or newer
- AWS provider (version ~> 6.5.0)
- Kubernetes provider (for ENIConfig resources)
- Existing VPC and subnets
- IAM roles for cluster and nodes

---
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~>2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>6.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~>2.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_addon_configs"></a> [addon\_configs](#input\_addon\_configs) | Map of addon names to their configurations | <pre>map(object({<br/>    version                     = string<br/>    resolve_conflicts_on_create = optional(string, "OVERWRITE")<br/>    resolve_conflicts_on_update = optional(string, "OVERWRITE")<br/>    configuration_values        = optional(string)<br/>  }))</pre> | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | yes |
| <a name="input_cluster_role_arn"></a> [cluster\_role\_arn](#input\_cluster\_role\_arn) | ARN of the IAM role for the EKS cluster | `string` | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Version of the EKS cluster | `string` | yes |
| <a name="input_ec2_subnet_ids"></a> [ec2\_subnet\_ids](#input\_ec2\_subnet\_ids) | List of subnet IDs for the node groups | `list(string)` | yes |
| <a name="input_eni_configs"></a> [eni\_configs](#input\_eni\_configs) | Map of AZ to ENIConfig manifest spec | `map(any)` | yes |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Managed node group definitions | <pre>map(object({<br/>    desired_size         = number<br/>    min_size             = number<br/>    max_size             = number<br/>    instance_types       = list(string)<br/>    labels               = optional(map(string), {})<br/>    node_taints          = optional(map(string), {})<br/>    capacity_type        = optional(string, "ON_DEMAND")<br/>    disk_size            = optional(number, 512)<br/>    orchestrator_version = optional(string, null)<br/>    force_update_version = optional(bool)<br/>  }))</pre> | yes |
| <a name="input_node_role_arn"></a> [node\_role\_arn](#input\_node\_role\_arn) | ARN of the IAM role for the EKS node group | `string` | yes |
| <a name="input_platform_admin_role_arns"></a> [platform\_admin\_role\_arns](#input\_platform\_admin\_role\_arns) | List of ARNs for IAM roles to be granted platform admin access to the EKS cluster | `list(string)` | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the EKS cluster | `list(string)` | yes |
| <a name="input_pod_identity_associations"></a> [pod\_identity\_associations](#input\_pod\_identity\_associations) | Map of pod identity associations to create | <pre>map(object({<br/>    namespace       = string<br/>    service_account = string<br/>    role_arn        = string<br/>  }))</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the EKS cluster | `map(string)` | no |
| <a name="input_upgrade_policy"></a> [upgrade\_policy](#input\_upgrade\_policy) | Upgrade policy for the EKS cluster | `string` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority"></a> [cluster\_certificate\_authority](#output\_cluster\_certificate\_authority) | cluster certificate authority |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | cluster endpoint |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | cluster name |
| <a name="output_cluster_oidc_issuer"></a> [cluster\_oidc\_issuer](#output\_cluster\_oidc\_issuer) | cluster OIDC issuer |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | cluster security group ID |
| <a name="output_nodegroup_ids"></a> [nodegroup\_ids](#output\_nodegroup\_ids) | EKS node group IDs |
<!-- END_TF_DOCS -->
