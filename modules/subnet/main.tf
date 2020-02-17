locals {
    subnet_name = var.use_specific_name ? var.subnet_name : format("%s-%s", var.virtual_network_name, var.subnet_name)
}

resource "azurerm_subnet" "subnet" {
    name = local.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = var.address_prefix
    route_table_id = var.route_table_id
}
