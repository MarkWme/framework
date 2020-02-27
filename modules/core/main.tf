data "local_file" "ssh_key" {
    filename = var.ssh_file_location
}

resource "azurerm_resource_group" "core-resource-group" {
  name     = format("%s-rg-%s-%s", var.environment, var.azure_region_code, var.name)
  location = var.location
   tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Resource group for core network, firewall and shared services"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_log_analytics_workspace" "core-log-analytics" {
  name                = format("%s-la-%s-%s", var.environment, var.azure_region_code, var.name)
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  sku                 = "Standalone"
  retention_in_days   = 30
  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}
/*

# Temporarily removed as there seems to be a bug
# with storage accounts in AzureRM v2

resource "azurerm_storage_account" "core_storage" {
  name                     = format("%ssa%s%s", var.environment, var.azure_region_code, var.name)
  resource_group_name      = azurerm_resource_group.core-resource-group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}
*/

module "core_virtual_network" {
  source = "../virtual-network"
  location = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  network_name = format("%s-vn-%s-%s", var.environment, var.azure_region_code, var.name)
  address_space = [var.virtual_network_address_space]
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core-log-analytics.id
}

resource "azurerm_subnet" "general_subnet" {
    name = format("%s-sn-general", module.core_virtual_network.virtual_network_name)
    resource_group_name = azurerm_resource_group.core-resource-group.name
    virtual_network_name = module.core_virtual_network.virtual_network_name
    address_prefix = var.general_subnet_address_prefix
}

resource "azurerm_key_vault" "core-kv" {
  name = format("%s-kv-%s-%s", var.environment, var.azure_region_code, var.name)
  location = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  tenant_id = var.tenant_id
  sku_name = "standard"
  enabled_for_disk_encryption = true

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.service_principal_object_id

    key_permissions = [
      "create",
      "get",
      "list",
      "delete",
      "update",
    ]

    secret_permissions = [
      "set",
      "get",
      "list",
      "delete",
    ]
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Azure Key Vault"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_key_vault_secret" "ssh_key" {
  name         = "ssh-public-key"
  value        = data.local_file.ssh_key.content
  key_vault_id = azurerm_key_vault.core-kv.id
}

resource "azurerm_container_registry" "core-acr" {
  name                     = format("%scr%s%s", var.environment, var.azure_region_code, var.name)
  resource_group_name      = azurerm_resource_group.core-resource-group.name
  location                 = var.location
  sku                      = "Basic"
  admin_enabled            = true

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Azure Container Registry"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}