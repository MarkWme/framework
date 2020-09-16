output "resource_group_name" {
  value = azurerm_resource_group.core-resource-group.name
}

output "virtual_network_name" {
  value = module.core_virtual_network.virtual_network_name
}

output "virtual_network_id" {
  value = module.core_virtual_network.virtual_network_id
}

output "general_subnet_id" {
  value = azurerm_subnet.general_subnet.id
}

output "general_subnet_name" {
  value = azurerm_subnet.general_subnet.name
}
