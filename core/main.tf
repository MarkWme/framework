terraform {
    required_version = "> 0.12.0"
    backend "azurerm" {
        storage_account_name = "psaeuwshared"
        container_name       = "terraform-state"
        key                  = "core.mtjw.azure.tfstate"
    }
}

provider "azurerm" {
    version = "=1.38.0"
}

module "core_infrastructure" {
    source = "./modules/core"
    location = var.location
    tenant_id = var.tenant_id
}
