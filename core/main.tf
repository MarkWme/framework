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
