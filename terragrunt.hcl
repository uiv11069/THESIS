dependency "AppService" {
  config_path = "${path_relative_from_include()}/AppService"
}

dependency "ContainerApp" {
  config_path = "${path_relative_from_include()}/ContainerApp"
}

inputs = {
  appservice_resource_group_name = "pop"
  appservice_location            = "lkj"
  appservice_app_name            = "lkj"
  appservice_subnet_id           = "zdf"
  containerapp_resource_group_name = "fasd"
  containerapp_location            = "fasd"
  containerapp_app_name            = "fasd"
}