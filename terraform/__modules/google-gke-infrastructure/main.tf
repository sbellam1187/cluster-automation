# Resources have been split into dedicated files for clarity:
#
#   network.tf           - VPC, subnet, Cloud NAT, and firewall rules
#   iam.tf               - GKE and Workload Identity service accounts + IAM bindings
#   cluster.tf           - GKE control plane configuration
#   node-pools.tf        - Managed node pools
#   workload-identity.tf - Kubernetes service account annotations for Workload Identity
#   locals.tf            - Shared local values
