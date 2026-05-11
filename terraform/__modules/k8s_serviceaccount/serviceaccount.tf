## creating namespace as per user input
resource "kubernetes_namespace_v1" "serviceaccount_namespace" {
  metadata {
    name = var.namespace

    labels = merge(
      {
        "kubernetes.io/metadata.name"           = var.namespace,
        "runway.aa.com/k8s-bootstrap-component" = "true"
      },
      var.additional_labels
    )

  }
  lifecycle {
    ignore_changes = all
  }
}

## creating service account as per user input
resource "kubernetes_service_account_v1" "service_account_name" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace_v1.serviceaccount_namespace.metadata[0].name
  }
  secret {
    name = "${var.service_account_name}-token"
  }
  lifecycle {
    ignore_changes = all
  }
}
## creating a token and ensures that the application doesn't start until the token is successfully retrieved
resource "kubernetes_secret_v1" "service_account_token" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.service_account_name.metadata[0].name
    }
    namespace = kubernetes_namespace_v1.serviceaccount_namespace.metadata[0].name
    name      = "${var.service_account_name}-token"
  }
  lifecycle {
    ignore_changes = all
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
## creating a secret and uploading the secrets to vault
resource "vault_kv_secret_v2" "cluster_config_secret" {
  mount = "secrets"
  name  = "bootstrap/k8s/${var.app_sdlc_environment}/${var.secret_path}"

  custom_metadata {
    max_versions = 10
  }

  data_json = jsonencode(
    {
      kubernetes_ca_cert = var.kubernetes_ca_cert
      kubernetes_host    = var.kubernetes_host
      sa_token           = kubernetes_secret_v1.service_account_token.data.token

    }
  )
}
