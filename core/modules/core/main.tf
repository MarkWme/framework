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

resource "azurerm_subnet" "core-subnet-1" {
    name = "p-sn-euw-core-001"
    resource_group_name = azurerm_resource_group.core-resource-group.name
    virtual_network_name = azurerm_virtual_network.core-virtual-network.name
    address_prefix = "10.0.1.0/24"
}

resource "azurerm_key_vault" "core-kv" {
  name = "p-kv-euw-core"
  location = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  tenant_id = var.tenant_id
  sku_name = "standard"
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

resource "azurerm_container_registry" "core-acr" {
  name                     = "pcreuwacr"
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