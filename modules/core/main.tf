data "local_file" "ssh_key" {
    filename = var.ssh_file_location
}

resource "azurerm_resource_group" "core-resource-group" {
  name     = "p-rg-euw-core"
  location = var.location
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

resource "azurerm_virtual_network" "core-virtual-network" {
    name = "p-vn-euw-core"
    location = var.location
    resource_group_name = azurerm_resource_group.core-resource-group.name
    address_space = ["10.0.0.0/16"]
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

resource "azurerm_key_vault" "core-kv" {
  name = "p-kv-euw-core"
  location = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  tenant_id = var.tenant_id
  sku_name = "standard"

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
  name                     = "pcreuwcore"
  resource_group_name      = azurerm_resource_group.core-resource-group.name
  location                 = var.location
  sku                      = "Basic"
  admin_enabled            = false

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

output "key_vault_id" {
  value = azurerm_key_vault.core-kv.id
}

output "resource_group_name" {
  value = azurerm_resource_group.core-resource-group.name
}

output "azure_container_registry_name" {
  value = azurerm_container_registry.core-acr.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.core-virtual-network.name
}

output "ssh_key_name" {
  value = azurerm_key_vault_secret.ssh_key.name
}