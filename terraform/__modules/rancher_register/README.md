# Terraform module: Rancher Registration

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.4 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | ~>8.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~>2.0 |
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | ~>8.2 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_app_sdlc_environment"></a> [app\_sdlc\_environment](#input\_app\_sdlc\_environment) | app\_sdlc\_environment | `string` | yes |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | cloud provider of the cluster | `string` | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | full cluster name | `string` | yes |
| <a name="input_container_registry_update_container_tag"></a> [container\_registry\_update\_container\_tag](#input\_container\_registry\_update\_container\_tag) | The image tag to use for the container registry update container. | `string` | yes |
| <a name="input_dx_cluster_name"></a> [dx\_cluster\_name](#input\_dx\_cluster\_name) | short name of the cluster | `string` | yes |
| <a name="input_location"></a> [location](#input\_location) | location | `string` | yes |
| <a name="input_registry_password"></a> [registry\_password](#input\_registry\_password) | registry\_password | `string` | yes |
| <a name="input_registry_username"></a> [registry\_username](#input\_registry\_username) | registry\_username | `string` | yes |
| <a name="input_additional_labels"></a> [additional\_labels](#input\_additional\_labels) | Additional labels to apply to Kubernetes resources | `map(string)` | no |
| <a name="input_allowed_aad_groups"></a> [allowed\_aad\_groups](#input\_allowed\_aad\_groups) | allowed aad groups for runway to filter on clusters | `string` | no |
| <a name="input_azad_mgmt_group_admin_reader"></a> [azad\_mgmt\_group\_admin\_reader](#input\_azad\_mgmt\_group\_admin\_reader) | azad\_mgmt\_group\_admin\_reader | `string` | no |
| <a name="input_azad_mgmt_group_owner"></a> [azad\_mgmt\_group\_owner](#input\_azad\_mgmt\_group\_owner) | azad\_mgmt\_group\_owner | `map(string)` | no |
| <a name="input_azad_mgmt_group_reader"></a> [azad\_mgmt\_group\_reader](#input\_azad\_mgmt\_group\_reader) | azad\_mgmt\_group\_reader | `map(string)` | no |
| <a name="input_azad_runway_automation_zaccount"></a> [azad\_runway\_automation\_zaccount](#input\_azad\_runway\_automation\_zaccount) | azad\_runway\_automation\_zaccount | `map(string)` | no |
| <a name="input_env_based_namespace_tolerations"></a> [env\_based\_namespace\_tolerations](#input\_env\_based\_namespace\_tolerations) | A list of default tolerations that should be passed into k8s namespaces created via Terraform | `map(string)` | no |
| <a name="input_env_based_pod_tolerations"></a> [env\_based\_pod\_tolerations](#input\_env\_based\_pod\_tolerations) | A list of tolerations that should be passed into k8s pods created via Terraform | `map(list(map(string)))` | no |
| <a name="input_node_selector_annotation"></a> [node\_selector\_annotation](#input\_node\_selector\_annotation) | node\_selector\_annotation | `string` | no |
| <a name="input_rancher_url"></a> [rancher\_url](#input\_rancher\_url) | rancher\_url | `map(string)` | no |
| <a name="input_registry_email"></a> [registry\_email](#input\_registry\_email) | registry\_email | `string` | no |
| <a name="input_registry_server"></a> [registry\_server](#input\_registry\_server) | registry\_server | `string` | no |
| <a name="input_runway_status"></a> [runway\_status](#input\_runway\_status) | status of the cluster for runway to identify | `string` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rancher_cluster_id"></a> [rancher\_cluster\_id](#output\_rancher\_cluster\_id) | The Rancher cluster id |
<!-- END_TF_DOCS -->
