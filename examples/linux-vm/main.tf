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

#
# Deploy a Linux VM with additional 250GB and 500GB data disks
# taking input from the "core" module's output
#
module "linux_core_vm_with_disks" {
  source = "./modules/linux-vm"
  name = "linux"
  location = var.azure_region
  azure_region_code = local.azure_region_code
  environment = local.environment_code
  resource_group_name = module.core_infrastructure.resource_group_name
  subnet_id = module.core_infrastructure.general_subnet_id
  key_vault_id = module.core_infrastructure.key_vault_id
  ssh_key_name = module.core_infrastructure.ssh_key_name
  //storage_account = module.core_infrastructure.storage_account_uri
  data_disks = {
      1 = 250,
      2 = 500
  }
}

#
# Deploy a Linux VM
#
module "linux_vm" {
  source = "./modules/linux-vm"
  name = "linux" # This value in incorporated into the full VM name
  location = "westeurope" # Azure region to deploy to
  azure_region_code = "euw" # Short name for Azure region, incorporated into the full VM name
  environment = "p" # p/d/t (Production/Dev/Test) code, incorporated into the full VM name
  resource_group_name = "resource_group" # Azure resource group to deploy to
  subnet_id = "<subnet-id>" # ID of the subnet the VM will be attached to
  key_vault_id = "<keyvault-id>" # ID of the KeyVault holding the SSH key
  ssh_key_name = "ssh_key" # Name of the key holding the SSH key in KeyVault
  //storage_account = module.core_infrastructure.storage_account_uri
}

#
# Deploy a Linux VM with additional 250GB and 500GB data disks
#
module "linux_vm_with_disks" {
  source = "./modules/linux-vm"
  name = "linux" # This value in incorporated into the full VM name
  location = "westeurope" # Azure region to deploy to
  azure_region_code = "euw" # Short name for Azure region, incorporated into the full VM name
  environment = "p" # p/d/t (Production/Dev/Test) code, incorporated into the full VM name
  resource_group_name = "resource_group" # Azure resource group to deploy to
  subnet_id = "<subnet-id>" # ID of the subnet the VM will be attached to
  key_vault_id = "<keyvault-id>" # ID of the KeyVault holding the SSH key
  ssh_key_name = "ssh_key" # Name of the key holding the SSH key in KeyVault
  //storage_account = module.core_infrastructure.storage_account_uri
  data_disks = { # List of disk numbers and sizes
      1 = 250,
      2 = 500
  }
}
