variable "rancher_server_url" {
  description = "rancher_server_url"
  type        = string
}

variable "cluster_name" {
  description = "cluster_name"
  type        = string
}

variable "kubernetes_version" {
  description = "kubernetes_version"
  type        = string
}

variable "rancher2_access_key" {
  description = "rancher2_access_key"
  type        = string
}

variable "rancher2_secret_key" {
  description = "rancher2_secret_key"
  type        = string
}

variable "group_role_bindings" {
  description = "List of group principal ids and role template ids"
  type = list(object({
    group_principal_id = string
    role_template_id   = string
    name               = string
  }))
}
