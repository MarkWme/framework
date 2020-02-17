resource "azurerm_resource_group" "private-aks-resource-group" {
  name     = "p-rg-euw-private-aks"
  location = var.location
   tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Resource group for a private instance of AKS"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_virtual_network" "private-aks-virtual-network" {
    name = "p-vn-euw-private-aks"
    location = var.location
    resource_group_name = azurerm_resource_group.private-aks-resource-group.name
    address_space = ["10.1.0.0/16"]
    tags = {
        deployed-by = "terraform"
        timestamp = timestamp()
        description = "Virtual Network for a private AKS instance"
    }

    lifecycle {
        ignore_changes = [
            tags["timestamp"],
        ]
    }
}

resource "azurerm_virtual_network_peering" "peer-to-private" {
  name                      = "peer-core-to-private-aks"
  resource_group_name       = var.core_resource_group_name
  virtual_network_name      = var.core_network_name
  remote_virtual_network_id = azurerm_virtual_network.private-aks-virtual-network.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peer-to-core" {
  name                      = "peer-private-aks-to-core"
  resource_group_name       = azurerm_resource_group.private-aks-resource-group.name
  virtual_network_name      = azurerm_virtual_network.private-aks-virtual-network.name
  remote_virtual_network_id = var.core_network_id
  allow_virtual_network_access = true
}

resource "azurerm_route_table" "route-table-firewall" {
  name                = "route-table-firewall"
  location            = var.location
  resource_group_name = azurerm_resource_group.private-aks-resource-group.name
}

resource "azurerm_route" "route-to-firewall" {
  name                = "route-to-firewall"
  resource_group_name = azurerm_resource_group.private-aks-resource-group.name
  route_table_name    = azurerm_route_table.route-table-firewall.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address  = "10.0.0.4"
}

module "aks_private_cluster" {
    source = "../aks"
    role = "aks-private"
    instance_id = "1"
    location = var.location
    network_number = "1"
    resource_group_name = azurerm_resource_group.private-aks-resource-group.name
    virtual_network_name = azurerm_virtual_network.private-aks-virtual-network.name
    key_vault_id = var.key_vault_id
    ssh_key_name = var.ssh_key_name
    enable_private_link = true
    log_analytics_workspace_id = var.log_analytics_workspace_id
    route_table_id = azurerm_route_table.route-table-firewall.id
}

resource "azurerm_subnet_route_table_association" "private-subnet-to-firewall" {
  subnet_id      = module.aks_private_cluster.subnet_id
  route_table_id = azurerm_route_table.route-table-firewall.id
}

resource "azurerm_firewall_network_rule_collection" "firewall-allow-dns" {
  name                = "aks-private-allow-dns"
  azure_firewall_name = var.core_firewall_name
  resource_group_name = var.core_resource_group_name
  priority            = 101
  action              = "Allow"

  rule {
    name = "allow-dns"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]
  }
}

resource "azurerm_firewall_network_rule_collection" "firewall-allow-ntp" {
  name                = "aks-private-allow-ntp"
  azure_firewall_name = var.core_firewall_name
  resource_group_name = var.core_resource_group_name
  priority            = 102
  action              = "Allow"

  rule {
    name = "allow-ntp"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "123",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.private-aks-resource-group.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.private-aks-virtual-network.name
}
