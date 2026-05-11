locals {
  ordered_policy_ids = [
    castai_workload_scaling_policy.AA_Default.id,
    castai_workload_scaling_policy.AA_Stability.id,
    castai_workload_scaling_policy.AA_Resilient.id,
    castai_workload_scaling_policy.AA_Protected.id
  ]
  unordered_policy_ids           = tolist(setsubtract(data.castai_workload_scaling_policy_order.cluster.policy_ids, local.ordered_policy_ids))
  configuration_id_regex_pattern = "[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}"
}


resource "azurerm_role_assignment" "castai_node_resource_group" {
  principal_id       = local.castai_sp_object_id
  role_definition_id = data.azurerm_role_definition.custom_castai_role.id
  scope              = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${data.azurerm_kubernetes_cluster.aks_cluster.node_resource_group}"
}

resource "castai_aks_cluster" "aks_cluster" {
  # depends_on = [
  #   azurerm_role_assignment.castai_node_resource_group,
  # ]
  name                       = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
  region                     = var.location
  subscription_id            = data.azurerm_subscription.current.subscription_id
  tenant_id                  = data.azurerm_subscription.current.tenant_id
  client_id                  = local.castai_sp_client_id
  client_secret              = var.castai_sp_client_secret
  node_resource_group        = data.azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  delete_nodes_on_disconnect = var.delete_nodes_on_disconnect
}


#This is just to disable the default workload scaling policy
resource "castai_workload_scaling_policy" "default" {
  name              = "default"
  cluster_id        = castai_aks_cluster.aks_cluster.id
  apply_type        = "IMMEDIATE"
  management_option = "READ_ONLY"

  lifecycle {
    ignore_changes = all
  }

  cpu {
    function = "QUANTILE"
    overhead = 0.05
    apply_threshold_strategy {
      type       = "PERCENTAGE"
      percentage = 0.3
    }
    limit {
      type = "NO_LIMIT"
    }
    args                     = ["0.95"]
    look_back_period_seconds = 86400
    min                      = 0.01
  }
  memory {
    function = "MAX"
    overhead = 0.05
    apply_threshold_strategy {
      type       = "PERCENTAGE"
      percentage = 0.3
    }
    args                     = []
    look_back_period_seconds = 86400
    min                      = 10
  }
}

#This is just to disable the default-statefulset workload scaling policy
resource "castai_workload_scaling_policy" "default-statefulset" {
  name              = "default-statefulset"
  cluster_id        = castai_aks_cluster.aks_cluster.id
  apply_type        = "IMMEDIATE"
  management_option = "READ_ONLY"

  lifecycle {
    ignore_changes = all
  }

  cpu {
    function = "QUANTILE"
    overhead = 0.05
    apply_threshold_strategy {
      type       = "PERCENTAGE"
      percentage = 0.3
    }
    limit {
      type = "NO_LIMIT"
    }
    args                     = ["0.95"]
    look_back_period_seconds = 86400
    min                      = 0.01
  }
  memory {
    function = "MAX"
    overhead = 0.05
    apply_threshold_strategy {
      type       = "PERCENTAGE"
      percentage = 0.3
    }
    args                     = []
    look_back_period_seconds = 86400
    min                      = 10
  }
}

