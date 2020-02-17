data "local_file" "ssh_key" {
    filename = var.ssh_file_location
}

resource "azurerm_resource_group" "core-resource-group" {
  name     = "p-rg-euw-core"
  location = var.location
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

resource "azurerm_virtual_network" "core-virtual-network" {
    name = "p-vn-euw-core"
    location = var.location
    resource_group_name = azurerm_resource_group.core-resource-group.name
    address_space = ["10.0.0.0/16"]
    tags = {
        deployed-by = "terraform"
        timestamp = timestamp()
        description = "Virtual Network"
    }

    lifecycle {
        ignore_changes = [
            tags["timestamp"],
        ]
    }
}

resource "azurerm_subnet" "core-subnet" {
  name = "AzureFirewallSubnet"
  resource_group_name = azurerm_resource_group.core-resource-group.name
  virtual_network_name = azurerm_virtual_network.core-virtual-network.name
  address_prefix = "10.0.0.0/26"
}

resource "azurerm_public_ip" "core-firewall-pip" {
  name                = "p-ip-euw-corefwip"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Public IP address for Azure Firewall"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_firewall" "core-firewall" {
  name                = "p-fw-euw-core"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name

  ip_configuration {
    name                 = "corefwconfig"
    subnet_id            = azurerm_subnet.core-subnet.id
    public_ip_address_id = azurerm_public_ip.core-firewall-pip.id
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Azure Firewall"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_subnet" "core-bastion-subnet" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.core-resource-group.name
  virtual_network_name = azurerm_virtual_network.core-virtual-network.name
  address_prefix = "10.0.0.64/26"
}

resource "azurerm_public_ip" "core-bastion-pip" {
  name                = "p-ip-euw-corebastionip"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Public IP address for Azure Bastion"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_bastion_host" "core-bastion" {
  name                = "p-bh-euw-core"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name

  ip_configuration {
    name                 = "corebastionconfig"
    subnet_id            = azurerm_subnet.core-bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.core-bastion-pip.id
  }
}

resource "azurerm_subnet" "core-jump-subnet" {
  name = "p-sn-euw-core-jump"
  resource_group_name = azurerm_resource_group.core-resource-group.name
  virtual_network_name = azurerm_virtual_network.core-virtual-network.name
  address_prefix = "10.0.0.128/26"
  network_security_group_id = azurerm_network_security_group.core-jump-vm-nsg.id
}

resource "azurerm_network_security_group" "core-jump-vm-nsg" {
  name                = "p-sg-euw-core-jump-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
}

resource "azurerm_network_security_rule" "core-jump-vm-ssh-rule" {
  name                        = "p-sg-euw-core-jump-ssh-rule"
  resource_group_name         = azurerm_resource_group.core-resource-group.name
  network_security_group_name = azurerm_network_security_group.core-jump-vm-nsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_subnet_network_security_group_association" "core-jump-nsg-ssh" {
  subnet_id                 = azurerm_subnet.core-jump-subnet.id
  network_security_group_id = azurerm_network_security_group.core-jump-vm-nsg.id
}

resource "azurerm_public_ip" "core-jump-vm-pip" {
  name                         = "p-ip-euw-linuxbastion-pip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.core-resource-group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "core-jump-vm-nic" {
  name                = "p-ni-euw-linuxbastion-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name

  ip_configuration {
    name                          = "p-ip-euw-linuxbastion-ip"
    subnet_id                     = azurerm_subnet.core-jump-subnet.id
    public_ip_address_id          = azurerm_public_ip.core-jump-vm-pip.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "core-linux-bastion" {
  name                             = "p-vl-euw-linuxbastion"
  location                         = var.location
  resource_group_name              = azurerm_resource_group.core-resource-group.name
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  network_interface_ids            = [azurerm_network_interface.core-jump-vm-nic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "p-os-euw-linuxbastion-disk0"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "p-vl-euw-linuxbastion"
    admin_username = "guvnor"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = data.local_file.ssh_key.content
      path     = "/home/guvnor/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_virtual_machine_extension" "core-linux-bastion-msi" {
  name                 = "p-vx-euw-linuxbastion-msi"
  publisher            = "Microsoft.ManagedIdentity"
  type                 = "ManagedIdentityExtensionForLinux"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id = azurerm_virtual_machine.core-linux-bastion.id
}


resource "azurerm_key_vault" "core-kv" {
  name = "p-kv-euw-core"
  location = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  tenant_id = var.tenant_id
  sku_name = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.service_principal_object_id

    key_permissions = [
      "create",
      "get",
      "list",
      "delete",
      "update",
    ]

    secret_permissions = [
      "set",
      "get",
      "list",
      "delete",
    ]
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Azure Key Vault"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_key_vault_secret" "ssh_key" {
  name         = "ssh-public-key"
  value        = data.local_file.ssh_key.content
  key_vault_id = azurerm_key_vault.core-kv.id
}

resource "azurerm_container_registry" "core-acr" {
  name                     = "pcreuwcore"
  resource_group_name      = azurerm_resource_group.core-resource-group.name
  location                 = var.location
  sku                      = "Basic"
  admin_enabled            = true

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = "Azure Container Registry"
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }
}

resource "azurerm_log_analytics_workspace" "core-log-analytics" {
  name                = "p-la-euw-core"
  location            = var.location
  resource_group_name = azurerm_resource_group.core-resource-group.name
  sku                 = "Standalone"
  retention_in_days   = 30
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

resource "azurerm_monitor_diagnostic_setting" "log-analytics-firewall" {
  name               = "log-analytics-firewall"
  target_resource_id = azurerm_firewall.core-firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core-log-analytics.id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

output "key_vault_id" {
  value = azurerm_key_vault.core-kv.id
}

output "resource_group_name" {
  value = azurerm_resource_group.core-resource-group.name
}

output "azure_container_registry_name" {
  value = azurerm_container_registry.core-acr.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.core-virtual-network.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.core-virtual-network.id
}

output "firewall_name" {
  value = azurerm_firewall.core-firewall.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.core-log-analytics.id
}

output "ssh_key_name" {
  value = azurerm_key_vault_secret.ssh_key.name
}