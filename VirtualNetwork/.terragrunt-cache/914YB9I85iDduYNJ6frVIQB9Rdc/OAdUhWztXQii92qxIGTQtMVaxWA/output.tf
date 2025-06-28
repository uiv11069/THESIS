output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.main_vnet.name
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.main_vnet.id
}

output "subnet_name" {
  description = "The name of the Subnet"
  value       = azurerm_subnet.main_subnet.name
}

output "subnet_id" {
  description = "The ID of the Subnet"
  value       = azurerm_subnet.main_subnet.id
}

output "appservice_subnet_id" {
  description = "ID of the App Service Subnet"
  value       = azurerm_subnet.appservice_subnet.id
}