resource "castai_workload_scaling_policy" "AA_Default" {
  name       = "AA_Default"
  cluster_id = castai_aks_cluster.aks_cluster.id

  apply_type        = try(var.castai_apply_type["AA_Default"], "IMMEDIATE")
  management_option = try(var.castai_management_option["AA_Default"], "MANAGED")

  assignment_rules {
    rules {
      namespace {
        names = try(var.castai_assignment_rules["AA_Default"], [])
      }
    }
  }

  cpu {
    function = try(var.castai_workload_policies_cpu["AA_Default"].function, "QUANTILE")
    overhead = try(var.castai_workload_policies_cpu["AA_Default"].overhead, 0.10)
    apply_threshold_strategy {
      type       = try(var.castai_workload_policies_cpu["AA_Default"].threshold_type, "PERCENTAGE")
      percentage = try(var.castai_workload_policies_cpu["AA_Default"].threshold_percentage, 0.3)
    }
    limit {
      type = try(var.castai_workload_policies_cpu["AA_Default"].limit, "KEEP_LIMITS")
    }
    args                     = [try(var.castai_workload_policies_cpu["AA_Default"].args, 0.95)]
    look_back_period_seconds = try(var.castai_workload_policies_cpu["AA_Default"].look_back_period_seconds, 86400)
    min                      = try(var.castai_workload_policies_cpu["AA_Default"].min, 0.01)
  }
  memory {
    function = try(var.castai_workload_policies_memory["AA_Default"].function, "MAX")
    overhead = try(var.castai_workload_policies_memory["AA_Default"].overhead, 0.05)
    apply_threshold_strategy {
      type       = try(var.castai_workload_policies_memory["AA_Default"].threshold_type, "PERCENTAGE")
      percentage = try(var.castai_workload_policies_memory["AA_Default"].threshold_percentage, 0.3)
    }
    limit {
      type = try(var.castai_workload_policies_memory["AA_Default"].limit, "KEEP_LIMITS")
    }
    args                     = []
    look_back_period_seconds = try(var.castai_workload_policies_memory["AA_Default"].look_back_period_seconds, 86400)
    min                      = try(var.castai_workload_policies_memory["AA_Default"].min, 10.0)
    max                      = try(var.castai_workload_policies_memory["AA_Default"].max, 0)
  }
  startup {
    period_seconds = try(var.castai_workload_policies_startup["AA_Default"].period_seconds, 300)
  }
  downscaling {
    apply_type = try(var.castai_workload_policies_downscaling["AA_Default"].apply_type, "IMMEDIATE")
  }
  memory_event {
    apply_type = try(var.castai_workload_policies_memory_event["AA_Default"].apply_type, "IMMEDIATE")
  }
  anti_affinity {
    consider_anti_affinity = try(var.castai_workload_policies_anti_affinity["AA_Default"].consider_anti_affinity, true)
  }
  confidence {
    threshold = try(var.castai_workload_policies_confidence["AA_Default"].threshold, 0.9)
  }
}

resource "castai_workload_scaling_policy" "AA_Resilient" {
  name       = "AA_Resilient"
  cluster_id = castai_aks_cluster.aks_cluster.id

  apply_type        = try(var.castai_apply_type["AA_Resilient"], "IMMEDIATE")
  management_option = try(var.castai_management_option["AA_Resilient"], "MANAGED")

  assignment_rules {
    rules {
      namespace {
        names = try(var.castai_assignment_rules["AA_Resilient"], [])
      }
    }
  }
  cpu {
    function = try(var.castai_workload_policies_cpu["AA_Resilient"].function, "QUANTILE")
    overhead = try(var.castai_workload_policies_cpu["AA_Resilient"].overhead, 0.15)
    apply_threshold_strategy {
      type       = try(var.castai_workload_policies_cpu["AA_Resilient"].threshold_type, "PERCENTAGE")
      percentage = try(var.castai_workload_policies_cpu["AA_Resilient"].threshold_percentage, 0.3)
    }
    limit {
      type = try(var.castai_workload_policies_cpu["AA_Resilient"].limit, "KEEP_LIMITS")
    }
    args                     = [try(var.castai_workload_policies_cpu["AA_Resilient"].args, 0.95)]
    look_back_period_seconds = try(var.castai_workload_policies_cpu["AA_Resilient"].look_back_period_seconds, 604800)
    min                      = try(var.castai_workload_policies_cpu["AA_Resilient"].min, 0.01)
  }
  memory {
    function = try(var.castai_workload_policies_memory["AA_Resilient"].function, "MAX")
    overhead = try(var.castai_workload_policies_memory["AA_Resilient"].overhead, 0.30)
    apply_threshold_strategy {
      type       = try(var.castai_workload_policies_memory["AA_Resilient"].threshold_type, "PERCENTAGE")
      percentage = try(var.castai_workload_policies_memory["AA_Resilient"].threshold_percentage, 0.3)
    }
    limit {
      type = try(var.castai_workload_policies_memory["AA_Resilient"].limit, "KEEP_LIMITS")
    }
    args                     = []
    look_back_period_seconds = try(var.castai_workload_policies_memory["AA_Resilient"].look_back_period_seconds, 604800)
    min                      = try(var.castai_workload_policies_memory["AA_Resilient"].min, 10.0)
    max                      = try(var.castai_workload_policies_memory["AA_Resilient"].max, 0)
  }
  startup {
    period_seconds = try(var.castai_workload_policies_startup["AA_Resilient"].period_seconds, 300)
  }
  downscaling {
    apply_type = try(var.castai_workload_policies_downscaling["AA_Resilient"].apply_type, "IMMEDIATE")
  }
  memory_event {
    apply_type = try(var.castai_workload_policies_memory_event["AA_Resilient"].apply_type, "IMMEDIATE")
  }
  anti_affinity {
    consider_anti_affinity = try(var.castai_workload_policies_anti_affinity["AA_Resilient"].consider_anti_affinity, true)
  }
  confidence {
    threshold = try(var.castai_workload_policies_confidence["AA_Resilient"].threshold, 0.9)
  }
}

