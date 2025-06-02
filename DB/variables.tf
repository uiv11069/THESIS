variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesis-db-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "db_name" {
  description = "PostgreSQL Flexible Server Name"
  type        = string
  default     = "thesis-db"
}

variable "admin_username" {
  description = "Administrator username for the PostgreSQL server"
  type        = string
  default     = "pgadmin"
}

variable "admin_password" {
  description = "Administrator password for the PostgreSQL server"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "thesis_db"
}
