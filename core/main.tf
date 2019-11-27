terraform {
    required_version = "> 0.12.0"
    backend "azurerm" {
        storage_account_name = "psaeuwshared"
        container_name       = "terraform-state"
        key                  = "core.mtjw.azure.tfstate"
    }
}

provider "azurerm" {
    version = "=1.37.0"
}

module "core_infrastructure" {
    source = "./modules/core"
    location = var.location
}
