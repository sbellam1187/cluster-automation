# Fetch current subscription data
data "azurerm_subscription" "current" {
  subscription_id = local.subscription_id
}

data "castai_workload_scaling_policy_order" "cluster" {
  cluster_id = castai_aks_cluster.aks_cluster.id
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
  resource_group_name = local.aks_cluster_resource_group_name
}

data "azurerm_role_definition" "custom_castai_role" {
  name  = local.castai_custom_role_name
  scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
}