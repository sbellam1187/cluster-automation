# Note: It might make a lot of sense for this to be a terraform module,
# that is managed within or besides this git repo:
# https://github.com/AAInternal/runway-kubernetes-cluster-container-registry-update

# Begin - Container Registry Access
resource "kubernetes_namespace" "container_registry_update" {
  metadata {
    name = "container-registry-update"

    labels = {
      "kubernetes.io/metadata.name"           = "container-registry-update",
      "runway.aa.com/k8s-bootstrap-component" = "true"
    }

    annotations = {
      "scheduler.alpha.kubernetes.io/defaultTolerations" = var.env_based_namespace_tolerations[var.app_sdlc_environment]
      "scheduler.alpha.kubernetes.io/node-selector"      = var.node_selector_annotation
    }
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_secret" "initial_registry_creds" {
  metadata {
    name      = "${var.registry_server}.registry.creds"
    namespace = kubernetes_namespace.container_registry_update.id
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.registry_server) = {
          "username" = var.registry_username
          "password" = var.registry_password # TODO: We need to pass this in.
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
  lifecycle {
    ignore_changes = all
  }
}
resource "kubernetes_service_account" "container_registry_update" {
  metadata {
    name      = "container-registry-update-sa"
    namespace = kubernetes_namespace.container_registry_update.id

    labels = {
      app                         = "container-registry-update"
      "app.kubernetes.io/name"    = "container-registry-update"
      "app.kubernetes.io/part-of" = "container-registry-update"
    }
  }

  lifecycle {
    ignore_changes = all
  }
}
resource "kubernetes_cluster_role" "container_registry_update" {
  metadata {
    name = "container-registry-update"

    labels = {
      app                         = "container-registry-update"
      "app.kubernetes.io/name"    = "container-registry-update"
      "app.kubernetes.io/part-of" = "container-registry-update"
    }
  }

  rule {
    verbs      = ["patch", "update", "create"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["list", "get"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_cluster_role_binding" "container_registry_update" {
  metadata {
    name = "container-registry-update"

    labels = {
      app                         = "container-registry-update"
      "app.kubernetes.io/name"    = "container-registry-update"
      "app.kubernetes.io/part-of" = "container-registry-update"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "container-registry-update-sa"
    namespace = "container-registry-update"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "container-registry-update"
  }

  lifecycle {
    ignore_changes = all
  }
}

## Deployment

resource "kubernetes_deployment" "container-registry-update" {
  metadata {
    name      = "container-registry-update"
    namespace = "container-registry-update"
  }
  wait_for_rollout = false
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "container-registry-update"
      }
    }

    template {
      metadata {
        labels = merge(var.additional_labels, { app = "container-registry-update" })
      }

      spec {

        image_pull_secrets {
          name = "${var.registry_server}.registry.creds"
        }
        restart_policy       = "Always"
        service_account_name = "container-registry-update-sa"
        dns_policy           = "ClusterFirst"

        container {
          image = "${var.registry_server}/prod/runway-kubernetes-cluster-container-registry-update:${var.container_registry_update_container_tag}"
          name  = "container-registry-update"
          env {
            name  = "SLEEP_TIME"
            value = "900"
          }
          env_from {
            config_map_ref {
              name = "workload-identity-cm"
            }
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
            requests = {
              cpu    = "300m"
              memory = "250Mi"
            }
          }
        }

        # This will build a list of tolerations from the variable, based on the environment.
        dynamic "toleration" {
          for_each = var.env_based_pod_tolerations[var.app_sdlc_environment]
          content {
            operator = toleration.value["operator"]
            effect   = toleration.value["effect"]
            key      = toleration.value["key"]
            value    = toleration.value["value"]
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [kubernetes_namespace.container_registry_update]
}
# End - Container Registry Access
