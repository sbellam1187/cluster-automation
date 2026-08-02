resource "castai_workload_scaling_policy" "policies" {
  for_each = var.castai_workload_scaling_policies

  name              = each.key
  cluster_id        = var.castai_cluster_id
  apply_type        = each.value.apply_type
  management_option = each.value.management_option

  dynamic "assignment_rules" {
    for_each = (try(each.value.assignment_rules, {}) != {} ? [each.value.assignment_rules] : [])
    content {
      rules {
        dynamic "namespace" {
          for_each = assignment_rules.value.namespaces
          content {
            names = namespace.value
          }
        }
      }
    }
  }

  cpu {
    function = each.value.cpu.function
    overhead = each.value.cpu.overhead
    apply_threshold_strategy {
      type       = each.value.cpu.apply_threshold_strategy.type
      percentage = each.value.cpu.apply_threshold_strategy.percentage
    }
    limit {
      type = each.value.cpu.limit.type
    }
    args                     = each.value.cpu.args
    look_back_period_seconds = each.value.cpu.look_back_period_seconds
    min                      = each.value.cpu.min
  }

  memory {
    function = each.value.memory.function
    overhead = each.value.memory.overhead
    apply_threshold_strategy {
      type       = each.value.memory.apply_threshold_strategy.type
      percentage = each.value.memory.apply_threshold_strategy.percentage
    }
    limit {
      type = each.value.memory.limit.type
    }
    args                     = each.value.memory.function == "MAX" ? [] : each.value.memory.args
    look_back_period_seconds = each.value.memory.look_back_period_seconds
    min                      = each.value.memory.min
    max                      = try(each.value.memory.max, 0)
  }

  dynamic "startup" {
    for_each = each.value.startup
    content {
      period_seconds = each.value.startup.period_seconds
    }
  }

  dynamic "downscaling" {
    for_each = each.value.downscaling
    content {
      apply_type = each.value.downscaling.apply_type
    }
  }

  dynamic "memory_event" {
    for_each = each.value.memory_event
    content {
      apply_type = each.value.memory_event.apply_type
    }
  }

  dynamic "anti_affinity" {
    for_each = each.value.anti_affinity
    content {
      consider_anti_affinity = each.value.anti_affinity.consider_anti_affinity
    }
  }

  dynamic "confidence" {
    for_each = each.value.confidence
    content {
      threshold = each.value.confidence.threshold
    }
  }
}
### For scaling policy order, we need to get the default policies that already exist in castai,
### and add them to the list of policies created by Terraform, and sort them according to the order specified in var.scaling_policy_order.
### This is needed because there are some default policies that are always present in castai, and if we don't include them in the policy order, they will be moved to the end of the list, and the order of the policies will be changed.
locals {
  aa_created_policy_ids = [
    for key in var.scaling_policy_order : castai_workload_scaling_policy.policies[key].id
    if contains(keys(castai_workload_scaling_policy.policies), key)
  ]
  castai_default_policy_ids = tolist(setsubtract(data.castai_workload_scaling_policy_order.cluster.policy_ids, local.aa_created_policy_ids))
}
resource "castai_workload_scaling_policy_order" "custom" {
  cluster_id = var.castai_cluster_id
  policy_ids = concat(local.aa_created_policy_ids, local.castai_default_policy_ids)
}
### End of scaling policy order section

