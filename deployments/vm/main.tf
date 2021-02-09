terraform {
    backend "azurerm" {}
}

provider "azurerm" {
    features {
        virtual_machine {
            delete_os_disk_on_deletion = true
        }
    }
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "core" {
    name = var.key_vault_name
    resource_group_name = var.key_vault_resource_group
}

data "azurerm_subnet" "vm_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}

data "azurerm_log_analytics_workspace" "core" {
    name = var.log_analytics_workspace_name
    resource_group_name = var.log_analytics_resource_group
}

locals {
    azure_region_code = var.azure_regions[var.azure_region]
    environment_code = var.environments[var.environment]
}

resource "azurerm_resource_group" "resource_group" {
  name     = format("%s-rg-%s-%s", local.environment_code, local.azure_region_code, var.name)
  location = var.azure_region
   tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Resource group for Linux VM resource"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

module "linux_vm" {
  source = "../../modules/linux-vm"
  name = var.name
  location = var.azure_region
  azure_region_code = local.azure_region_code
  environment = local.environment_code
  resource_group_name = azurerm_resource_group.resource_group.name
  subnet_id = data.azurerm_subnet.vm_subnet.id
  key_vault_id = data.azurerm_key_vault.core.id
  ssh_key_name = var.ssh_key_name
  //storage_account = module.core_infrastructure.storage_account_uri
  data_disks = {
      1 = 250,
      2 = 500
  }
}
