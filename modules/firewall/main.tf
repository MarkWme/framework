locals {
  name = format("%s-fw-%s-%s", var.environment, var.azure_region_code, var.name)
}

resource "azurerm_subnet" "firewall_subnet" {
    name = "AzureFirewallSubnet"
    resource_group_name = var.subnet_resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = var.address_prefix
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = format("%s-ip-%s-%s-firewall-ip", var.environment, var.azure_region_code, var.name)
  location            = var.location
  resource_group_name = var.firewall_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = local.name
  location            = var.location
  resource_group_name = var.firewall_resource_group_name

  ip_configuration {
    name                 = format("%s-ip-config", local.name)
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "log_analytics_firewall" {
  count = var.enable_diagnostics ? 1 : 0
  name               = format("%s-diagnostics", local.name)
  target_resource_id = azurerm_firewall.firewall.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

output "firewall_private_ip_address" {
  value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}