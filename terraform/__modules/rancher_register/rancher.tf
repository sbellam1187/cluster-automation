# Import Generic Kubernetes Cluster into Rancher
# Note: At the moment, we do not use the AKS specific import functionality.

resource "rancher2_cluster" "runway_cluster_import_rancher" {
  name        = var.cluster_name
  description = "Generic imported cluster"
  labels = {
    "provider.cattle.io"     = var.cloud_provider
    "dx_cluster_environment" = var.app_sdlc_environment
    "cloud_provider"         = var.cloud_provider
    "cluster_name"           = var.cluster_name
    "dx_cluster_name"        = var.dx_cluster_name
    "location"               = var.location
    "runway_status"          = var.runway_status
  }
}

data "rancher2_principal" "azad_owner" {
  count = (var.app_sdlc_environment == "lab" || var.app_sdlc_environment == "nonprod") ? 1 : 0
  name  = var.azad_mgmt_group_owner[var.app_sdlc_environment]
  type  = "group"
}

data "rancher2_principal" "azad_reader" {
  name = var.azad_mgmt_group_reader[var.app_sdlc_environment]
  type = "group"
}

data "rancher2_principal" "azad_admin_reader" {
  count = var.app_sdlc_environment == "prod" ? 1 : 0
  name  = var.azad_mgmt_group_admin_reader
  type  = "group"
}

data "rancher2_principal" "azad_runway_automation" {
  name = var.azad_runway_automation_zaccount[var.app_sdlc_environment]
  type = "user"
}

resource "rancher2_cluster_role_template_binding" "azad_owner" {
  count              = length(data.rancher2_principal.azad_owner)
  name               = "${rancher2_cluster.runway_cluster_import_rancher.id}-owner"
  cluster_id         = rancher2_cluster.runway_cluster_import_rancher.id
  role_template_id   = "cluster-owner"
  group_principal_id = data.rancher2_principal.azad_owner[0].id
}

resource "rancher2_cluster_role_template_binding" "azad_reader" {
  name               = "${rancher2_cluster.runway_cluster_import_rancher.id}-reader"
  cluster_id         = rancher2_cluster.runway_cluster_import_rancher.id
  role_template_id   = "kpaas-readonly"
  group_principal_id = data.rancher2_principal.azad_reader.id
}

resource "rancher2_cluster_role_template_binding" "azad_admin_reader" {
  count              = var.app_sdlc_environment == "prod" ? 1 : 0
  name               = "${rancher2_cluster.runway_cluster_import_rancher.id}-admin-reader"
  cluster_id         = rancher2_cluster.runway_cluster_import_rancher.id
  role_template_id   = "kpaas-admin-readonly"
  group_principal_id = data.rancher2_principal.azad_admin_reader[0].id
}

resource "rancher2_cluster_role_template_binding" "azad_runway_automation" {
  name              = "${rancher2_cluster.runway_cluster_import_rancher.id}-runwayautomation"
  cluster_id        = rancher2_cluster.runway_cluster_import_rancher.id
  role_template_id  = "cluster-owner"
  user_principal_id = data.rancher2_principal.azad_runway_automation.id
}
#
# === Begin Kubernetes Manifests for Rancher Agent
#


# Cluster role
resource "kubernetes_cluster_role" "proxy_clusterrole_kubeapiserver" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name = "proxy-clusterrole-kubeapiserver"
  }
  rule {
    verbs      = ["get", "list", "watch", "create"]
    api_groups = [""]
    resources  = ["nodes/metrics", "nodes/proxy", "nodes/stats", "nodes/log", "nodes/spec"]
  }

}

# Cluster role binding
resource "kubernetes_cluster_role_binding" "proxy_role_binding_kubernetes_master" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name = "proxy-role-binding-kubernetes-master"
  }
  subject {
    kind = "User"
    name = "kube-apiserver"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.proxy_clusterrole_kubeapiserver.metadata[0].name
  }

}

# Namespaces (pre-create Rancher namespaces)

resource "kubernetes_namespace" "cattle_fleet_system" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name = "cattle-fleet-system"
    annotations = {
      "scheduler.alpha.kubernetes.io/defaultTolerations" = var.env_based_namespace_tolerations[var.app_sdlc_environment]
      "scheduler.alpha.kubernetes.io/node-selector"      = var.node_selector_annotation
    }
  }
}


resource "kubernetes_namespace" "cattle_system" {
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["field.cattle.io/projectId"],
      metadata[0].annotations["kopf.zalando.org/last-handled-configuration"],
      metadata[0].annotations["field.cattle.io/projectId"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
      metadata[0].annotations["management.cattle.io/no-default-sa-token"],
      metadata[0].labels,
    ]
  }
  metadata {
    name = "cattle-system"
    annotations = {
      "scheduler.alpha.kubernetes.io/defaultTolerations" = var.env_based_namespace_tolerations[var.app_sdlc_environment]
      "scheduler.alpha.kubernetes.io/node-selector"      = var.node_selector_annotation
    }
  }
}

