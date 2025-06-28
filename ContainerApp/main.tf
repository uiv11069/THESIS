resource "azurerm_resource_group" "container_rg" {
  name     = var.ContainerApp_resource_group_name
  location = var.ContainerApp_location
}

resource "azurerm_container_app_environment" "app_env" {
  name                = "thesis-container-env"
  location            = azurerm_resource_group.container_rg.location
  resource_group_name = azurerm_resource_group.container_rg.name
}

resource "azurerm_container_app" "minimal_app" {
  name                           = var.ContainerApp_app_name
  resource_group_name            = var.ContainerApp_resource_group_name
  container_app_environment_id   = azurerm_container_app_environment.app_env.id
  revision_mode                  = "Single"

  template {
    container {
      name   = "nginx"
      image  = "nginx:latest"
      cpu    = 0.25       # Corrected CPU value with only 2 decimals
      memory = "0.5Gi"   # Minimal RAM (512 MB) it must be coupled with the value of cpu in 0.5Gi
    }
  }
}
