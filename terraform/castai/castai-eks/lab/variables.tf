variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
variable "sdlc_environment" {
  type        = string
  description = "Cluster environment, provide nonprod for both lab and nonprod"
}
variable "region" {
  description = "AWS region where the EKS cluster is located"
  type        = string
}

variable "vpc_id" {
  type        = map(string)
  description = "VPC of the cluster IAM resources will created for."
  default = {
    "us-east-1" = "vpc-04f33088d2bf9974a"
    "us-west-2" = "vpc-01d736f3291515ffd"
  }
}

variable "castai_api_token" {
  type        = string
  sensitive   = true
  description = "castai api token to connect to castai"
}
## castai configuration variables
variable "castai_workload_scaling_policies" {
  description = "Map of workload scaling policies with optimized defaults"
  type = map(object({
    apply_type        = optional(string, "IMMEDIATE")
    management_option = optional(string, "MANAGED")
    assignment_rules = optional(object({
      namespaces = optional(object({
        name = optional(list(string), ["default"])
      }), {})
    }), {})

    cpu = optional(object({
      function                 = optional(string, "QUANTILE")
      overhead                 = optional(number, 0.15) # 2/4 use 0.15
      args                     = optional(list(string), ["0.95"])
      look_back_period_seconds = optional(number, 604800) # 2/4 use 7 days
      min                      = optional(number, 0.01)   # 3/4 use 0.01
      apply_threshold_strategy = optional(object({
        type       = optional(string, "PERCENTAGE")
        percentage = optional(number, 0.3)
      }), {})
      limit = optional(object({
        type = optional(string, "KEEP_LIMITS")
      }), {})
    }), {})

    memory = optional(object({
      function                 = optional(string, "MAX")
      overhead                 = optional(number, 0.05)
      args                     = optional(list(any), [])
      look_back_period_seconds = optional(number, 604800)
      min                      = optional(number, 10.0)
      max                      = optional(number, 0)
      apply_threshold_strategy = optional(object({
        type       = optional(string, "PERCENTAGE")
        percentage = optional(number, 0.3)
      }), {})
      limit = optional(object({
        type = optional(string, "KEEP_LIMITS")
      }), {})
    }), {})

    downscaling   = optional(object({ apply_type = optional(string, "IMMEDIATE") }), {})
    memory_event  = optional(object({ apply_type = optional(string, "IMMEDIATE") }), {})
    anti_affinity = optional(object({ consider_anti_affinity = optional(bool, true) }), {})
    confidence    = optional(object({ threshold = optional(number, 0.9) }), {})
    startup       = optional(object({ period_seconds = optional(number, 300) }), {})
  }))
  ## overrides for scaling policies, can be defined in tfvars file, if not defined below will be applied
  default = {
    AA_Default = {
      cpu    = { overhead = 0.10, look_back_period_seconds = 86400 }
      memory = { look_back_period_seconds = 86400 }
    }
    AA_Resilient = {
      assignment_rules = {
        namespaces = { name = ["cattle-fleet-system", "cert-manager", "cloudability", "container-registry-update", "keda", "kubernetes-gtm-sync-service", "runway-conductor-operator-system", "runway-ingress-operator-system", "runway-webapp-operator-system", "synthetics-monitoring", "telemetry-apm-dynatrace", "telemetry-logs-fluentbit", "telemetry-metrics-prometheus-stack", "telemetry-synthetics-grafana-private-probe", "tenable", "vault-secrets-operator-system", "velero"] }
      }
      memory = { overhead = 0.30 }
    }
    AA_Stability = {
      assignment_rules = {
        namespaces = { name = ["castai-agent", "cattle-system", "dx-apigee", "dx-apigee-dev", "dx-apigee-stage", "dx-apigee-test", "grafana-cloud", "istio-gateway", "istio-system"] }
      }
      cpu    = { min = 0.10 }
      memory = { overhead = 0.20, max = 10240.0 }
    }

    AA_Protected = {
      management_option = "READ_ONLY"
      cpu               = { overhead = 0.05, look_back_period_seconds = 86400, limit = { type = "NO_LIMIT" } }
      memory            = { look_back_period_seconds = 86400 }
    }
  }
}

