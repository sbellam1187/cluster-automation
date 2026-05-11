output "postgresql_server_id" {
  description = "The id of the postgresql server id"
  value       = module.simple_postgres_database.postgresql_server_id
}

output "server_fqdn" {
  description = "The fully qualified domain name (FQDN) of the PostgreSQL server"
  value       = module.simple_postgres_database.server_fqdn
}

output "administrator_login" {
  description = "The Administrator Login for the PostgreSQL Server"
  value       = module.simple_postgres_database.administrator_login
}

output "administrator_password" {
  description = "Password associated with the administrator_login for the PostgreSQL Server"
  value       = module.simple_postgres_database.administrator_password
  sensitive   = true
}

output "database_ids" {
  description = "The list of all database resource ids"
  value       = module.simple_postgres_database.database_ids
}

output "firewall_rule_ids" {
  description = "The list of all firewall rule resource ids"
  value       = module.simple_postgres_database.firewall_rule_ids
}
