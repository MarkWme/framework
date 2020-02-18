locals {
    subnet_name = var.use_specific_name ? var.subnet_name : format("%s-sn-%s", var.virtual_network_name, var.subnet_name)
}
resource "azurerm_subnet" "subnet" {
    count = var.enable_route_table ? 0 : 1
    name = local.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = var.address_prefix
    network_security_group_id = var.network_security_group_id
}

resource "azurerm_subnet" "subnet_with_routing_table" {
    count = var.enable_route_table ? 1 : 0
    name = local.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = var.address_prefix
    route_table_id = var.route_table_id
    network_security_group_id = var.network_security_group_id
}

resource "azurerm_subnet_route_table_association" "private-subnet-to-firewall" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = var.route_table_id
}

output "subnet_id" {
    value = azurerm_subnet.subnet.id
}
