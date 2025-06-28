generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "terragrunt"
    storage_account_name = "terragrunt2025thesis"
    container_name       = "tfstate"
    key                  = "terragrunt.tfstate"
    access_key  ="9R8pS/sebQqPvbo+32btT7eAhlkfJmF7827cAJ5Rl5CgvsBWo/FGSTezhKBZ8eYdfi1v3xQKWOum+AStM3fk5g=="
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.34.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "da9a301e-7a82-4e73-abb1-e28a503a0adf"
}
EOF
}

inputs = {
  ContainerApp_resource_group_name = "thesis-container-rg"
  ContainerApp_location = "West Europe"
  ContainerApp_app_name = "namecotainerupt"
  ContainerRegistry_resource_group_name = "customtestupt"
  ContainerRegistry_location = "West Europe"
  ContainerRegistry_acr_name = "numeacrupttest"
  ContainerRegistry_acr_sku = "Basic"
  DB_resource_group_name = "thesis-db-rg"
  DB_location = "Australia East"
  DB_server_name = "thesis-sql-server"
  DB_admin_username = "sqladminuser"
  DB_admin_password = "parola123"
  DB_database_name = "thesis_sqldb"
  DB_sku_name = "Basic"
  StorageAccount_resource_group_name = "thesis-storage-rg"
  StorageAccount_location = "West Europe"
  StorageAccount_storage_account_name = "numestorag"
  StorageAccount_account_tier = "Standard"
  StorageAccount_account_replication_type = "LRS"
  VirtualNetwork_resource_group_name = "VirtualNW_RG"
  VirtualNetwork_location = "West Europe"
  VirtualNetwork_vnet_name = "numeretea"
  VirtualNetwork_address_space = ["10.0.0.0/16"]
  VirtualNetwork_subnet_name = "numesubretea"
  VirtualNetwork_subnet_address_prefixes = ["10.0.1.0/24"]
  VirtualNetwork_environment = "dev"
}