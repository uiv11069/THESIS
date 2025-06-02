```hcl
terraform {
  source = "./modules/${path_relative_to_include()}"
}

inputs = {
  # AKS Module Inputs
  resource_group_name = "thesisRG"
  location            = "West Europe"
  aks_cluster_name    = "thesis-aks"
  subnet_id           = "/subscriptions/da9a301e-7a82-4e73-abb1-e28a503a0adf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-subnet"

  # AppService Module Inputs
  app_name = "thesis-appservice"
  subnet_id = "/subscriptions/da9a301e-7a82-4e73-abb1-e28a503a0adf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-appservice-subnet"

  # StorageAccount Module Inputs
  resource_group_name      = "thesis-storage-rg"
  storage_account_name     = "licentastorageaccount"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "dev"
  }
}

remote_state {
  backend = "azurerm"
  config = {
    storage_account_name = "your_storage_account_name"
    container_name       = "your_container_name"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
```