# Automating Kubernetes Version Upgrades for On-Premises Clusters in Rancher using Terraform and GitHub Actions

## Description

This document describes the process of automating Kubernetes version upgrades for on-premises clusters in Rancher using Terraform and GitHub Actions. By leveraging the "rancher2_cluster" Terraform provider, we can efficiently manage cluster upgrades and configuration changes in Rancher. To execute the Terraform code, we have created two GitHub workflow files: "terraform-plan-onprem.yaml" and "terraform-plan-apply-onprem.yaml", which are triggered through GitHub Actions.

## Terraform and Rancher2 Cluster Provider

The "rancher2_cluster" provider is a Terraform plugin that enables us to interact with the Rancher platform and manage resources such as Kubernetes clusters. With this provider, we can automate Kubernetes version upgrades and make configuration changes for on-premises clusters in Rancher.

## GitHub Workflows

To automate the execution of the Terraform code, we have created two GitHub workflow files:

**2.1. terraform-plan-onprem.yaml:**

This workflow file is responsible for running the "terraform plan" command, which generates an execution plan for the Terraform code. It shows the proposed changes to the infrastructure without applying them, allowing you to review the changes before proceeding.

**2.2. terraform-plan-apply-onprem.yaml:**

This workflow file is responsible for running the "terraform apply" command, which applies the proposed changes to the infrastructure. The changes are based on the execution plan generated in the previous step.

## Execution through GitHub Actions

GitHub Actions is a CI/CD platform that enables you to automate software workflows directly within your GitHub repository. By using GitHub Actions, we can trigger the Terraform workflows mentioned above and automate Kubernetes version upgrades for on-premises clusters in Rancher.

### Conclusion

The combination of Terraform, the "rancher2_cluster" provider, and GitHub Actions allows us to efficiently automate Kubernetes version upgrades and configuration changes for on-premises clusters in Rancher. This automation ensures that our clusters are consistently up to date and reduces the risk of human error during the upgrade process.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.4 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 3.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | 3.0.2 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | cluster\_name | `string` | yes |
| <a name="input_group_role_bindings"></a> [group\_role\_bindings](#input\_group\_role\_bindings) | List of group principal ids and role template ids | <pre>list(object({<br>    group_principal_id = string<br>    role_template_id   = string<br>    name               = string<br>  }))</pre> | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | kubernetes\_version | `string` | yes |
| <a name="input_rancher2_access_key"></a> [rancher2\_access\_key](#input\_rancher2\_access\_key) | rancher2\_access\_key | `string` | yes |
| <a name="input_rancher2_secret_key"></a> [rancher2\_secret\_key](#input\_rancher2\_secret\_key) | rancher2\_secret\_key | `string` | yes |
| <a name="input_rancher_server_url"></a> [rancher\_server\_url](#input\_rancher\_server\_url) | rancher\_server\_url | `string` | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
