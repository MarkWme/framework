terraform {
    required_version = "> 0.12.0"
    backend "azurerm" {}
}

provider "azurerm" {
    version = ">=2.0.0"
    features {
        virtual_machine {
            delete_os_disk_on_deletion = true
        }
    }
}

provider "azuread" {
    version = ">=0.7.0"
}

data "azurerm_client_config" "current" {}

locals {
    azure_region_code = var.azure_regions[var.azure_region]
    environment_code = var.environments[var.environment]
}

module "core_infrastructure" {
    source = "../modules/core"
    name = var.name
    location = var.azure_region
    azure_region_code = local.azure_region_code
    environment = local.environment_code
    tenant_id = data.azurerm_client_config.current.tenant_id
    virtual_network_address_space = var.networks["virtual_network"]
    general_subnet_address_prefix = var.networks["general_subnet"]
    service_principal_object_id = data.azurerm_client_config.current.object_id
    ssh_file_location = var.ssh_file_location
}

module "uk_south_spoke" {
    source = "../modules/spoke"
    name = "spoke"
    location = "uksouth"
    azure_region_code = "uks"
    environment = local.environment_code
    virtual_network_address_space = var.networks["virtual_network_uk_south"]
    general_subnet_address_prefix = var.networks["general_subnet_uk_south"]
    hub_virtual_network_name = module.core_infrastructure.virtual_network_name
    hub_virtual_network_id = module.core_infrastructure.virtual_network_id
    hub_virtual_network_resource_group = module.core_infrastructure.resource_group_name
    log_analytics_workspace_id = module.core_infrastructure.log_analytics_workspace_id
}
