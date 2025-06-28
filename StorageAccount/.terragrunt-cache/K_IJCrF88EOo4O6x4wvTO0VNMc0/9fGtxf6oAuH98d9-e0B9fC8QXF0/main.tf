

resource "azurerm_resource_group" "storage_rg" {
  name     = var.StorageAccount_resource_group_name
  location = var.StorageAccount_location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.StorageAccount_storage_account_name
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = azurerm_resource_group.storage_rg.location
  account_tier             = var.StorageAccount_account_tier
  account_replication_type = var.StorageAccount_account_replication_type
}
