BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.4 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 2.15.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.18.0 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | 7.73.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.18.0 |
| <a name="provider_castai"></a> [castai](#provider\_castai) | 7.73.1 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_app_sdlc_environment"></a> [app\_sdlc\_environment](#input\_app\_sdlc\_environment) | app\_sdlc\_environment | `string` | yes |
| <a name="input_devexp_cluster_name"></a> [devexp\_cluster\_name](#input\_devexp\_cluster\_name) | Development experience cluster name | `string` | yes |
| <a name="input_devexp_cluster_num"></a> [devexp\_cluster\_num](#input\_devexp\_cluster\_num) | Development experience cluster number | `string` | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region location | `string` | yes |
| <a name="input_castai_aks_node_configurations"></a> [castai\_aks\_node\_configurations](#input\_castai\_aks\_node\_configurations) | Map of AKS node configurations to create | `any` | no |
| <a name="input_castai_aks_node_templates"></a> [castai\_aks\_node\_templates](#input\_castai\_aks\_node\_templates) | Map of AKS node templates to create | `any` | no |
| <a name="input_castai_aks_rebalancing_schedules"></a> [castai\_aks\_rebalancing\_schedules](#input\_castai\_aks\_rebalancing\_schedules) | Map of AKS rebalancing schedules to create | `any` | no |
| <a name="input_castai_api_token"></a> [castai\_api\_token](#input\_castai\_api\_token) | CAST AI API token created in console.cast.ai API Access keys section. | `string` | no |
| <a name="input_castai_api_url"></a> [castai\_api\_url](#input\_castai\_api\_url) | CAST AI url to API, default value is https://api.cast.ai | `string` | no |
| <a name="input_castai_apply_type"></a> [castai\_apply\_type](#input\_castai\_apply\_type) | Apply type for each CAST AI scaling policy | `map(string)` | no |
| <a name="input_castai_assignment_rules"></a> [castai\_assignment\_rules](#input\_castai\_assignment\_rules) | Assignment rules for each CAST AI scaling policy based on namespaces | `map(list(string))` | no |
| <a name="input_castai_autoscaler_settings"></a> [castai\_autoscaler\_settings](#input\_castai\_autoscaler\_settings) | Settings for CastAI autoscaler | <pre>object({<br>    enabled                                 = bool<br>    is_scoped_mode                          = bool<br>    node_templates_partial_matching_enabled = bool<br>    unschedulable_pods = object({<br>      enabled = bool<br>      headroom = object({<br>        enabled           = bool<br>        cpu_percentage    = number<br>        memory_percentage = number<br>      })<br>      pod_pinner = object({<br>        enabled = bool<br>      })<br>    })<br>    cluster_limits = object({<br>      enabled = bool<br>      cpu = object({<br>        min_cores = number<br>        max_cores = number<br>      })<br>    })<br>    node_downscaler = object({<br>      enabled = bool<br>      empty_nodes = object({<br>        enabled = bool<br>      })<br>      evictor = object({<br>        aggressive_mode           = bool<br>        cycle_interval            = string<br>        dry_run                   = bool<br>        enabled                   = bool<br>        node_grace_period_minutes = number<br>        scoped_mode               = bool<br>      })<br>    })<br>  })</pre> | no |
| <a name="input_castai_default_node_configuration"></a> [castai\_default\_node\_configuration](#input\_castai\_default\_node\_configuration) | ID of the default node configuration | `string` | no |
| <a name="input_castai_default_node_configuration_name"></a> [castai\_default\_node\_configuration\_name](#input\_castai\_default\_node\_configuration\_name) | Name of the default node configuration | `string` | no |
| <a name="input_castai_management_option"></a> [castai\_management\_option](#input\_castai\_management\_option) | Management option for each CAST AI scaling policy | `map(string)` | no |
| <a name="input_castai_node_autoscale_enable"></a> [castai\_node\_autoscale\_enable](#input\_castai\_node\_autoscale\_enable) | Varaible to specify the condition to enable castai node autoscalling | `bool` | no |
| <a name="input_castai_sp_client_secret"></a> [castai\_sp\_client\_secret](#input\_castai\_sp\_client\_secret) | Service principal secret for castai | `string` | no |
| <a name="input_castai_workload_policies_anti_affinity"></a> [castai\_workload\_policies\_anti\_affinity](#input\_castai\_workload\_policies\_anti\_affinity) | Anti-affinity settings for each workload scaling policy | <pre>map(object({<br>    consider_anti_affinity = optional(bool, true)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_confidence"></a> [castai\_workload\_policies\_confidence](#input\_castai\_workload\_policies\_confidence) | Confidence threshold for each workload scaling policy | <pre>map(object({<br>    threshold = optional(number, 0.9)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_cpu"></a> [castai\_workload\_policies\_cpu](#input\_castai\_workload\_policies\_cpu) | CPU settings for each workload scaling policy | <pre>map(object({<br>    function                 = optional(string, "QUANTILE")<br>    overhead                 = optional(number, 0.10)<br>    threshold_type           = optional(string, "PERCENTAGE")<br>    threshold_percentage     = optional(number, 0.3)<br>    limit                    = optional(string, "KEEP_LIMITS")<br>    args                     = optional(number, 0.95)<br>    look_back_period_seconds = optional(number, 86400)<br>    min                      = optional(number, 0.01)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_downscaling"></a> [castai\_workload\_policies\_downscaling](#input\_castai\_workload\_policies\_downscaling) | Downscaling settings for each workload scaling policy | <pre>map(object({<br>    apply_type = optional(string, "IMMEDIATE")<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_memory"></a> [castai\_workload\_policies\_memory](#input\_castai\_workload\_policies\_memory) | Memory settings for each workload scaling policy | <pre>map(object({<br>    function                 = optional(string, "MAX")<br>    overhead                 = optional(number, 0.05)<br>    threshold_type           = optional(string, "PERCENTAGE")<br>    threshold_percentage     = optional(number, 0.3)<br>    limit                    = optional(string, "KEEP_LIMITS")<br>    args                     = optional(list(string), [])<br>    look_back_period_seconds = optional(number, 86400)<br>    min                      = optional(number, 10.0)<br>    max                      = optional(number, 0)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_memory_event"></a> [castai\_workload\_policies\_memory\_event](#input\_castai\_workload\_policies\_memory\_event) | Memory event settings for each workload scaling policy | <pre>map(object({<br>    apply_type = optional(string, "IMMEDIATE")<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_startup"></a> [castai\_workload\_policies\_startup](#input\_castai\_workload\_policies\_startup) | Startup period\_seconds for each workload scaling policy | <pre>map(object({<br>    period_seconds = optional(number, 300)<br>  }))</pre> | no |
| <a name="input_delete_nodes_on_disconnect"></a> [delete\_nodes\_on\_disconnect](#input\_delete\_nodes\_on\_disconnect) | Optionally delete Cast AI created nodes when the cluster is destroyed. | `bool` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure tenant ID | `string` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.4 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 2.15.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.18.0 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | 7.73.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.18.0 |
| <a name="provider_castai"></a> [castai](#provider\_castai) | 7.73.1 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_app_sdlc_environment"></a> [app\_sdlc\_environment](#input\_app\_sdlc\_environment) | app\_sdlc\_environment | `string` | yes |
| <a name="input_devexp_cluster_name"></a> [devexp\_cluster\_name](#input\_devexp\_cluster\_name) | Development experience cluster name | `string` | yes |
| <a name="input_devexp_cluster_num"></a> [devexp\_cluster\_num](#input\_devexp\_cluster\_num) | Development experience cluster number | `string` | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region location | `string` | yes |
| <a name="input_castai_aks_node_configurations"></a> [castai\_aks\_node\_configurations](#input\_castai\_aks\_node\_configurations) | Map of AKS node configurations to create | `any` | no |
| <a name="input_castai_aks_node_templates"></a> [castai\_aks\_node\_templates](#input\_castai\_aks\_node\_templates) | Map of AKS node templates to create | `any` | no |
| <a name="input_castai_aks_rebalancing_schedules"></a> [castai\_aks\_rebalancing\_schedules](#input\_castai\_aks\_rebalancing\_schedules) | Map of AKS rebalancing schedules to create | `any` | no |
| <a name="input_castai_api_token"></a> [castai\_api\_token](#input\_castai\_api\_token) | CAST AI API token created in console.cast.ai API Access keys section. | `string` | no |
| <a name="input_castai_api_url"></a> [castai\_api\_url](#input\_castai\_api\_url) | CAST AI url to API, default value is https://api.cast.ai | `string` | no |
| <a name="input_castai_apply_type"></a> [castai\_apply\_type](#input\_castai\_apply\_type) | Apply type for each CAST AI scaling policy | `map(string)` | no |
| <a name="input_castai_assignment_rules"></a> [castai\_assignment\_rules](#input\_castai\_assignment\_rules) | Assignment rules for each CAST AI scaling policy based on namespaces | `map(list(string))` | no |
| <a name="input_castai_autoscaler_settings"></a> [castai\_autoscaler\_settings](#input\_castai\_autoscaler\_settings) | Settings for CastAI autoscaler | <pre>object({<br>    enabled                                 = bool<br>    is_scoped_mode                          = bool<br>    node_templates_partial_matching_enabled = bool<br>    unschedulable_pods = object({<br>      enabled = bool<br>      headroom = object({<br>        enabled           = bool<br>        cpu_percentage    = number<br>        memory_percentage = number<br>      })<br>      pod_pinner = object({<br>        enabled = bool<br>      })<br>    })<br>    cluster_limits = object({<br>      enabled = bool<br>      cpu = object({<br>        min_cores = number<br>        max_cores = number<br>      })<br>    })<br>    node_downscaler = object({<br>      enabled = bool<br>      empty_nodes = object({<br>        enabled       = bool<br>        delay_seconds = optional(number, 60)<br>      })<br>      evictor = object({<br>        aggressive_mode           = bool<br>        cycle_interval            = string<br>        dry_run                   = bool<br>        enabled                   = bool<br>        node_grace_period_minutes = number<br>        scoped_mode               = bool<br>      })<br>    })<br>  })</pre> | no |
| <a name="input_castai_default_node_configuration"></a> [castai\_default\_node\_configuration](#input\_castai\_default\_node\_configuration) | ID of the default node configuration | `string` | no |
| <a name="input_castai_default_node_configuration_name"></a> [castai\_default\_node\_configuration\_name](#input\_castai\_default\_node\_configuration\_name) | Name of the default node configuration | `string` | no |
| <a name="input_castai_management_option"></a> [castai\_management\_option](#input\_castai\_management\_option) | Management option for each CAST AI scaling policy | `map(string)` | no |
| <a name="input_castai_node_autoscale_enable"></a> [castai\_node\_autoscale\_enable](#input\_castai\_node\_autoscale\_enable) | Varaible to specify the condition to enable castai node autoscalling | `bool` | no |
| <a name="input_castai_sp_client_secret"></a> [castai\_sp\_client\_secret](#input\_castai\_sp\_client\_secret) | Service principal secret for castai | `string` | no |
| <a name="input_castai_workload_policies_anti_affinity"></a> [castai\_workload\_policies\_anti\_affinity](#input\_castai\_workload\_policies\_anti\_affinity) | Anti-affinity settings for each workload scaling policy | <pre>map(object({<br>    consider_anti_affinity = optional(bool, true)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_confidence"></a> [castai\_workload\_policies\_confidence](#input\_castai\_workload\_policies\_confidence) | Confidence threshold for each workload scaling policy | <pre>map(object({<br>    threshold = optional(number, 0.9)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_cpu"></a> [castai\_workload\_policies\_cpu](#input\_castai\_workload\_policies\_cpu) | CPU settings for each workload scaling policy. Note: AA\_Protected CPU settings are currently hard-coded in castai.tf and are not configurable via this variable. | <pre>map(object({<br>    function                 = optional(string, "QUANTILE")<br>    overhead                 = optional(number, 0.10)<br>    threshold_type           = optional(string, "PERCENTAGE")<br>    threshold_percentage     = optional(number, 0.3)<br>    limit                    = optional(string, "KEEP_LIMITS")<br>    args                     = optional(number, 0.95)<br>    look_back_period_seconds = optional(number, 86400)<br>    min                      = optional(number, 0.01)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_downscaling"></a> [castai\_workload\_policies\_downscaling](#input\_castai\_workload\_policies\_downscaling) | Downscaling settings for each workload scaling policy | <pre>map(object({<br>    apply_type = optional(string, "IMMEDIATE")<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_memory"></a> [castai\_workload\_policies\_memory](#input\_castai\_workload\_policies\_memory) | Memory settings for each workload scaling policy | <pre>map(object({<br>    function                 = optional(string, "MAX")<br>    overhead                 = optional(number, 0.05)<br>    threshold_type           = optional(string, "PERCENTAGE")<br>    threshold_percentage     = optional(number, 0.3)<br>    limit                    = optional(string, "KEEP_LIMITS")<br>    args                     = optional(list(string), [])<br>    look_back_period_seconds = optional(number, 86400)<br>    min                      = optional(number, 10.0)<br>    max                      = optional(number, 0)<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_memory_event"></a> [castai\_workload\_policies\_memory\_event](#input\_castai\_workload\_policies\_memory\_event) | Memory event settings for each workload scaling policy | <pre>map(object({<br>    apply_type = optional(string, "IMMEDIATE")<br>  }))</pre> | no |
| <a name="input_castai_workload_policies_startup"></a> [castai\_workload\_policies\_startup](#input\_castai\_workload\_policies\_startup) | Startup period\_seconds for each workload scaling policy | <pre>map(object({<br>    period_seconds = optional(number, 300)<br>  }))</pre> | no |
| <a name="input_delete_nodes_on_disconnect"></a> [delete\_nodes\_on\_disconnect](#input\_delete\_nodes\_on\_disconnect) | Optionally delete Cast AI created nodes when the cluster is destroyed. | `bool` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure tenant ID | `string` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
