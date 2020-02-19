resource "azurerm_resource_group" "private_aks_resource_group" {
  name     = format("%s-rg-%s-%s", var.environment, var.azure_region_code, var.name)
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

module "private_aks_virtual_network" {
  source = "../virtual-network"
  location = var.location
  resource_group_name = azurerm_resource_group.private_aks_resource_group.name
  network_name = format("%s-vn-%s-%s", var.environment, var.azure_region_code, var.name)
  address_space = [format("10.%s.0.0/16",var.network_id)]
  enable_peering = true
  peer_with_network_resource_group = var.core_resource_group_name
  peer_with_network_name = var.core_network_name
  peer_with_network_id = var.core_network_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_route_table" "route_table_firewall" {
  name                = "route-table-firewall"
  location            = var.location
  resource_group_name = azurerm_resource_group.private_aks_resource_group.name
}

resource "azurerm_route" "route_to_firewall" {
  name                = "route-to-firewall"
  resource_group_name = azurerm_resource_group.private_aks_resource_group.name
  route_table_name    = azurerm_route_table.route_table_firewall.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address  = var.firewall_private_ip_address
}

module "aks_private_cluster" {
    source = "../aks"
    name = "aks-private"
    instance_id = var.instance_id
    location = var.location
    network_id = var.network_id
    azure_region_code = var.location
    environment = var.environment
    resource_group_name = azurerm_resource_group.private_aks_resource_group.name
    virtual_network_name = module.private_aks_virtual_network.virtual_network_name
    key_vault_id = var.key_vault_id
    ssh_key_name = var.ssh_key_name
    enable_private_link = true
    log_analytics_workspace_id = var.log_analytics_workspace_id
    enable_route_table = true
    route_table_id = azurerm_route_table.route_table_firewall.id
}

resource "azurerm_subnet_route_table_association" "private-subnet-to-firewall" {
  subnet_id      = module.aks_private_cluster.subnet_id
  route_table_id = azurerm_route_table.route_table_firewall.id
}

resource "azurerm_firewall_network_rule_collection" "firewall_allow_dns" {
  name                = "aks-private-allow-dns"
  azure_firewall_name = var.firewall_name
  resource_group_name = var.firewall_resource_group_name
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

resource "azurerm_firewall_network_rule_collection" "firewall_allow_ntp" {
  name                = "aks-private-allow-ntp"
  azure_firewall_name = var.firewall_name
  resource_group_name = var.firewall_resource_group_name
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
