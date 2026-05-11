module "castai_cluster" {
  source           = "../../../__modules/castai/castai-eks-cluster"
  cluster_name     = var.cluster_name
  sdlc_environment = var.sdlc_environment
  vpc_id           = var.vpc_id[var.region]
}
module "castai_config" {
  source                           = "../../../__modules/castai/castai-configuration"
  castai_cluster_id                = module.castai_cluster.castai_cluster_id
  castai_workload_scaling_policies = var.castai_workload_scaling_policies
  scaling_policy_order             = ["AA_Default", "AA_Stability", "AA_Resilient", "AA_Protected"]
  castai_node_autoscale_enable     = var.castai_node_autoscale_enable
  castai_autoscaler_settings       = var.castai_autoscaler_settings
  castai_node_configurations       = var.castai_node_configurations
  castai_node_templates            = var.castai_node_templates
  castai_rebalancing_schedule      = var.castai_rebalancing_schedule
  vpc_id                           = var.vpc_id[var.region]
  instance_profile_arn             = module.castai_cluster.instance_role_arn
  eks_cluster_name                 = var.cluster_name
}
