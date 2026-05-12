################################################################################
# Kubernetes Service Accounts and Workload Identity Binding
################################################################################

resource "kubernetes_service_account" "workload_identity" {
  for_each = google_service_account.workload_identity

  metadata {
    name      = "workload-identity-sa"
    namespace = each.key

    annotations = {
      "iam.gke.io/gcp-service-account" = each.value.email
    }
  }

  depends_on = [
    google_container_cluster.main
  ]
}
