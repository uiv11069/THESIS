provider "azurerm" {
  features {}
  subscription_id = "da9a301e-7a82-4e73-abb1-e28a503a0adf"
}

resource "azurerm_resource_group" "acr_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = var.acr_sku
  admin_enabled       = true

  tags = {
    environment = "dev"
  }
}
