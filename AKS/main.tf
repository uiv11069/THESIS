provider "azurerm" {
  features {}
  subscription_id = "da9a301e-7a82-4e73-abb1-e28a503a0adf"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "thesis-aks"

  default_node_pool {
    name           = "agentpool"
    node_count     = 1              # Minimal consumption
    vm_size        = "Standard_B2s" # Smallest VM type
    vnet_subnet_id = var.subnet_id  # Attach AKS to the existing Subnet
  }


  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.0.2.0/24"
    dns_service_ip = "10.0.2.10"
  }

  tags = {
    environment = "dev"
  }
}
