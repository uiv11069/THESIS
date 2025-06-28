output "DB_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.db_server.fully_qualified_domain_name
}

output "DB_admin" {
  description = "The admin username for the SQL Server"
  value       = azurerm_mssql_server.db_server.administrator_login
}

output "DB_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.db.name
}
