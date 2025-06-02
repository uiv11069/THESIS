output "db_connection_string" {
  description = "Database connection string"
  value       = "postgresql://${azurerm_postgresql_flexible_server.db.administrator_login}@${azurerm_postgresql_flexible_server.db.fqdn}/${azurerm_postgresql_flexible_server_database.thesis_db.name}"
  sensitive   = true
}

output "db_fqdn" {
  description = "The FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.db.fqdn
}

output "db_admin" {
  description = "The admin username for the database"
  value       = azurerm_postgresql_flexible_server.db.administrator_login
}