resource "castai_workload_scaling_policy" "AA_Stability" {
  name       = "AA_Stability"
  cluster_id = castai_aks_cluster.aks_cluster.id

  apply_type        = try(var.castai_apply_type["AA_Stability"], "IMMEDIATE")
  management_option = try(var.castai_management_option["AA_Stability"], "MANAGED")

  assignment_rules {
    rules {
      namespace {
        names = try(var.castai_assignment_rules["AA_Stability"], [])
      }
    }
  }
  cpu {
    function = try(var.castai_workload_policies_cpu["AA_Stability"].function, "QUANTILE")
    overhead = try(var.castai_workload_policies_cpu["AA_Stability"].overhead, 0.15)
    apply_threshold_strategy {
      type       = try(var.castai_workload_policies_cpu["AA_Stability"].threshold_type, "PERCENTAGE")
      percentage = try(var.castai_workload_policies_cpu["AA_Stability"].threshold_percentage, 0.3)
    }
    limit {
      type = try(var.castai_workload_policies_cpu["AA_Stability"].limit, "KEEP_LIMITS")
    }
    args                     = [try(var.castai_workload_policies_cpu["AA_Stability"].args, 0.95)]
    look_back_period_seconds = try(var.castai_workload_policies_cpu["AA_Stability"].look_back_period_seconds, 604800)
    min                      = try(var.castai_workload_policies_cpu["AA_Stability"].min, 0.10)
  }
  memory {
    function = try(var.castai_workload_policies_memory["AA_Stability"].function, "MAX")
    overhead = try(var.castai_workload_policies_memory["AA_Stability"].overhead, 0.20)
    apply_threshold_strategy {
      type       = try(var.castai_workload_policies_memory["AA_Stability"].threshold_type, "PERCENTAGE")
      percentage = try(var.castai_workload_policies_memory["AA_Stability"].threshold_percentage, 0.3)
    }
    limit {
      type = try(var.castai_workload_policies_memory["AA_Stability"].limit, "KEEP_LIMITS")
    }
    args                     = []
    look_back_period_seconds = try(var.castai_workload_policies_memory["AA_Stability"].look_back_period_seconds, 604800)
    min                      = try(var.castai_workload_policies_memory["AA_Stability"].min, 10.0)
    max                      = try(var.castai_workload_policies_memory["AA_Stability"].max, 10240.0)
  }
  startup {
    period_seconds = try(var.castai_workload_policies_startup["AA_Stability"].period_seconds, 300)
  }
  downscaling {
    apply_type = try(var.castai_workload_policies_downscaling["AA_Stability"].apply_type, "IMMEDIATE")
  }
  memory_event {
    apply_type = try(var.castai_workload_policies_memory_event["AA_Stability"].apply_type, "IMMEDIATE")
  }
  anti_affinity {
    consider_anti_affinity = try(var.castai_workload_policies_anti_affinity["AA_Stability"].consider_anti_affinity, true)
  }
  confidence {
    threshold = try(var.castai_workload_policies_confidence["AA_Stability"].threshold, 0.9)
  }
}

