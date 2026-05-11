output "service_account" {
  description = "Service account resource"
  value       = google_service_account.sa
}

output "email" {
  description = "Service account email"
  value       = google_service_account.sa.email
}

output "unique_id" {
  description = "Service account unique ID"
  value       = google_service_account.sa.unique_id
}

output "display_name" {
  description = "Service account display name"
  value       = google_service_account.sa.display_name
}
