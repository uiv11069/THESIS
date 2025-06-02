provider "azurerm" {
  features {}
  subscription_id = "da9a301e-7a82-4e73-abb1-e28a503a0adf"
}

resource "azurerm_resource_group" "storage_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = azurerm_resource_group.storage_rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = var.tags
}