# AA_Protected policy needs special lifecycle management, so it's handled separately
resource "castai_workload_scaling_policy" "AA_Protected" {
  name              = "aa_protected"
  cluster_id        = castai_aks_cluster.aks_cluster.id
  apply_type        = try(var.castai_apply_type["AA_Protected"], "IMMEDIATE")
  management_option = try(var.castai_management_option["AA_Protected"], "READ_ONLY")

  lifecycle {
    ignore_changes = all
  }

  cpu {
    function = "QUANTILE"
    overhead = 0.05
    apply_threshold_strategy {
      type       = "PERCENTAGE"
      percentage = 0.3
    }
    limit {
      type = "NO_LIMIT"
    }
    args                     = ["0.95"]
    look_back_period_seconds = 86400
    min                      = 0.01
  }
  memory {
    function = try(var.castai_workload_policies_memory["AA_Protected"].function, "MAX")
    overhead = try(var.castai_workload_policies_memory["AA_Protected"].overhead, 0.05)
    apply_threshold_strategy {
      type       = try(var.castai_workload_policies_memory["AA_Protected"].threshold_type, "PERCENTAGE")
      percentage = try(var.castai_workload_policies_memory["AA_Protected"].threshold_percentage, 0.3)
    }
    limit {
      type = try(var.castai_workload_policies_memory["AA_Protected"].limit, "KEEP_LIMITS")
    }
    args                     = []
    look_back_period_seconds = try(var.castai_workload_policies_memory["AA_Protected"].look_back_period_seconds, 86400)
    min                      = try(var.castai_workload_policies_memory["AA_Protected"].min, 10.0)
    max                      = try(var.castai_workload_policies_memory["AA_Protected"].max, 0)
  }
}

resource "castai_autoscaler" "castai_autoscaler_policy" {
  count      = var.castai_node_autoscale_enable ? 1 : 0
  cluster_id = castai_aks_cluster.aks_cluster.id

  autoscaler_settings {
    enabled                                 = var.castai_autoscaler_settings.enabled
    is_scoped_mode                          = var.castai_autoscaler_settings.is_scoped_mode
    node_templates_partial_matching_enabled = var.castai_autoscaler_settings.node_templates_partial_matching_enabled

    unschedulable_pods {
      enabled = var.castai_autoscaler_settings.unschedulable_pods.enabled

      headroom {
        enabled           = var.castai_autoscaler_settings.unschedulable_pods.headroom.enabled
        cpu_percentage    = var.castai_autoscaler_settings.unschedulable_pods.headroom.cpu_percentage
        memory_percentage = var.castai_autoscaler_settings.unschedulable_pods.headroom.memory_percentage
      }
      pod_pinner {
        enabled = try(var.castai_autoscaler_settings.unschedulable_pods.pod_pinner.enabled, false)
      }
    }

    cluster_limits {
      enabled = var.castai_autoscaler_settings.cluster_limits.enabled

      cpu {
        min_cores = var.castai_autoscaler_settings.cluster_limits.cpu.min_cores
        max_cores = var.castai_autoscaler_settings.cluster_limits.cpu.max_cores
      }
    }

    node_downscaler {
      enabled = var.castai_autoscaler_settings.node_downscaler.enabled

      empty_nodes {
        enabled       = var.castai_autoscaler_settings.node_downscaler.empty_nodes.enabled
        delay_seconds = var.castai_autoscaler_settings.node_downscaler.empty_nodes.delay_seconds
      }

      evictor {
        aggressive_mode           = var.castai_autoscaler_settings.node_downscaler.evictor.aggressive_mode
        cycle_interval            = var.castai_autoscaler_settings.node_downscaler.evictor.cycle_interval
        dry_run                   = var.castai_autoscaler_settings.node_downscaler.evictor.dry_run
        enabled                   = var.castai_autoscaler_settings.node_downscaler.evictor.enabled
        node_grace_period_minutes = var.castai_autoscaler_settings.node_downscaler.evictor.node_grace_period_minutes
        scoped_mode               = var.castai_autoscaler_settings.node_downscaler.evictor.scoped_mode
      }
    }
  }
}

resource "castai_workload_scaling_policy_order" "custom" {
  cluster_id = castai_aks_cluster.aks_cluster.id
  policy_ids = concat(local.ordered_policy_ids, sort(local.unordered_policy_ids))
}

# Node autoscaling section

