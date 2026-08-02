# AWS IAM Roles and Policies Created

This document summarizes IAM resources created by `terraform/aws-iam/main.tf`.

> [!IMPORTANT]
> AWS Identity and Access Management (IAM) resources are globally scoped, meaning users, groups, roles, and policies are created once and automatically available across all AWS Regions.
> IAM identities and policies are not tied to a specific region.

## Note

> [!NOTE]
> - IAM roles are shared between clusters.
> - `<env>` is `nonprod` or `prod` based on the target AWS account.

## Roles

| Role Name | Trusted Principal | Description |
| --- | --- | --- |
| `githubActions-deploy-role-<env>` | GitHub OIDC provider (`var.github_arn`) | Deployment role for GitHub Actions using OIDC with 2-hour session duration for long-running EKS operations; currently attached to `AdministratorAccess`. |
| `eks-cluster-role-<env>` | `eks.amazonaws.com` | EKS control plane role with AWS managed EKS cluster/service permissions. |
| `ec2-eks-role-<env>` | `ec2.amazonaws.com` |  EC2 node role with worker/CNI/ECR/SSM managed policies. |
| `containerRegistry-tokens-podIdentity-role-<env>` | `pods.eks.amazonaws.com` | Pod identity role intended for container registry token workflows; policies come from `var.pod_policy_arns`. |
| `velero-s3-podIdentity-role-<env>` | `pods.eks.amazonaws.com` | Velero pod identity role using `velero_s3_policy`. |
| `ack-eks-podIdentity-role-<env>` | `pods.eks.amazonaws.com` | ACK pod identity role attaching ACK EKS and IAM policies. |
| `autoscaler-eks-role-<env>` | `pods.eks.amazonaws.com` | Cluster autoscaler pod identity role using `autoscaler_eks_policy`. |
| `lbController-eks-role-<env>` | `pods.eks.amazonaws.com` | Pod identity role for AWS Load Balancer Controller using `lb_controller_eks_policy`. |
| `adot-col-otlp-ingest-podIdentity-role-<env>` | `pods.eks.amazonaws.com` | OpenTelemetry OTLP collector pod identity role using `opentelemetry_otlp_podIdentity_policy` for cross-account role assumption. |

## Policies

| Policy Name | Description |
| --- | --- |
| `velero-s3-policy-<env>` | cluster custom S3 policy for Velero backup bucket access. |
| `ack-eks-podIdentity-policy-<env>` | ACK EKS policy to create pod identity association. |
| `ack-iam-podIdentity-policy-<env>` | ACK EKS policy to create IAM roles and policy. |
| `autoscaler-eks-policy-<env>` | cluster autoscaler policy for ASG scaling and EKS/EC2 describe actions. |
| `lbController-eks-policy-<env>` | IAM policy for AWS Load Balancer Controller to manage ALB/NLB, SGs, tags, and related integrations. |
| `opentelemetry-otlp-podIdentity-policy-<env>` | Allows OTLP collector role to call `sts:AssumeRole` and `sts:TagSession` on the configured NXOP cross-account role ARN. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.14.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.1 |

## Inputs

| Name | Description | Type | Required |
| ---- | ----------- | ---- | :------: |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | yes |
| <a name="input_velero_s3_bucket_name"></a> [velero\_s3\_bucket\_name](#input\_velero\_s3\_bucket\_name) | Name of the S3 bucket for Velero backups | `string` | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g., prod, nonprod) | `string` | no |
| <a name="input_fis_orchestrator_account_id"></a> [fis\_orchestrator\_account\_id](#input\_fis\_orchestrator\_account\_id) | AWS account ID of the FIS orchestrator account | `string` | no |
| <a name="input_fis_target_cluster_arns"></a> [fis\_target\_cluster\_arns](#input\_fis\_target\_cluster\_arns) | EKS cluster ARNs to target for FIS pod fault experiments | `list(string)` | no |
| <a name="input_github_arn"></a> [github\_arn](#input\_github\_arn) | Github OIDC Identifier Name | `string` | no |
| <a name="input_otlp_nxop_cross_account_role_arn"></a> [otlp\_nxop\_cross\_account\_role\_arn](#input\_otlp\_nxop\_cross\_account\_role\_arn) | NXOP account role ARN to ingest OTLP metrics into NXOP cloudwatch | `string` | no |
| <a name="input_pod_policy_arns"></a> [pod\_policy\_arns](#input\_pod\_policy\_arns) | Permission Policies for Pod Identity | `list(string)` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ec2_eks_role_arn"></a> [ec2\_eks\_role\_arn](#output\_ec2\_eks\_role\_arn) | ec2 eks role arn |
| <a name="output_eks_control_plane_role_arn"></a> [eks\_control\_plane\_role\_arn](#output\_eks\_control\_plane\_role\_arn) | eks control plane role arn |
<!-- END_TF_DOCS -->
