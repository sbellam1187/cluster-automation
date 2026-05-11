output "token" {
  description = "JWT Token of the service account"
  value       = kubernetes_secret_v1.service_account_token.data.token
  sensitive   = true
}
