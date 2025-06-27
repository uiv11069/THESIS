
# App Service Plan (Using azurerm_service_plan)
resource "azurerm_service_plan" "app_plan" {
  name                = "thesis-appservice-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Web App (Using azurerm_linux_web_app)
resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = true
  }

  app_settings = {
    "DOCKER_ENABLE_CI"                       = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"    = "false"
    "WEBSITES_CONTAINER_START_TIME_LIMIT"    = "240"
    "WEBSITES_PORT"                          = "80"
    "DOCKER_CUSTOM_IMAGE_NAME"               = "nginx:latest" # Set Docker image here
  }
}

# VNet Integration for App Service
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = var.subnet_id
}