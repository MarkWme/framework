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

module "core_virtual_network" {
  source = "../virtual-network"
  location = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  network_name = format("%s-vn-%s-%s", var.environment, var.azure_region_code, var.name)
  address_space = [var.virtual_network_address_space]
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_subnet" "general_subnet" {
    name = format("%s-sn-general", module.core_virtual_network.virtual_network_name)
    resource_group_name = azurerm_resource_group.core-resource-group.name
    virtual_network_name = module.core_virtual_network.virtual_network_name
    address_prefixes = [var.general_subnet_address_prefix]
}

resource "azurerm_virtual_network_peering" "peer_spoke_to_hub" {
  name = format("%s-vp-%s-to-hub", var.environment, var.location)
  resource_group_name = azurerm_resource_group.core-resource-group.name
  virtual_network_name = module.core_virtual_network.virtual_network_name
  remote_virtual_network_id = var.hub_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peer_hub_to_spoke" {
  name = format("%s-vp-hub-to-%s", var.environment, var.location)
  resource_group_name = var.hub_virtual_network_resource_group
  virtual_network_name = var.hub_virtual_network_name
  remote_virtual_network_id = module.core_virtual_network.virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
}