################################################################################
# Service Account for GKE Cluster
################################################################################

resource "google_service_account" "gke_cluster" {
  account_id   = "${var.cluster_name}-cluster"
  display_name = "GKE Cluster Service Account - ${var.cluster_name}"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_cluster_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_cluster.email}"
}

resource "google_project_iam_member" "gke_cluster_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_cluster.email}"
}

################################################################################
# Service Accounts for Workload Identity
################################################################################

resource "google_service_account" "workload_identity" {
  for_each     = toset(var.workload_identity_namespaces)
  account_id   = "${var.cluster_name}-wi-${each.value}"
  display_name = "Workload Identity - ${var.cluster_name} / ${each.value}"
  project      = var.project_id
}

resource "google_service_account_iam_member" "workload_identity" {
  for_each = google_service_account.workload_identity

  service_account_id = each.value.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.key}/workload-identity-sa]"
}
