
# Resource Group
resource "azurerm_resource_group" "vnet_rg" {
  name     = var.VirtualNetwork_resource_group_name
  location = var.VirtualNetwork_location
}

# Virtual Network
resource "azurerm_virtual_network" "main_vnet" {
  name                = var.VirtualNetwork_vnet_name
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location
  address_space       = var.VirtualNetwork_address_space

  tags = {
    environment = var.VirtualNetwork_environment
  }
}

# Subnet for AKS (Unchanged)
resource "azurerm_subnet" "main_subnet" {
  name                 = var.VirtualNetwork_subnet_name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = var.VirtualNetwork_subnet_address_prefixes
}

# New Subnet for App Service with Delegation
resource "azurerm_subnet" "appservice_subnet" {
  name                 = "thesis-appservice-subnet"
  resource_group_name  = var.VirtualNetwork_resource_group_name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.2.0/24"]  # New subnet for App Service

  delegation {
    name = "app_service_delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
