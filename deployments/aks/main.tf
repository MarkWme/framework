terraform {
    required_version = "> 0.12.0"
    backend "azurerm" {}
      required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">2.0.0"
        }
    }
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
    description = "Resource group for core network, firewall and shared services"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

module "aks_cluster" {
    source = "../../modules/aks"
    name = var.name
    vm_sku = "Standard_D2s_v3"
    aks_subnet_address_prefix = var.networks["aks_subnet"]
    use_preview_version = true
    location = var.azure_region
    azure_region_code = local.azure_region_code
    environment = local.environment_code
    resource_group_name = azurerm_resource_group.resource_group.name
    core_resource_group_name = var.virtual_network_resource_group
    virtual_network_name = var.virtual_network_name
    key_vault_id = data.azurerm_key_vault.core.id
    ssh_key_name = var.ssh_key_name
    enable_log_analytics = true
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.core.id
}
