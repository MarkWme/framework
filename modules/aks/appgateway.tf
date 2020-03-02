locals {
  backend_address_pool_name      = format("%s-beap", var.virtual_network_name)
  frontend_port_name             = format("%s-feport", var.virtual_network_name)
  frontend_ip_configuration_name = format("%s-feip", var.virtual_network_name)
  http_setting_name              = format("%s-be-htst", var.virtual_network_name)
  listener_name                  = format("%s-httplstn", var.virtual_network_name)
  request_routing_rule_name      = format("%s-rqrt", var.virtual_network_name)
  redirect_configuration_name    = format("%s-rdrcfg", var.virtual_network_name)
}

resource "azurerm_subnet" "agic_subnet" {
  name                 = format("%s-sn-%s-agic", var.virtual_network_name, var.name)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefix       = var.aks_agic_subnet_address_prefix
}

resource "azurerm_public_ip" "agic_public_ip" {
  name                = format("%s-ip-%s-%s-agic-ip", var.environment, var.azure_region_code, var.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_application_gateway" "aks_agic" {
  name                = format("%s-ag-%s-%s", var.environment, var.azure_region_code, var.name)
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }
  autoscale_configuration {
    min_capacity = 0
    max_capacity = 10
  }

  gateway_ip_configuration {
    name      = format("%s-ag-%s-%s-ip-configuration", var.environment, var.azure_region_code, var.name)
    subnet_id = azurerm_subnet.agic_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agic_public_ip.id
  }

  backend_address_pool {
    name = "defaultaddresspool"
  }

  backend_http_settings {
    name                  = "defaulthttpsetting"
    cookie_based_affinity = "Disabled"
    probe_name            = "defaultprobe-Http"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "fl-80"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rr-80"
    rule_type                  = "Basic"
    http_listener_name         = "fl-80"
    backend_address_pool_name  = "defaultaddresspool"
    backend_http_settings_name = "defaulthttpsetting"
  }

  probe {
      name = "defaultprobe-Http"
      host = "localhost"
      interval = 30
      minimum_servers = 0
      path = "/"
      pick_host_name_from_backend_http_settings = false
      protocol = "Http"
      timeout = 30
      unhealthy_threshold = 3
      match {
          status_code = []
      }
  }

  probe {
      name = "defaultprobe-Https"
      host = "localhost"
      interval = 30
      minimum_servers = 0
      path = "/"
      pick_host_name_from_backend_http_settings = false
      protocol = "Https"
      timeout = 30
      unhealthy_threshold = 3
      match {
          status_code = []
      }
  }
  lifecycle {
    ignore_changes = [
      tags, backend_http_settings, backend_address_pool, http_listener, probe, request_routing_rule
    ]
  }
}
