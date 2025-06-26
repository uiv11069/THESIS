output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.minimal_app.name
}

output "container_app_url" {
  description = "Default URL for the Container App"
  value       = azurerm_container_app.minimal_app.latest_revision_fqdn
}
