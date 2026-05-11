## Environment and Application Variables
variable "devexp_cluster_name" {
  description = "Development experience cluster name"
  type        = string
}

variable "devexp_cluster_num" {
  description = "Development experience cluster number"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = "null"
}

variable "delete_nodes_on_disconnect" {
  type        = bool
  description = "Optionally delete Cast AI created nodes when the cluster is destroyed."
  default     = true
}

## Cast AI related variables:

variable "castai_api_url" {
  type        = string
  description = "CAST AI url to API, default value is https://api.cast.ai"
  default     = "https://api.cast.ai"
}

variable "castai_api_token" {
  description = "CAST AI API token created in console.cast.ai API Access keys section."
  type        = string
  sensitive   = true
  default     = null
}

variable "app_sdlc_environment" {
  description = "app_sdlc_environment"
  type        = string
}

variable "castai_sp_client_secret" {
  description = "Service principal secret for castai"
  type        = string
  default     = null
  sensitive   = true
}

variable "castai_node_autoscale_enable" {
  description = "Varaible to specify the condition to enable castai node autoscalling"
  type        = bool
  default     = false
}

variable "castai_apply_type" {
  description = "Apply type for each CAST AI scaling policy"
  type        = map(string)
  default = {
    AA_Default   = "IMMEDIATE"
    AA_Resilient = "IMMEDIATE"
    AA_Stability = "DEFERRED"
    AA_Protected = "IMMEDIATE"
  }
}

variable "castai_management_option" {
  description = "Management option for each CAST AI scaling policy"
  type        = map(string)
  default = {
    AA_Default   = "MANAGED"
    AA_Resilient = "MANAGED"
    AA_Stability = "MANAGED"
    AA_Protected = "READ_ONLY"
  }
}

variable "castai_assignment_rules" {
  description = "Assignment rules for each CAST AI scaling policy based on namespaces"
  type        = map(list(string))
  default = {
    AA_Default   = ["default"]
    AA_Resilient = ["cattle-fleet-system", "cert-manager", "cloudability", "cloudzero", "container-registry-update", "external-secrets-operator-system", "keda", "kubernetes-gtm-sync-service", "runway-conductor-operator-system", "runway-ingress-operator-system", "runway-webapp-operator-system", "synthetics-monitoring", "telemetry-apm-dynatrace", "telemetry-logs-fluentbit", "telemetry-metrics-prometheus-stack", "telemetry-synthetics-grafana-private-probe", "tenable", "vault-secrets-operator-system", "velero"]
    AA_Stability = ["castai-agent", "cattle-system", "dx-apigee", "dx-apigee-dev", "dx-apigee-stage", "dx-apigee-test", "dx-argocd", "grafana-cloud", "istio-gateway", "istio-system"]
    AA_Protected = []
  }
}


variable "castai_workload_policies_cpu" {
  description = "CPU settings for each workload scaling policy. Note: AA_Protected CPU settings are currently hard-coded in castai.tf and are not configurable via this variable."
  type = map(object({
    function                 = optional(string, "QUANTILE")
    overhead                 = optional(number, 0.10)
    threshold_type           = optional(string, "PERCENTAGE")
    threshold_percentage     = optional(number, 0.3)
    limit                    = optional(string, "KEEP_LIMITS")
    args                     = optional(number, 0.95)
    look_back_period_seconds = optional(number, 86400)
    min                      = optional(number, 0.01)
  }))
  default = {
    AA_Default = {
      function                 = "QUANTILE"
      overhead                 = 0.10
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = 0.95
      look_back_period_seconds = 86400
      min                      = 0.01
    }
    AA_Resilient = {
      function                 = "QUANTILE"
      overhead                 = 0.15
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = 0.95
      look_back_period_seconds = 604800
      min                      = 0.01
    }
    AA_Stability = {
      function                 = "QUANTILE"
      overhead                 = 1.00
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = 0.99
      look_back_period_seconds = 172800
      min                      = 0.10
    }
    # AA_Protected CPU settings are currently hard-coded in castai.tf and this
    # block is not used for configuring them. Changes here will not affect the
    # actual AA_Protected CPU policy and are provided for reference only.
    AA_Protected = {
      function                 = "QUANTILE"
      overhead                 = 0.15
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = 0.95
      look_back_period_seconds = 604800
      min                      = 0.10
    }
  }
}

