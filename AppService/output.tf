output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.app.name
}

output "app_service_url" {
  description = "The default URL of the App Service"
  value       = azurerm_linux_web_app.app.default_hostname
}
