locals {
  name = format("%s-bh-%s-%s", var.environment, var.azure_region_code, var.name)
}

resource "azurerm_subnet" "bastion_subnet" {
    name = "AzureBastionSubnet"
    resource_group_name = var.subnet_resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = var.address_prefix
}


resource "azurerm_public_ip" "bastion_pip" {
  name                = format("%s-ip-%s-%s-bastion-ip", var.environment, var.azure_region_code, var.name)
  location            = var.location
  resource_group_name = var.bastion_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = format ("Public IP address for Azure Bastion %s", local.name)
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_bastion_host" "bastion" {
  name                = local.name
  location            = var.location
  resource_group_name = var.bastion_resource_group_name

  ip_configuration {
    name                 = format("%s-ip-config", local.name)
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "log_analytics" {
    count = var.enable_diagnostics ? 1 : 0
    name               = format("%s-diagnostics", local.name)
    target_resource_id = azurerm_bastion_host.bastion.id
    log_analytics_workspace_id = var.log_analytics_workspace_id

    log {
        category = "BastionAuditLogs"
        enabled  = true

        retention_policy {
        enabled = false
        }
    }
}
