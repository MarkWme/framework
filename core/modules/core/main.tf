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
    address_space = ["10.0.0.0/8"]
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
    address_prefix = "10.1.0.0/16"
}