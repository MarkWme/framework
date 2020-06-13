provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

data "azurerm_key_vault_secret" "ssh_key" {
  name      = var.ssh_key_name
  key_vault_id = var.key_vault_id
}

data "azurerm_kubernetes_service_versions" "kubernetes_version" {
  location = var.location
  version_prefix = var.kubernetes_version_prefix
  include_preview = var.use_preview_version
}

resource "random_password" "windows_admin_password" {
  length = 16
}

resource "azurerm_subnet" "aks_subnet" {
    name = format("%s-sn-%s", var.virtual_network_name, var.name)
    resource_group_name = var.core_resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = var.aks_subnet_address_prefix
}

resource "azurerm_subnet_route_table_association" "private-subnet-to-firewall" {
  count = var.enable_route_table ? 1 : 0
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = var.route_table_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = format("%s-ks-%s-%s", var.environment, var.azure_region_code, var.name)
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = format("%s-ks-%s-%s", var.environment, var.azure_region_code, var.name)
  kubernetes_version = data.azurerm_kubernetes_service_versions.kubernetes_version.latest_version

  enable_pod_security_policy = var.enable_pod_security_policy
  private_cluster_enabled = var.enable_private_link

  role_based_access_control {
    enabled = var.enable_rbac
  }

  addon_profile {
    oms_agent {
      enabled = var.enable_log_analytics
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  default_node_pool {
    name = "linux01"
    vm_size = var.vm_sku
    type = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count = var.minimum_node_count
    max_count = var.maximum_node_count
    node_count = var.node_count
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_key.value
    }
  }

  windows_profile {
    admin_username = var.admin_username
    admin_password = random_password.windows_admin_password.result
  }


  network_profile {
    load_balancer_sku = "Standard"
    network_plugin = "azure"
    network_policy = var.network_policy
    service_cidr = "10.250.0.0/16"
    dns_service_ip = "10.250.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
      default_node_pool.0.node_count, # Prevent K8s autoscaling changes from being modified by Terraform
      service_principal.0.client_id # Prevent client ID being overwritten - this can happen if MSI is being used.
    ]
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "aks_windows" {
  count                 = var.enable_windows_containers ? 1:0
  name                  = "win01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_sku
  enable_auto_scaling = var.enable_auto_scaling
  min_count = var.minimum_node_count
  max_count = var.maximum_node_count
  node_count = var.node_count
  os_type = "Windows"
  vnet_subnet_id = azurerm_subnet.aks_subnet.id
  node_taints = ["os=windows:NoSchedule"]
  lifecycle {
    ignore_changes = [
      node_count # Prevent K8s autoscaling changes from being modified by Terraform
    ]
  }
}

resource "azurerm_key_vault_secret" "windows_admin_password" {
  count        = var.enable_windows_containers ? 1:0
  name         = format("%s-windows-admin-password", azurerm_kubernetes_cluster.aks.name)
  value        = random_password.windows_admin_password.result
  key_vault_id = var.key_vault_id
}