variable "castai_workload_policies_memory" {
  description = "Memory settings for each workload scaling policy"
  type = map(object({
    function                 = optional(string, "MAX")
    overhead                 = optional(number, 0.05)
    threshold_type           = optional(string, "PERCENTAGE")
    threshold_percentage     = optional(number, 0.3)
    limit                    = optional(string, "KEEP_LIMITS")
    args                     = optional(list(string), [])
    look_back_period_seconds = optional(number, 86400)
    min                      = optional(number, 10.0)
    max                      = optional(number, 0)
  }))
  default = {
    AA_Default = {
      function                 = "MAX"
      overhead                 = 0.05
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = []
      look_back_period_seconds = 86400
      min                      = 10.0
      max                      = 0
    }
    AA_Resilient = {
      function                 = "MAX"
      overhead                 = 0.30
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = []
      look_back_period_seconds = 604800
      min                      = 10.0
      max                      = 0
    }
    AA_Stability = {
      function                 = "MAX"
      overhead                 = 0.20
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = []
      look_back_period_seconds = 172800
      max                      = 10240.0
      min                      = 10.0
    }
    AA_Protected = {
      function                 = "MAX"
      overhead                 = 0.05
      threshold_type           = "PERCENTAGE"
      threshold_percentage     = 0.3
      limit                    = "KEEP_LIMITS"
      args                     = []
      look_back_period_seconds = 86400
      min                      = 10.0
      max                      = 0
    }
  }
}

variable "castai_workload_policies_startup" {
  description = "Startup period_seconds for each workload scaling policy"
  type = map(object({
    period_seconds = optional(number, 300)
  }))
  default = {
    AA_Default = {
      period_seconds = 300
    }
    AA_Resilient = {
      period_seconds = 300
    }
    AA_Stability = {
      period_seconds = 300
    }
    AA_Protected = {
      period_seconds = 300
    }
  }
}

variable "castai_workload_policies_downscaling" {
  description = "Downscaling settings for each workload scaling policy"
  type = map(object({
    apply_type = optional(string, "IMMEDIATE")
  }))
  default = {
    AA_Default = {
      apply_type = "IMMEDIATE"
    }
    AA_Resilient = {
      apply_type = "IMMEDIATE"
    }
    AA_Stability = {
      apply_type = "IMMEDIATE"
    }
    AA_Protected = {
      apply_type = "IMMEDIATE"
    }
  }
}

variable "castai_workload_policies_memory_event" {
  description = "Memory event settings for each workload scaling policy"
  type = map(object({
    apply_type = optional(string, "IMMEDIATE")
  }))
  default = {
    AA_Default = {
      apply_type = "IMMEDIATE"
    }
    AA_Resilient = {
      apply_type = "IMMEDIATE"
    }
    AA_Stability = {
      apply_type = "IMMEDIATE"
    }
    AA_Protected = {
      apply_type = "IMMEDIATE"
    }
  }
}
variable "castai_workload_policies_anti_affinity" {
  description = "Anti-affinity settings for each workload scaling policy"
  type = map(object({
    consider_anti_affinity = optional(bool, true)
  }))
  default = {
    AA_Default = {
      consider_anti_affinity = true
    }
    AA_Resilient = {
      consider_anti_affinity = true
    }
    AA_Stability = {
      consider_anti_affinity = true
    }
    AA_Protected = {
      consider_anti_affinity = true
    }
  }
}

