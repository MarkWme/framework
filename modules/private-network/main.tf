module "core_firewall" {
  source = "../firewall"
  name = var.name
  location = var.location
  azure_region_code = var.azure_region_code
  environment = var.environment
  firewall_resource_group_name = var.resource_group_name
  subnet_resource_group_name = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefix = format("10.%s.0.0/26", var.network_id)
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

module "core_bastion_host" {
  source = "../bastion"
  name = var.name
  location = var.location
  azure_region_code = var.azure_region_code
  environment = var.environment
  bastion_resource_group_name = var.resource_group_name
  subnet_resource_group_name = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefix = format("10.%s.0.64/26", var.network_id)
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_subnet" "bastion_vm_subnet" {
    name = format("%s-sn-jumpbox", var.virtual_network_name)
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = format("10.%s.0.128/26", var.network_id)
}

module "bastion_vm" {
  source = "../linux-vm"
  name = "bastion"
  location = "westeurope"
  azure_region_code = var.azure_region_code
  environment = var.environment
  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.bastion_vm_subnet.id
  key_vault_id = var.key_vault_id
  ssh_key_name = var.ssh_key_name
  //storage_account = var.storage_account
}

output "firewall_private_ip_address" {
  value = module.core_firewall.firewall_private_ip_address
}

output "firewall_name" {
  value = module.core_firewall.firewall_name
}