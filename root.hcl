
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "thesisRG"
    storage_account_name = "thesisstorage"
    container_name       = "tfstate"
    key                  = "terragrunt.tfstate"
  }
}

dependency "AKS" {
  config_path = "${path_relative_from_include()}/AKS"
}

dependency "AppService" {
  config_path = "${path_relative_from_include()}/AppService"
}

inputs = {
  aks_resource_group_name        = "thesisRG"
  aks_location                   = "West Europe"
  aks_aks_cluster_name           = "thesis-aks"
  aks_subnet_id                  = "/subscriptions/da9a301e-7a82-4e73-abb1-e28a503a0adf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-subnet"
  appservice_resource_group_name = "thesisRG"
  appservice_location            = "West Europe"
  appservice_app_name            = "thesis-appservice"
  appservice_subnet_id           = "/subscriptions/da9a301e-7a82-4e73-abb1-e28a503a0adf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-appservice-subnet"
}