# Service Account
resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = var.display_name != "" ? var.display_name : var.service_account_name
}

# IAM Role Bindings
resource "google_project_iam_member" "roles" {
  for_each = toset(var.roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.sa.email}"
}
