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

resource "azurerm_kubernetes_cluster" "aks" {
  name = "p-ks-euw-aks"
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = "p-ks-euw-aks"
  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name = "pool01"
    vm_size = "Standard_DS2_v2"
    type = VirtualMachineScaleSets
    enable_auto_scaling = true
    min_count = 1
    max_count = 10
    node_count = 3
    vnet_subnet_id = something
  }

  linux_profile {
    admin_username = "guvnor"
    ssh_key
  }

  network_profile {
    load_balancer_sku = standard
    network_plugin = azure
    service_cidr = "10.1.254.0/24"
    dns_service_ip = "10.1.254.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  service_principal {
    client_id     = "00000000-0000-0000-0000-000000000000"
    client_secret = "00000000000000000000000000000000"
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
}
