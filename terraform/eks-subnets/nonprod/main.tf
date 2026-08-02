module "eks_subnets" {
  source                      = "git::https://github.com/AAInternal/runway-kubernetes-cluster-automation//terraform/__modules/aws-subnets?ref=v1.0.0-tf-aws-subnets%2Bpr7906"
  subnets                     = var.subnets
  vpc_id                      = var.vpc_id
  public_rt_name              = var.public_rt_name
  public_routes               = var.public_routes
  allowed_cluster_names       = var.allowed_cluster_names
  interface_endpoint_services = var.interface_endpoint_services
}
