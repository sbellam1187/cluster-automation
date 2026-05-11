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

## Policies

| Policy Name | Description |
| --- | --- |
| `velero-s3-policy-<env>` | cluster custom S3 policy for Velero backup bucket access. |
| `ack-eks-podIdentity-policy-<env>` | ACK EKS policy to create pod identity association. |
| `ack-iam-podIdentity-policy-<env>` | ACK EKS policy to create IAM roles and policy. |
| `autoscaler-eks-policy-<env>` | cluster autoscaler policy for ASG scaling and EKS/EC2 describe actions. |
| `lbController-eks-policy-<env>` | IAM policy for AWS Load Balancer Controller to manage ALB/NLB, SGs, tags, and related integrations. |