resource "castai_node_configuration" "node_configuration" {

  for_each = {
    for k, v in var.castai_aks_node_configurations : k => v
    if var.castai_node_autoscale_enable
  }

  cluster_id = castai_aks_cluster.aks_cluster.id

  name              = try(each.value.name, each.key)
  subnets           = [data.azurerm_kubernetes_cluster.aks_cluster.agent_pool_profile[0].vnet_subnet_id]
  tags              = try(each.value.tags, {})
  disk_cpu_ratio    = try(each.value.disk_cpu_ratio, 0)
  drain_timeout_sec = try(each.value.drain_timeout_sec, 0)
  image             = try(each.value.image, null)
  min_disk_size     = try(each.value.min_disk_size, 100)
  aks {
    max_pods_per_node = try(each.value.max_pods_per_node, 30)
    os_disk_type      = try(each.value.os_disk_type, null)
    aks_image_family  = try(each.value.aks_image_family, null)
    pod_subnet_id     = data.azurerm_kubernetes_cluster.aks_cluster.agent_pool_profile[0].vnet_subnet_id
    dynamic "ephemeral_os_disk" {
      for_each = flatten([lookup(each.value, "aks_ephemeral_os_disk", [])])
      content {
        placement = try(ephemeral_os_disk.value.placement, null)
      }
    }
  }
}
resource "castai_node_configuration_default" "node_configuration_default" {
  count            = var.castai_node_autoscale_enable ? 1 : 0
  cluster_id       = castai_aks_cluster.aks_cluster.id
  configuration_id = var.castai_default_node_configuration_name != "" ? castai_node_configuration.node_configuration[var.castai_default_node_configuration_name].id : length(regexall(local.configuration_id_regex_pattern, var.castai_default_node_configuration)) > 0 ? var.castai_default_node_configuration : castai_node_configuration.node_configuration[var.castai_default_node_configuration].id
  depends_on       = [castai_node_configuration.node_configuration]
}
# need to handle the default node template created by castai when no templates are defined
# this resource will import that default node template and disable it to avoid conflicts
# Uncomment the import block below when castai_node_autoscale_enable is true
# import {
#   to = castai_node_template.default_by_castai[0]
#   id = "${castai_aks_cluster.aks_cluster.id}/default-by-castai"
# }
resource "castai_node_template" "default_by_castai" {
  count            = var.castai_node_autoscale_enable ? 1 : 0
  cluster_id       = castai_aks_cluster.aks_cluster.id
  is_default       = true  # disable the default template created by castai
  is_enabled       = false # disable the default template created by castai
  configuration_id = castai_node_configuration_default.node_configuration_default[0].configuration_id
  name             = "default-by-castai"
  lifecycle {
    ignore_changes = [
      constraints,
    ]
  }
}
resource "castai_node_template" "node_template" {
  for_each = {
    for k, v in var.castai_aks_node_templates : k => v
    if var.castai_node_autoscale_enable
  }

  cluster_id = castai_aks_cluster.aks_cluster.id

  name                         = try(each.value.name, each.key)
  is_default                   = try(each.value.is_default, false)
  is_enabled                   = try(each.value.is_enabled, true)
  configuration_id             = try(each.value.castai_node_configuration_name, null) != null ? castai_node_configuration.node_configuration[each.value.castai_node_configuration_name].id : null
  should_taint                 = try(each.value.should_taint, true)
  rebalancing_config_min_nodes = try(each.value.rebalancing_config_min_nodes, 0)

  custom_labels = try(each.value.custom_labels, {})

  dynamic "custom_taints" {
    for_each = flatten([lookup(each.value, "custom_taints", [])])

    content {
      key    = try(custom_taints.value.key, null)
      value  = try(custom_taints.value.value, null)
      effect = try(custom_taints.value.effect, null)
    }
  }

  dynamic "constraints" {
    for_each = [for constraints in flatten([lookup(each.value, "constraints", [])]) : constraints if constraints != null]

    content {
      compute_optimized                             = try(constraints.value.compute_optimized, null)
      storage_optimized                             = try(constraints.value.storage_optimized, null)
      compute_optimized_state                       = try(constraints.value.compute_optimized_state, "")
      storage_optimized_state                       = try(constraints.value.storage_optimized_state, "")
      spot                                          = try(constraints.value.spot, false)
      on_demand                                     = try(constraints.value.on_demand, null)
      use_spot_fallbacks                            = try(constraints.value.use_spot_fallbacks, false)
      fallback_restore_rate_seconds                 = try(constraints.value.fallback_restore_rate_seconds, null)
      enable_spot_diversity                         = try(constraints.value.enable_spot_diversity, false)
      spot_diversity_price_increase_limit_percent   = try(constraints.value.spot_diversity_price_increase_limit_percent, null)
      spot_reliability_enabled                      = try(constraints.value.spot_reliability_enabled, false)
      spot_reliability_price_increase_limit_percent = try(constraints.value.spot_reliability_price_increase_limit_percent, null)
      spot_interruption_predictions_enabled         = try(constraints.value.spot_interruption_predictions_enabled, false)
      spot_interruption_predictions_type            = try(constraints.value.spot_interruption_predictions_type, null)
      min_cpu                                       = try(constraints.value.min_cpu, null)
      max_cpu                                       = try(constraints.value.max_cpu, null)
      min_memory                                    = try(constraints.value.min_memory, null)
      max_memory                                    = try(constraints.value.max_memory, null)
      architectures                                 = try(constraints.value.architectures, ["amd64"])
      architecture_priority                         = try(constraints.value.architecture_priority, [])
      os                                            = try(constraints.value.os, ["linux"])
      azs                                           = try(constraints.value.azs, null)
      burstable_instances                           = try(constraints.value.burstable_instances, null)
      customer_specific                             = try(constraints.value.customer_specific, null)
      cpu_manufacturers                             = try(constraints.value.cpu_manufacturers, null)
      is_gpu_only                                   = try(constraints.value.is_gpu_only, false)

      dynamic "instance_families" {
        for_each = [for instance_families in flatten([lookup(constraints.value, "instance_families", [])]) : instance_families if instance_families != null]

        content {
          include = try(instance_families.value.include, [])
          exclude = try(instance_families.value.exclude, [])
        }
      }

      dynamic "custom_priority" {
        for_each = [for custom_priority in flatten([lookup(constraints.value, "custom_priority", [])]) : custom_priority if custom_priority != null]

        content {
          instance_families = try(custom_priority.value.instance_families, [])
          spot              = try(custom_priority.value.spot, false)
          on_demand         = try(custom_priority.value.on_demand, false)
        }
      }

      dynamic "gpu" {
        for_each = [for gpu in flatten([lookup(constraints.value, "gpu", [])]) : gpu if gpu != null]

        content {
          manufacturers = try(gpu.value.manufacturers, [])
          include_names = try(gpu.value.include_names, [])
          exclude_names = try(gpu.value.exclude_names, [])
          min_count     = try(gpu.value.min_count, null)
          max_count     = try(gpu.value.max_count, null)
        }
      }

      dynamic "resource_limits" {
        for_each = [for resource_limits in flatten([lookup(constraints.value, "resource_limits", [])]) : resource_limits if resource_limits != null]

        content {
          cpu_limit_enabled   = try(resource_limits.value.cpu_limit_enabled, false)
          cpu_limit_max_cores = try(resource_limits.value.cpu_limit_max_cores, 0)
        }
      }
    }
  }
  depends_on = [castai_node_configuration.node_configuration, castai_node_template.default_by_castai]
}
# Rebalancing Job create/update
resource "castai_rebalancing_schedule" "rebalancing_schedule" {
  for_each = {
    for k, v in var.castai_aks_rebalancing_schedules : k => v
    if var.castai_node_autoscale_enable
  }
  name = "${var.app_sdlc_environment}_${var.devexp_cluster_num}_${var.location}_${each.key}"
  schedule {
    cron = try(each.value.schedule_cron, "0 0 0 32 * ?") # defaults to never running
  }
  trigger_conditions {
    savings_percentage = try(each.value.savings_percentage, 20)
  }
  launch_configuration {
    # only consider instances older than 5 minutes
    node_ttl_seconds         = try(each.value.node_ttl_seconds, 300)
    num_targeted_nodes       = try(each.value.num_targeted_nodes, 5)
    rebalancing_min_nodes    = try(each.value.rebalancing_min_nodes, 1)
    keep_drain_timeout_nodes = try(each.value.keep_drain_timeout_nodes, false)
    selector = jsonencode({
      nodeSelectorTerms = [{
        matchExpressions = [
          for n in each.value.node_selector : {
            key      = n.key
            operator = n.operator
            values   = [n.values]
          }
        ]
      }]
    })
    execution_conditions {
      enabled                     = try(each.value.execution_conditions.enabled, false)
      achieved_savings_percentage = try(each.value.achieved_savings_percentage, 1)
    }
  }
}

# Rebalancing Job assignment to schedule
resource "castai_rebalancing_job" "rebalancing_job" {
  for_each = {
    for k, v in var.castai_aks_rebalancing_schedules : k => v
    if var.castai_node_autoscale_enable
  }
  cluster_id              = castai_aks_cluster.aks_cluster.id
  rebalancing_schedule_id = castai_rebalancing_schedule.rebalancing_schedule[each.key].id
  enabled                 = try(each.value.enabled, false)
  depends_on              = [castai_node_template.node_template]
}