variable "castai_node_autoscale_enable" {
  default     = false
  type        = bool
  description = "flag to enable node autoscaler"
}
variable "castai_autoscaler_settings" {
  description = "Settings for CastAI autoscaler with nested defaults"
  type = object({
    enabled                                 = optional(bool, true)
    is_scoped_mode                          = optional(bool, false)
    node_templates_partial_matching_enabled = optional(bool, true)
    unschedulable_pods = optional(object({
      enabled = optional(bool, true)
      pod_pinner = optional(object({
        enabled = optional(bool, true)
      }), {})
    }), {})

    cluster_limits = optional(object({
      enabled = optional(bool, false)
      cpu = optional(object({
        min_cores = optional(number, 1)
        max_cores = optional(number, 200)
      }), {})
    }), {})

    node_downscaler = optional(object({
      enabled = optional(bool, true)
      empty_nodes = optional(object({
        enabled = optional(bool, true)
      }), {})
      evictor = optional(object({
        aggressive_mode           = optional(bool, false)
        cycle_interval            = optional(string, "1m")
        dry_run                   = optional(bool, false)
        enabled                   = optional(bool, true)
        node_grace_period_minutes = optional(number, 10)
        scoped_mode               = optional(bool, false)
      }), {})
    }), {})
  })

  default = {}
}


variable "castai_node_configurations" {
  description = "Map of node configurations with nested defaults"
  type = map(object({
    disk_cpu_ratio    = optional(number, 4)
    min_disk_size     = optional(number, 100)
    max_pods_per_node = optional(number, 200)
    drain_timeout_sec = optional(number, 300)
    tags              = optional(map(string), { "castai_node_config" : "aa_castai_node_conf_default" })
    eks = optional(object({
      eks_image_family = optional(string, "al2023")
    }), {})
  }))
  default = {
    aa_castai_node_conf_default = {} # Uses all defaults above
  }
}
variable "castai_node_templates" {
  description = "Map of CAST AI node templates with nested defaults"
  type = map(object({
    castai_node_configuration_name = optional(string, "aa_castai_node_conf_default")
    is_default                     = optional(bool, false)
    is_enabled                     = optional(bool, true)
    should_taint                   = optional(bool, false)
    custom_labels = optional(map(string), {
      aa_castai_agentpool = "common"
    })

    constraints = optional(object({
      fallback_restore_rate_seconds = optional(number, 1800)
      on_demand                     = optional(bool, true)
      spot                          = optional(bool, false)
      use_spot_fallbacks            = optional(bool, false)
      compute_optimized_state       = optional(string, "disabled")
      storage_optimized_state       = optional(string, "disabled")
      is_gpu_only                   = optional(bool, false)
      min_cpu                       = optional(number, 12)
      max_cpu                       = optional(number, 32)
      min_memory                    = optional(number, 4096)
      max_memory                    = optional(number, 131072)
      architectures                 = optional(list(string), ["amd64"])
      azs                           = optional(list(string), [])
      burstable_instances           = optional(string, "disabled")
      customer_specific             = optional(string, "disabled")
      instance_families = optional(object({
        include = optional(list(string), ["r5a", "m5a"])
        exclude = optional(list(string), [])
      }), {})
      custom_priority = optional(object({
        instance_families = optional(list(string), ["r5a", "m5a"])
        spot              = optional(bool, false)
        on_demand         = optional(bool, true)
      }), {})
    }), {})
  }))

  default = {
    "aa_worker_castai_default_tmpl" = {} # Uses all defaults above
  }
}

variable "castai_rebalancing_schedule" {
  description = "Map of CAST AI rebalancing schedules with nested defaults"
  type = map(object({
    enabled                  = optional(bool, true)
    schedule_cron            = optional(string, "CRON_TZ=America/Chicago 0 */4 * * *")
    savings_percentage       = optional(number, 5)
    node_ttl_seconds         = optional(number, 300)
    num_targeted_nodes       = optional(number, 10)
    rebalancing_min_nodes    = optional(number, 1)
    keep_drain_timeout_nodes = optional(bool, false)
    execution_conditions = optional(object({
      enabled                     = optional(bool, false)
      achieved_savings_percentage = optional(number, 1)
      }), {
      enabled                     = false
      achieved_savings_percentage = 1
    })
    node_selector = optional(list(object({
      key      = string
      operator = string
      values   = list(string)
      })), [
      {
        key      = "aa_castai_agentpool"
        operator = "In"
        values   = ["common"]
      }
    ])
  }))

  default = {
    "aa_castai_worker_default" = {} # Uses all defaults above
  }
}
