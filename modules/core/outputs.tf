output "key_vault_id" {
  value = azurerm_key_vault.core-kv.id
}

output "resource_group_name" {
  value = azurerm_resource_group.core-resource-group.name
}

output "azure_container_registry_name" {
  value = azurerm_container_registry.core-acr.name
}

/*
output "storage_account_name" {
  value = azurerm_storage_account.core_storage.name
}

output "storage_account_uri" {
  value = "azurerm_storage_account.core_storage.primary_blob_endpoint"
}
*/

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

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.core-log-analytics.id
}

output "ssh_key_name" {
  value = azurerm_key_vault_secret.ssh_key.name
}