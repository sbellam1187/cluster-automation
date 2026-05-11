resource "kubernetes_namespace_v1" "vault-operator" {
  metadata {
    name = "vault-secrets-operator-system"

    labels = {
      "kubernetes.io/metadata.name"           = "vault-secrets-operator-system",
      "runway.aa.com/k8s-bootstrap-component" = "true"
    }

    annotations = {
      "scheduler.alpha.kubernetes.io/defaultTolerations" = var.env_based_namespace_tolerations[var.app_sdlc_environment]
      "scheduler.alpha.kubernetes.io/node-selector"      = "agentpool=gen02"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["kopf.zalando.org/last-handled-configuration"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
      metadata[0].labels["dynakube.internal.dynatrace.com/instance"]
    ]
  }
}

resource "kubernetes_service_account_v1" "vault_operator_service_account" {
  image_pull_secret {
    name = "docker.aa.com.registry.creds"
  }
  metadata {
    name      = "vault-secrets-operator-controller-manager"
    namespace = kubernetes_namespace_v1.vault-operator.metadata[0].name
  }
  secret {
    name = "vault-token"
  }
}

resource "kubernetes_secret_v1" "service_account_token" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.vault_operator_service_account.metadata[0].name
    }
    namespace = kubernetes_namespace_v1.vault-operator.metadata[0].name
    name      = "vault-token"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "vault_kv_secret_v2" "k8s_secrets_runway" {
  mount = "kubernetes"
  name  = var.cluster_name

  custom_metadata {
    max_versions = 10
  }

  data_json = jsonencode(
    {
      kubernetes_ca_cert = var.kubernetes_ca_cert
      kubernetes_host    = var.kubernetes_host
      token_reviewer_jwt = kubernetes_secret_v1.service_account_token.data.token
    }
  )
}
