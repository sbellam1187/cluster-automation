################################################################################
# Google GKE Infrastructure Module
#
# Resource definitions are intentionally split by concern:
# - network.tf        : VPC, subnet, Cloud NAT, and firewall rules
# - iam.tf            : Service accounts and IAM bindings
# - cluster.tf        : GKE control plane
# - node-pools.tf     : GKE node pools
# - workload-identity.tf : Kubernetes service accounts and WI bindings
################################################################################
