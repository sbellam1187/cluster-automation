variable "app_sdlc_environment" {
  description = "app_sdlc_environment like lab/nonprod/prod"
  type        = string
}

variable "namespace" {
  description = "Name of the namespace user inputs for creating"
  type        = string
}

variable "kubernetes_ca_cert" {
  description = "Kubernetes CA cert - Cluster on which the SA is created"
  type        = string
}

variable "kubernetes_host" {
  description = "Kubernetes Host - cluster which this SA is created"
  type        = string
}
variable "service_account_name" {
  description = "This is the name of the serviceaccount being created by the user"
  type        = string

}

variable "additional_labels" {
  description = "providing additional labels for the namespace"
  type        = map(string)
  default     = {} # Users can provide extra labels, but defaults stay unchanged
}

variable "secret_path" {
  description = "This will be the folder which will include all the secrets in vault"
  type        = string
}
