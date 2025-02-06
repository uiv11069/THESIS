provider "azurerm" {
  features {}
  subscription_id = "42f0aa72-9941-46be-a162-e863bd1c1caf"
}

resource "azurerm_resource_group" "vnet_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "main_vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location
  address_space       = var.address_space

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "main_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = var.subnet_address_prefixes
}
