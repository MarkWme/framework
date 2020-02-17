resource "azurerm_subnet" "core-subnet" {
  name = "AzureFirewallSubnet"
  resource_group_name = azurerm_resource_group.core-resource-group.name
  virtual_network_name = module.core_virtual_network.virtual_network_name
  address_prefix = "10.0.0.0/26"
}

resource "azurerm_public_ip" "core-firewall-pip" {
  name                = "p-ip-euw-corefwip"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Public IP address for Azure Firewall"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_firewall" "core-firewall" {
  name                = "p-fw-euw-core"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name

  ip_configuration {
    name                 = "corefwconfig"
    subnet_id            = azurerm_subnet.core-subnet.id
    public_ip_address_id = azurerm_public_ip.core-firewall-pip.id
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Azure Firewall"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "log-analytics-firewall" {
  name               = "log-analytics-firewall"
  target_resource_id = azurerm_firewall.core-firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core-log-analytics.id

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
