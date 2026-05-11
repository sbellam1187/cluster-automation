variable "app_sdlc_environment" {
  description = "app_sdlc_environment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "kubernetes_ca_cert" {
  description = "Kubernetes CA cert"
  type        = string
}

variable "kubernetes_host" {
  description = "Kubernetes Host"
  type        = string
}

variable "env_based_namespace_tolerations" {
  description = "A list of default tolerations that should be passed into k8s namespaces created via Terraform"
  type        = map(string)
  default = {
    "lab"     = "[{\"operator\": \"Exists\", \"key\": \"SystemWorkload\"},{\"operator\": \"Exists\", \"key\": \"CriticalAddonsOnly\"},{\"operator\":\"Equal\",\"effect\":\"NoSchedule\",\"key\":\"kubernetes.azure.com/scalesetpriority\",\"value\":\"spot\"}]"
    "nonprod" = "[{\"operator\": \"Exists\", \"key\": \"SystemWorkload\"},{\"operator\": \"Exists\", \"key\": \"CriticalAddonsOnly\"}]"
    "prod"    = "[{\"operator\": \"Exists\", \"key\": \"SystemWorkload\"},{\"operator\": \"Exists\", \"key\": \"CriticalAddonsOnly\"}]"
  }
}