variable "castai_workload_policies_confidence" {
  description = "Confidence threshold for each workload scaling policy"
  type = map(object({
    threshold = optional(number, 0.9)
  }))
  default = {
    AA_Default = {
      threshold = 0.9
    }
    AA_Resilient = {
      threshold = 0.9
    }
    AA_Stability = {
      threshold = 0.9
    }
    AA_Protected = {
      threshold = 0.9
    }
  }
}
variable "castai_autoscaler_settings" {
  description = "Settings for CastAI autoscaler"
  type = object({
    enabled                                 = bool
    is_scoped_mode                          = bool
    node_templates_partial_matching_enabled = bool
    unschedulable_pods = object({
      enabled = bool
      headroom = object({
        enabled           = bool
        cpu_percentage    = number
        memory_percentage = number
      })
      pod_pinner = object({
        enabled = bool
      })
    })
    cluster_limits = object({
      enabled = bool
      cpu = object({
        min_cores = number
        max_cores = number
      })
    })
    node_downscaler = object({
      enabled = bool
      empty_nodes = object({
        enabled       = bool
        delay_seconds = optional(number, 60)
      })
      evictor = object({
        aggressive_mode           = bool
        cycle_interval            = string
        dry_run                   = bool
        enabled                   = bool
        node_grace_period_minutes = number
        scoped_mode               = bool
      })
    })
  })
  default = {
    enabled                                 = true # changing to true to enable castai node autoscaler
    is_scoped_mode                          = false
    node_templates_partial_matching_enabled = true # changing to true to enable castai node autoscaler
    unschedulable_pods = {
      enabled = true # changing to true to enable castai node autoscaler
      headroom = {
        enabled           = true
        cpu_percentage    = 0
        memory_percentage = 0
      }
      pod_pinner = {
        enabled = true
      }
    }
    cluster_limits = {
      enabled = false
      cpu = {
        min_cores = 1
        max_cores = 200
      }
    }
    node_downscaler = {
      enabled = true # changing to true to enable castai node autoscaler
      empty_nodes = {
        enabled       = true # changing to true to enable castai node autoscaler
        delay_seconds = 60   # in seconds , delete naturally emptied nodes after 1 minute, aks cast autoscale default is 10 minutes and cast default is 5 mins
      }
      evictor = {
        aggressive_mode           = false
        cycle_interval            = "1m"
        dry_run                   = false
        enabled                   = true # changing to true to enable castai node autoscaler for better downscaling and bin packing
        node_grace_period_minutes = 10
        scoped_mode               = false
      }
    }
  }
}

# castai aks node configurations variables
variable "castai_aks_node_configurations" {
  type        = any
  description = "Map of AKS node configurations to create"
  default = {
    aa_castai_node_conf_default = {
      disk_cpu_ratio    = 8
      min_disk_size     = 200
      max_pods_per_node = 250
      aks_image_family  = "ubuntu"
      drain_timeout_sec = 300
      tags = {
        "castai_node_config" : "aa_castai_node_conf_default"
      }
      aks_ephemeral_os_disk = [
        {
          placement = "resourceDisk" # cacheDisk or resourceDisk
          # Cache-related settings are not used when placement = "resourceDisk" (ephemeral storage without cache), but are kept here as a reference for potential future use with cacheDisk.
          ## cache     = "ReadOnly"     # ReadOnly or ReadWrite, #ReadWrite fails for some VMS , example: standard_E4s_v5

        }
      ]
    },
    aa_castai_node_conf_spot_default = {
      min_disk_size     = 30
      max_pods_per_node = 100
      aks_image_family  = "ubuntu"
      drain_timeout_sec = 0
      tags = {
        "castai_node_config" : "aa_castai_node_conf_spot_default"
      }
    }
  }
}
#this will be passed dynamic through the module reading the map above, do not fill it here
variable "castai_default_node_configuration" {
  type        = string
  description = "ID of the default node configuration"
  default     = ""
}

