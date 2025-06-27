
resource "azurerm_resource_group" "db_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_postgresql_flexible_server" "db" {
  name                   = var.db_name
  resource_group_name    = azurerm_resource_group.db_rg.name
  location               = azurerm_resource_group.db_rg.location
  version                = "13"
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = "B_Standard_B1ms"  # Minimal consumption
  storage_mb             = 32768             # 32GB, the minimum allowed
  backup_retention_days  = 7                 # Minimal backup retention

  tags = {
    environment = "dev"
  }
}

resource "azurerm_postgresql_flexible_server_database" "thesis_db" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}
