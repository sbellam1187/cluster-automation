locals {
  castai_sp_object_id             = var.app_sdlc_environment == "prod" ? "3467473d-8571-43ae-a08c-c38af458cd6b" : "fa598c62-f383-451d-b136-94f73d226b14" # Enterprise application ID of the service principals "dt-p-KaaS-castai-sp"&"dt-n-KaaS-castai-sp"
  castai_sp_client_id             = var.app_sdlc_environment == "prod" ? "6905b8f5-5ae2-48c9-a5f1-283d40fb4cfc" : "21a4eddc-58e2-442a-81a8-5a9bfdea1600" # Client application ID of the service principals "dt-p-KaaS-castai-sp"&"dt-n-KaaS-castai-sp"
  subscription_id                 = var.app_sdlc_environment == "prod" ? "e540da57-5250-45d5-9c19-74c5de18d0ab" : "2fe97b8d-f7b5-4964-85b0-48740441865e" # Subscription name based on environment
  aks_cluster_resource_group_name = var.app_sdlc_environment == "prod" ? "dx-runway-core-prod" : "dx-runway-core-np"                                     # Cluster resource group name based on environment
  castai_custom_role_name         = var.app_sdlc_environment == "prod" ? "CastaiAKSRole-prod" : "CastaiAKSRole-nonprod"                                  # Custom role name for Castai
}
