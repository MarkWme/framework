data "azurerm_key_vault_secret" "ssh_key" {
  name      = var.ssh_key_name
  key_vault_id = var.key_vault_id
}

module "aks_sp" {
    source = "../serviceprincipal"
    service_principal_name = format("%s-sp-%s-%s-%02s", var.environment, var.azure_region_code, var.name, var.instance_id)
    key_vault_id = var.key_vault_id
}

resource "azurerm_subnet" "aks_subnet" {
    name = format("%s-%s-%02s", var.virtual_network_name, var.name, var.instance_id)
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = format("10.%s.%s.0/24", var.network_id, var.instance_id)
}

resource "azurerm_subnet_route_table_association" "private-subnet-to-firewall" {
  count = var.enable_route_table ? 1 : 0
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = var.route_table_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = format("%s-ks-%s-%s-%02s", var.environment, var.azure_region_code, var.name, var.instance_id)
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = format("%s-ks-%s-%s-%02s", var.environment, var.azure_region_code, var.name, var.instance_id)
  kubernetes_version = var.kubernetes_version

  enable_pod_security_policy = var.enable_pod_security_policy
  private_link_enabled = var.enable_private_link

  role_based_access_control {
    enabled = var.enable_rbac
  }

  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  default_node_pool {
    name = "pool01"
    vm_size = "Standard_DS2_v2"
    type = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count = var.minimum_node_count
    max_count = var.maximum_node_count
    node_count = var.node_count
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  linux_profile {
    admin_username = "guvnor"
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_key.value
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin = "azure"
    service_cidr = "10.250.0.0/16"
    dns_service_ip = "10.250.0.10"
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
