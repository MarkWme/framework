locals {
  name = format("p-fw-euw-%s", var.name)
}

module "firewall-subnet" {
  source = "../subnet"
  resource_group_name = var.subnet_resource_group_name
  virtual_network_name = var.virtual_network_name
  subnet_name = "AzureFirewallSubnet"
  use_specific_name = true
  address_prefix = var.address_prefix
}

resource "azurerm_public_ip" "firewall-pip" {
  name                = format("p-ip-euw-%s-firewall-ip", var.name)
  location            = var.location
  resource_group_name = var.firewall_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = format("Public IP address for Azure Firewall %s", local.name)
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_firewall" "firewall" {
  name                = local.name
  location            = var.location
  resource_group_name = var.firewall_resource_group_name

  ip_configuration {
    name                 = format("%s-ip-config", local.name)
    subnet_id            = module.firewall-subnet.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall-pip.id
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