variable "castai_default_node_configuration_name" {
  type        = string
  description = "Name of the default node configuration"
  default     = "aa_castai_node_conf_default"
}
variable "castai_aks_node_templates" {
  type        = any
  description = "Map of AKS node templates to create"
  default = {
    # creating spot template as place holder if needed in future
    aa_castai_spot_tmpl = {
      castai_node_configuration_name = "aa_castai_node_conf_spot_default"
      is_default                     = false
      should_taint                   = true

      custom_labels = {
        aa_castai_agent = "aa_castai_spot"
      }
      # not adding taints for cast created nodes for now
      # custom_taints = [
      #   {
      #     key    = "custom-taint-key-1"
      #     value  = "custom-taint-value-1"
      #     effect = "NoSchedule"
      #   }
      # ]
      constraints = {
        fallback_restore_rate_seconds = 1800
        spot                          = true
        use_spot_fallbacks            = true
        min_cpu                       = 4
        max_cpu                       = 100
        instance_families = {
          exclude = ["standard_DPLSv5"]
        }
        compute_optimized_state = "disabled"
        storage_optimized_state = "disabled"
      }
    },
    #agent pool : aa_worker_castai # all apps pool
    aa_worker_castai_default_tmpl = {
      castai_node_configuration_name = "aa_castai_node_conf_default"
      is_default                     = false
      should_taint                   = false
      custom_labels = {
        aa_castai_agentpool = "common" #common for gen01gen03 webapps workloads for now
        # aa_castai_agentpool = "aa_castai_default"
        #we cannot use "agentpool" as label as it is reserved by AKS and cast with cast worker nodes
        #this label will be used in rebalancing schedule to identify the nodes and this
      }
      constraints = {
        fallback_restore_rate_seconds = 1800
        #for lab cluster using spot only, this will change to on demand only for nonprod and prod
        on_demand               = true
        spot                    = false
        use_spot_fallbacks      = false # not using spot for worker pool
        compute_optimized_state = "disabled"
        storage_optimized_state = "disabled"
        is_gpu_only             = false
        min_cpu                 = 8      # min cpu cores
        max_cpu                 = 32     # max cpu cores
        min_memory              = 4096   # in Mib - 4GiB
        max_memory              = 262144 # in Mib - 256GiB
        architectures           = ["amd64"]
        azs                     = []
        burstable_instances     = "disabled"
        customer_specific       = "disabled"
        # optional instance families
        # instance_families = {
        #   # mix of E and D series with more preference to Dsv5 which has cost savings
        #   include = ["standard_DSv4","standard_DSv5","standard_DASv5","standard_DADSv5","standard_DADSv6","standard_DADSv7","standard_ESv4","standard_ESv5","standard_ESv6","standard_EDSv4","standard_EDSv5","standard_EDSv6","standard_EADSv4","standard_EADSv5","standard_EADSv6","standard_EADSv7","standard_EASv7"]
        # }
        custom_priority = {
          # give priority to ephermal storage enabled instances
          instance_families = ["standard_DADSv5", "standard_DADSv6", "standard_DADSv7", "standard_EADSv4", "standard_EADSv5", "standard_EADSv6", "standard_EADSv7"]
          #for nonprod cluster we are using on demand only for now
          spot      = false
          on_demand = true
        }
      }
    },
    aa_worker_castai_conductor_tmpl = {
      castai_node_configuration_name = "aa_castai_node_conf_default"
      is_default                     = false
      should_taint                   = true
      custom_taints = [
        {
          key    = "ConductorWorkloadOnly"
          value  = "true"
          effect = "NoSchedule"
        }
      ]
      custom_labels = {
        aa_castai_agentpool = "conductor"
      }
      constraints = {
        fallback_restore_rate_seconds = 1800
        #for lab cluster using spot only, this will change to on demand only for nonprod and prod
        on_demand               = true
        spot                    = false
        use_spot_fallbacks      = false # not using spot for worker pool
        compute_optimized_state = "disabled"
        storage_optimized_state = "disabled"
        is_gpu_only             = false
        min_cpu                 = 16     # min cpu cores
        max_cpu                 = 64     # max cpu cores
        min_memory              = 4096   # in Mib - 4GiB
        max_memory              = 262144 # in Mib - 256GiB
        architectures           = ["amd64"]
        azs                     = []
        burstable_instances     = "disabled"
        customer_specific       = "disabled"
        custom_priority = {
          # give priority to ephermal storage enabled instances
          instance_families = ["standard_DADSv5", "standard_DADSv6", "standard_DADSv7", "standard_EADSv4", "standard_EADSv5", "standard_EADSv6", "standard_EADSv7"]
          spot              = false
          on_demand         = true
        }
      }
    }
  }
}
variable "castai_aks_rebalancing_schedules" {
  type        = any
  description = "Map of AKS rebalancing schedules to create"
  default = {
    aa_castai_worker_default = {
      enabled                  = true
      schedule_cron            = "CRON_TZ=America/Chicago 0 21 */1 * *" # cental time zone
      savings_percentage       = 10                                     # at least 10% savings to trigger the rebalancing schedule
      node_ttl_seconds         = 300
      num_targeted_nodes       = 10
      rebalancing_min_nodes    = 1
      keep_drain_timeout_nodes = false
      node_selector = [
        # include the nodes that needs to be rebalanced, cast selects nodes based on labels
        {
          key      = "aa_castai_agentpool"
          operator = "In"
          values   = "common"
        }
      ]
      execution_conditions_enabled = false # disable this settings to avoid restarts
      achieved_savings_percentage  = 5     # at least 5% savings needs to be achieved else newly created nodes gets removed
    }
  }
}
