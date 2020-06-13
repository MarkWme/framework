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

data "azurerm_key_vault" "core" {
    name = var.core_key_vault_name
    resource_group_name = var.core_resource_group_name
}

data "azurerm_log_analytics_workspace" "core" {
    name = var.core_log_analytics_workspace_name
    resource_group_name = var.core_resource_group_name
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

/*
module "private_network" {
    source = "../modules/private-network"
    name = var.name
    location = var.azure_region
    azure_region_code = local.azure_region_code
    environment = local.environment_code
    resource_group_name = module.core_infrastructure.resource_group_name
    virtual_network_name = module.core_infrastructure.virtual_network_name
    firewall_subnet_address_prefix = var.networks["firewall_subnet"]
    bastion_subnet_address_prefix = var.networks["bastion_subnet"]
    jumpbox_subnet_address_prefix = var.networks["jumpbox_subnet"]
    key_vault_id = module.core_infrastructure.key_vault_id
    ssh_key_name = module.core_infrastructure.ssh_key_name
    enable_diagnostics = true
    log_analytics_workspace_id = module.core_infrastructure.log_analytics_workspace_id
    //storage_account = module.core_infrastructure.storage_account_uri
}
*/

module "aks_cluster" {
    source = "../modules/aks"
    name = "aks"
    vm_sku = "Standard_D2s_v3"
    aks_subnet_address_prefix = var.networks["aks_subnet"]
    aks_agic_subnet_address_prefix = var.networks["aks_agic_subnet"]
    use_preview_version = true
    enable_windows_containers = false
    enable_agic = false
    enable_kured = true
    enable_keda = false
    location = var.azure_region
    azure_region_code = local.azure_region_code
    environment = local.environment_code
    resource_group_name = azurerm_resource_group.resource_group.name
    core_resource_group_name = var.core_resource_group_name
    virtual_network_name = var.core_virtual_network_name
    key_vault_id = data.azurerm_key_vault.core.id
    ssh_key_name = var.core_ssh_key_name
    enable_log_analytics = true
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.core.id
}

/*
module "aks_cluster_calico" {
    source = "../modules/aks"
    name = "akscalico"
    vm_sku = "Standard_D2s_v3"
    aks_subnet_address_prefix = "10.0.3.0/24"
    use_preview_version = true
    location = var.azure_region
    azure_region_code = local.azure_region_code
    environment = local.environment_code
    resource_group_name = module.core_infrastructure.resource_group_name
    network_policy = "calico"
    virtual_network_name = module.core_infrastructure.virtual_network_name
    key_vault_id = module.core_infrastructure.key_vault_id
    ssh_key_name = module.core_infrastructure.ssh_key_name
    log_analytics_workspace_id = module.core_infrastructure.log_analytics_workspace_id
}
*/

/*
module "aks_cluster_1_15_10" {
    source = "../modules/aks"
    name = "aks11510"
    vm_sku = "Standard_D2s_v3"
    aks_subnet_address_prefix = "10.0.3.0/24"
    use_preview_version = false
    kubernetes_version_prefix = "1.15"
    enable_windows_containers = true
    location = var.azure_region
    azure_region_code = local.azure_region_code
    environment = local.environment_code
    resource_group_name = module.core_infrastructure.resource_group_name
    virtual_network_name = module.core_infrastructure.virtual_network_name
    key_vault_id = module.core_infrastructure.key_vault_id
    ssh_key_name = module.core_infrastructure.ssh_key_name
    log_analytics_workspace_id = module.core_infrastructure.log_analytics_workspace_id
}
*/

/*
module "benchmark_vm" {
  source = "../modules/linux-vm"
  name = "bench"
  location = var.azure_region
  azure_region_code = local.azure_region_code
  environment = local.environment_code
  resource_group_name = module.core_infrastructure.resource_group_name
  subnet_id = module.core_infrastructure.general_subnet_id
  key_vault_id = module.core_infrastructure.key_vault_id
  ssh_key_name = module.core_infrastructure.ssh_key_name
  vm_sku = "Standard_D8s_v3"
  enable_accelerated_networking = true
}
*/

/*
module "private_aks" {
    source = "../modules/private-aks"
    name = "aks-private"
    instance_id = "1"
    network_id = var.aks_private_network_id
    location = var.azure_region
    azure_region_code = local.azure_region_code
    environment = local.environment_code
    core_resource_group_name = module.core_infrastructure.resource_group_name
    core_network_id = module.core_infrastructure.virtual_network_id
    core_network_name = module.core_infrastructure.virtual_network_name
    private_aks_virtual_network_address_space = var.networks["private_aks_virtual_network"]
    aks_subnet_address_prefix = var.networks["private_aks_subnet"]
    key_vault_id = module.core_infrastructure.key_vault_id
    ssh_key_name = module.core_infrastructure.ssh_key_name
    log_analytics_workspace_id = module.core_infrastructure.log_analytics_workspace_id
    firewall_name = module.private_network.firewall_name
    firewall_private_ip_address = module.private_network.firewall_private_ip_address
    firewall_resource_group_name = module.core_infrastructure.resource_group_name
}
*/
/*
module "linux_vm" {
  source = "../modules/linux-vm"
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
*/