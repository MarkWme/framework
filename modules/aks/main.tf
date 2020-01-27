data "azurerm_key_vault_secret" "ssh_key" {
  name      = var.ssh_key
  key_vault_id = var.key_vault_id
}

module "aks_sp" {
    source = "../serviceprincipal"
    service_principal_name = format("p-sp-euw-%s-%03s",var.role, var.instance_id)
    key_vault_id = var.key_vault_id
}

resource "azurerm_subnet" "aks-subnet" {
    name = format("p-sn-euw-core-%03s", var.instance_id)
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = format("10.0.%s.0/24", var.instance_id)
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = format("p-ks-euw-%s-%03s", var.role, var.instance_id)
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = format("p-ks-euw-%s-%03s", var.role, var.instance_id)
  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name = "pool01"
    vm_size = "Standard_DS2_v2"
    type = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count = 1
    max_count = 10
    node_count = 3
    vnet_subnet_id = azurerm_subnet.aks-subnet.id
  }

  linux_profile {
    admin_username = "guvnor"
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_key.value
    }
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin = "azure"
    service_cidr = "10.1.254.0/24"
    dns_service_ip = "10.1.254.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  service_principal {
    client_id     = module.aks_sp.client_id
    client_secret = module.aks_sp.client_secret
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
      default_node_pool.0.node_count # Prevent K8s autoscaling changes from being modified by Terraform
    ]
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}
