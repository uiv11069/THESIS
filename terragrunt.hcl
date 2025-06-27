# terragrunt.hcl

 
# Generate backend configuration
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "terragrunt"
    storage_account_name = "terragrunt2025test"
    container_name       = "tfstate"
    key                  = "terragrunt.tfstate"
    access_key  =""
  }
}
EOF
}
 
# Generate provider configuration
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
  subscription_id = ""
}
EOF
}

 




inputs = {
  storageaccount_resource_group_name       = "thesis-storage-rg"
  storageaccount_location                  = "West Europe"
  storageaccount_storage_account_name      = "licentastorageaccount"
  storageaccount_account_tier              = "Standard"
  storageaccount_account_replication_type  = "LRS"
  virtualnetwork_resource_group_name       = "thesisRG"
  virtualnetwork_location                  = "West Europe"
  virtualnetwork_vnet_name                 = "thesis-vnet"
  virtualnetwork_address_space             = ["10.0.0.0/16"]
  virtualnetwork_subnet_name               = "thesis-subnet"
  virtualnetwork_subnet_address_prefixes   = ["10.0.1.0/24"]
  virtualnetwork_environment               = "dev"
}