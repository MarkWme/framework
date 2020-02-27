output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.virtual_machine.id
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.virtual_machine.private_ip_address
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
}