resource "castai_autoscaler" "castai_autoscaler_policy" {
  count      = var.castai_node_autoscale_enable ? 1 : 0
  cluster_id = var.castai_cluster_id

  autoscaler_settings {
    enabled                                 = var.castai_autoscaler_settings.enabled
    is_scoped_mode                          = var.castai_autoscaler_settings.is_scoped_mode
    node_templates_partial_matching_enabled = var.castai_autoscaler_settings.node_templates_partial_matching_enabled

    unschedulable_pods {
      enabled = var.castai_autoscaler_settings.unschedulable_pods.enabled
      pod_pinner {
        enabled = var.castai_autoscaler_settings.unschedulable_pods.pod_pinner.enabled
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
        enabled = var.castai_autoscaler_settings.node_downscaler.empty_nodes.enabled
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
# Node autoscaling section
resource "castai_node_configuration" "node_configuration" {

  for_each = var.castai_node_autoscale_enable ? var.castai_node_configurations : {}

  cluster_id = var.castai_cluster_id

  name              = each.key
  subnets           = var.eks_cluster_name != null ? data.aws_subnets.eks_ec2_only[0].ids : [data.azurerm_kubernetes_cluster.aks_cluster[0].agent_pool_profile[0].vnet_subnet_id]
  tags              = each.value.tags
  disk_cpu_ratio    = each.value.disk_cpu_ratio
  drain_timeout_sec = each.value.drain_timeout_sec
  image             = try(each.value.image, null)
  min_disk_size     = each.value.min_disk_size
  dynamic "aks" {
    for_each = { for k, v in each.value : k => v if k == "aks" && v != null }
    content {
      max_pods_per_node = aks.value.max_pods_per_node
      os_disk_type      = aks.value.os_disk_type
      aks_image_family  = aks.value.aks_image_family
      pod_subnet_id     = aks.value.pod_subnet_id
      dynamic "ephemeral_os_disk" {
        for_each = flatten([lookup(each.value, "aks_ephemeral_os_disk", [])])
        content {
          placement = ephemeral_os_disk.value.placement
          cache     = ephemeral_os_disk.value.cache
        }
      }
    }
  }

  dynamic "eks" {
    for_each = { for k, v in each.value : k => v if k == "eks" && v != null }
    content {
      security_groups      = [data.aws_eks_cluster.eks_cluster[0].vpc_config[0].cluster_security_group_id]
      instance_profile_arn = var.instance_profile_arn
      eks_image_family     = eks.value.eks_image_family
    }
  }
}

resource "castai_node_configuration_default" "node_configuration_default" {
  count            = var.castai_node_autoscale_enable ? 1 : 0
  cluster_id       = var.castai_cluster_id
  configuration_id = try(castai_node_configuration.node_configuration[var.castai_default_node_configuration_name].id, "1233e4567-e89b-12d3-a456-426614174000")
  depends_on       = [castai_node_configuration.node_configuration]
}
resource "castai_node_template" "default_by_castai" {
  count            = var.castai_node_autoscale_enable ? 1 : 0
  cluster_id       = var.castai_cluster_id
  is_default       = true
  is_enabled       = false
  configuration_id = castai_node_configuration_default.node_configuration_default[0].configuration_id
  name             = "default-by-castai"

  lifecycle {
    ignore_changes = [
      constraints,
    ]
  }
}

resource "castai_node_template" "castai_node_template" {
  for_each         = var.castai_node_autoscale_enable ? var.castai_node_templates : {}
  cluster_id       = var.castai_cluster_id
  name             = each.key
  clm_enabled      = try(each.value.clm_enabled, null)
  is_default       = each.value.is_default
  is_enabled       = each.value.is_enabled
  configuration_id = castai_node_configuration.node_configuration[each.value.castai_node_configuration_name].id

  custom_labels = each.value.custom_labels

  constraints {
    on_demand                             = try(each.value.constraints.on_demand, null)
    spot                                  = each.value.constraints.spot
    use_spot_fallbacks                    = each.value.constraints.use_spot_fallbacks
    compute_optimized_state               = try(each.value.constraints.compute_optimized_state, "")
    storage_optimized_state               = try(each.value.constraints.storage_optimized_state, "")
    fallback_restore_rate_seconds         = each.value.constraints.fallback_restore_rate_seconds
    spot_reliability_enabled              = try(each.value.constraints.spot_reliability_enabled, false)
    spot_interruption_predictions_enabled = try(each.value.constraints.spot_interruption_predictions_enabled, false)
    min_cpu                               = each.value.constraints.min_cpu
    max_cpu                               = each.value.constraints.max_cpu
    min_memory                            = try(each.value.constraints.min_memory, null)
    max_memory                            = try(each.value.constraints.max_memory, null)
    architectures                         = try(each.value.constraints.architectures, ["amd64"])
    azs                                   = try(each.value.constraints.azs, null)
    burstable_instances                   = try(each.value.constraints.burstable_instances, null)
    customer_specific                     = try(each.value.constraints.customer_specific, null)

    dynamic "instance_families" {
      for_each = { for k, v in each.value.constraints : k => v if k == "instance_families" && v != null }
      content {
        include = try(instance_families.value.include, [])
        exclude = instance_families.value.exclude
      }
    }

    dynamic "custom_priority" {
      for_each = { for k, v in each.value.constraints : k => v if k == "custom_priority" && v != null }
      content {
        instance_families = custom_priority.value.instance_families
        spot              = custom_priority.value.spot
        on_demand         = custom_priority.value.on_demand
      }
    }
  }
  depends_on = [castai_node_configuration_default.node_configuration_default]
}
# Rebalancing Job create/update
resource "castai_rebalancing_schedule" "rebalancing_schedule" {
  for_each = var.castai_node_autoscale_enable ? var.castai_rebalancing_schedule : {}
  name     = "${var.castai_cluster_id}-${each.key}"

  schedule {
    cron = each.value.schedule_cron
  }

  trigger_conditions {
    savings_percentage = each.value.savings_percentage
  }

  launch_configuration {
    node_ttl_seconds         = each.value.node_ttl_seconds
    num_targeted_nodes       = each.value.num_targeted_nodes
    rebalancing_min_nodes    = each.value.rebalancing_min_nodes
    keep_drain_timeout_nodes = each.value.keep_drain_timeout_nodes

    selector = jsonencode({
      nodeSelectorTerms = [{
        matchExpressions = [
          for n in each.value.node_selector : {
            key      = n.key
            operator = n.operator
            values   = n.values
          }
        ]
      }]
    })

    dynamic "execution_conditions" {
      for_each = try(each.value.execution_conditions, null) != null ? [each.value.execution_conditions] : []
      content {
        enabled                     = try(execution_conditions.value.enabled, false)
        achieved_savings_percentage = try(execution_conditions.value.achieved_savings_percentage, 1)
      }
    }
  }
}

# Rebalancing Job assignment to schedule
resource "castai_rebalancing_job" "rebalancing_job" {
  for_each                = var.castai_node_autoscale_enable ? var.castai_rebalancing_schedule : {}
  cluster_id              = var.castai_cluster_id
  rebalancing_schedule_id = castai_rebalancing_schedule.rebalancing_schedule[each.key].id
  enabled                 = try(each.value.enabled, false)
  depends_on              = [castai_node_template.castai_node_template]
}
