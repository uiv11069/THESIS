terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "East US"
}

# 2. Create a Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "mystorageacct12345"  # Must be globally unique
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"          # Options: Standard, Premium
  account_replication_type = "LRS"               # Options: LRS, GRS, ZRS, RA-GRS

  tags = {
    environment = "dev"
  }
}

# 3. Create a Blob Storage Container
resource "azurerm_storage_container" "example" {
  name                  = "mycontainer"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private" # Options: private, blob, container
}

# 4. Upload a Blob File (Optional)
resource "azurerm_storage_blob" "example" {
  name                   = "example.txt"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"  # Block blobs are for general file storage
  source                 = "local-path-to-file/example.txt" # Replace with actual file path
}

output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

output "blob_url" {
  value = "https://${azurerm_storage_account.example.name}.blob.core.windows.net/${azurerm_storage_container.example.name}/example.txt"
}
