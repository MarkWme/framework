locals {
  name = format("p-bh-euw-%s", var.name)
}

module "bastion-subnet" {
  source = "../subnet"
  resource_group_name = var.subnet_resource_group_name
  virtual_network_name = var.virtual_network_name
  subnet_name = "AzureBastionSubnet"
  use_specific_name = true
  address_prefix = var.address_prefix
}

resource "azurerm_public_ip" "bastion-pip" {
  name                = format("p-ip-euw-%s-bastion-ip", var.name)
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
    subnet_id            = module.bastion-subnet.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion-pip.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "log-analytics" {
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
