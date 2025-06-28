
resource "azurerm_resource_group" "acr_rg" {
  name     = var.ContainerRegistry_resource_group_name
  location = var.ContainerRegistry_location
}

resource "azurerm_container_registry" "acr" {
  name                = var.ContainerRegistry_acr_name
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = var.ContainerRegistry_acr_sku
  admin_enabled       = true

  tags = {
    environment = "dev"
  }
}
