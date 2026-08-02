# Changelog
## v3.0.0-tf-eks-cluster+pr7730
- Removed EIP provisioning from Terraform; EIP allocation is now handled by the Istio gateway service object via the aws-load-balancer-controller.

## v2.8.0-tf-eks-cluster+pr7503
- Refactored EKS addon resources in the child module to a single `for_each` driven `aws_eks_addon` implementation, with addon settings passed via `addon_configs` for consistent version and conflict handling.
- Moved addon configuration ownership to the lab/root module for environment-specific control and safer upgrades.

## v2.7.0-tf-eks-cluster+pr7436
- Enables Amazon VPC CNI IPv4 prefix delegation via addon configuration so Pods can be allocated IPs from delegated /28 prefixes on pod ENIs (instead of individual secondary IPs), improving pod density and reducing EC2 API calls.
    - Adds ENABLE_PREFIX_DELEGATION=true to the VPC CNI addon configuration_values.
    - Updates the JSON formatting in the CNI config to include the required comma between env entries.

## v2.6.0-tf-eks-cluster+pr7387
- Updating the addon management approach from automatic data source selection to manual version control via variables for precise version management across all environments.

## v2.5.0-tf-eks-cluster+pr7178
- Enhanced EKS upgrade reliability with force update for node groups and addon conflict resolution.

## v2.4.0-tf-eks-cluster+pr7002
- Added EKS addon version compatibility and configurable node group orchestrator versions.

## v2.3.0-tf-eks-cluster+pr6670
- Adding aws eks_cluster resource dependency for kubernetes/helm provider resources and updating module tag only for nonprod

## v2.2.0-tf-eks-cluster+pr6633
- Adding amazon Mountpoint S3 Driver

## v2.1.0-tf-eks-cluster+pr6512
- Add output for EIP so that it can be used in root module and add to vault during cluster spin up

## v2.0.0-tf-eks-cluster+pr6452
- Update helm provider config to use aws cli instead of data source to obtain cluster authentication details.

## v1.0.0-tf-eks-cluster+pr6436
- Make cluster API Private and add security group inbound rule to allow tls traffic to API server from selected networks

***Breaking changes***
- API cluster access is made private

## v0.3.0-tf-eks-cluster+pr6439
- Add tags to aws resources module aws-eks-cluster

## v0.2.0-tf-eks-cluster+pr6329
- Add capability to associate multiple pod identities to the module

***Breaking changes***
- change pod identity to a map from being a string. Update root module to overcome this breaking change


## v0.1.0-tf-eks-cluster+pr6324
- Add spot instances capability to the module as optional

***Breaking changes***
- Move disk_size to be part of the variable node_group instead of a separate variable

## v0.0.2-tf-eks-cluster+pr6230
- Add disk size parameter to node groups resource

## v0.0.1-tf-eks-cluster+pr6052
- Initial module version for eks cluster
