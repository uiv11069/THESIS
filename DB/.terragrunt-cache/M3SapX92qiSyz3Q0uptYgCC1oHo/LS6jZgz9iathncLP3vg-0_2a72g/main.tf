resource "azurerm_resource_group" "db_rg" {
  name     = var.DB_resource_group_name
  location = var.DB_location
}

resource "azurerm_mssql_server" "db_server" {
  name                         = var.DB_server_name
  resource_group_name          = azurerm_resource_group.db_rg.name
  location                     = azurerm_resource_group.db_rg.location
  version                      = "12.0"
  administrator_login          = var.DB_admin_username
  administrator_login_password = var.DB_admin_password

  tags = {
    environment = "dev"
  }
}

resource "azurerm_mssql_database" "db" {
  name                = var.DB_database_name
  server_id           = azurerm_mssql_server.db_server.id
  sku_name            = var.DB_sku_name
  auto_pause_delay_in_minutes = 60  # Optional: For serverless SKUs
}