# Service account
resource "kubernetes_service_account" "cattle" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name      = "cattle"
    namespace = kubernetes_namespace.cattle_system.metadata[0].name
  }
}

# Cluster role binding
resource "kubernetes_cluster_role_binding" "cattle_admin_binding" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name = "cattle-admin-binding"
    labels = {
      "cattle.io/creator" = "norman"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cattle.metadata[0].name
    namespace = kubernetes_namespace.cattle_system.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cattle_admin.metadata[0].name
  }

}

# Registration Secret
resource "kubernetes_secret" "cattle_credentials_az" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name      = "cattle-agent-credentials"
    namespace = kubernetes_namespace.cattle_system.metadata[0].name
  }
  data = {
    token = rancher2_cluster.runway_cluster_import_rancher.cluster_registration_token[0].token
    url   = var.rancher_url[var.app_sdlc_environment]
  }
  type = "Opaque"
}

# Cluster role
resource "kubernetes_cluster_role" "cattle_admin" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name = "cattle-admin"
    labels = {
      "cattle.io/creator" = "norman"
    }
  }
  rule {
    verbs      = ["*"]
    api_groups = ["*"]
    resources  = ["*"]
  }
  rule {
    verbs             = ["*"]
    non_resource_urls = ["*"]
  }

}

# Rancher settings
data "rancher2_setting" "server_version" {
  name = "server-version"
}

data "rancher2_setting" "install_uuid" {
  name = "install-uuid"
}

data "rancher2_setting" "server_url" {
  name = "server-url"
}

# === Start Kubernetes Manifests for Rancher Agent
#
# Deployment
resource "kubernetes_deployment" "cattle_cluster_agent" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name      = "cattle-cluster-agent"
    namespace = kubernetes_namespace.cattle_system.metadata[0].name
    annotations = {
      "management.cattle.io/scale-available" = "2"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "cattle-cluster-agent"
      }
    }
    template {
      metadata {
        labels = {
          app = "cattle-cluster-agent"
        }
      }
      spec {
        volume {
          name = "cattle-credentials"
          secret {
            secret_name  = kubernetes_secret.cattle_credentials_az.metadata[0].name
            default_mode = "0500"
          }
        }
        container {
          name  = "cluster-register"
          image = "registry.rancher.com/rancher/rancher-agent:${data.rancher2_setting.server_version.value}"
          env {
            name  = "CATTLE_IS_RKE"
            value = "false"
          }
          env {
            name  = "CATTLE_SERVER"
            value = data.rancher2_setting.server_url.value
          }
          env {
            name = "CATTLE_CA_CHECKSUM"
          }
          env {
            name  = "CATTLE_CLUSTER"
            value = "true"
          }
          env {
            name  = "CATTLE_K8S_MANAGED"
            value = "true"
          }
          env {
            name = "CATTLE_CLUSTER_REGISTRY"
          }
          env {
            name  = "CATTLE_SERVER_VERSION"
            value = data.rancher2_setting.server_version.value
          }
          env {
            name  = "CATTLE_INSTALL_UUID"
            value = data.rancher2_setting.install_uuid.value
          }
          env {
            name  = "CATTLE_INGRESS_IP_DOMAIN"
            value = "sslip.io"
          }
          volume_mount {
            name       = "cattle-credentials"
            read_only  = true
            mount_path = "/cattle-credentials"
          }
          image_pull_policy = "IfNotPresent"
        }
        service_account_name = "cattle"
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "beta.kubernetes.io/os"
                  operator = "NotIn"
                  values   = ["windows"]
                }
              }
            }
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              preference {
                match_expressions {
                  key      = "node-role.kubernetes.io/controlplane"
                  operator = "In"
                  values   = ["true"]
                }
              }
            }
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              preference {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "In"
                  values   = ["true"]
                }
              }
            }
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              preference {
                match_expressions {
                  key      = "node-role.kubernetes.io/master"
                  operator = "In"
                  values   = ["true"]
                }
              }
            }
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              preference {
                match_expressions {
                  key      = "cattle.io/cluster-agent"
                  operator = "In"
                  values   = ["true"]
                }
              }
            }
          }
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["cattle-cluster-agent"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }
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
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge = "1"
      }
    }
  }
}

# Service definition
resource "kubernetes_service" "cattle_cluster_agent" {
  lifecycle {
    ignore_changes = all
  }
  metadata {
    name      = "cattle-cluster-agent"
    namespace = kubernetes_namespace.cattle_system.metadata[0].name
  }
  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }
    port {
      name        = "https-internal"
      protocol    = "TCP"
      port        = 443
      target_port = "444"
    }
    selector = {
      app = "cattle-cluster-agent"
    }
  }
}

#
# === End Kubernetes Manifests for Rancher Agent
#
