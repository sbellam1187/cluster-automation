# Changelog

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
