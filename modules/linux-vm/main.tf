data "azurerm_key_vault_secret" "ssh_key" {
  name      = var.ssh_key_name
  key_vault_id = var.key_vault_id
}

resource "azurerm_network_security_group" "virtual_machine_nsg" {
  name                = format("%s-sg-%s-%s-vm", var.environment, var.azure_region_code, var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "virtual_machine_ssh_rule" {
  name                        = format("%s-sg-%s-%s-ssh-rule", var.environment, var.azure_region_code, var.name)
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.virtual_machine_nsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_public_ip" "virtual_machine_pip" {
  name                = format("%s-ip-%s-%s-vm-ip", var.environment, var.azure_region_code, var.name)
  location                     = var.location
  resource_group_name          = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
    description = format ("Public IP address for Linux Virtual Machine%s-vl-%s-%s-vm", var.environment, var.azure_region_code, var.name)
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
    ]
  }

}

resource "azurerm_network_interface" "virtual_machine_nic" {
  name                = format("%s-ni-%s-%s-nic", var.environment, var.azure_region_code, var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  network_security_group_id = azurerm_network_security_group.virtual_machine_nsg.id

  ip_configuration {
    name                          = format("%s-ip-%s-%s-vm-ip-config", var.environment, var.azure_region_code, var.name)
    subnet_id                     = var.subnet_id
    public_ip_address_id          = azurerm_public_ip.virtual_machine_pip.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "virtual_machine" {
  name                             = format("%s-vl-%s-%s-vm", var.environment, var.azure_region_code, var.name)
  location                         = var.location
  resource_group_name              = var.resource_group_name
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  network_interface_ids            = [azurerm_network_interface.virtual_machine_nic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = format("%s-os-%s-%s-vm-disk0", var.environment, var.azure_region_code, var.name)
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = format("%s-vl-%s-%s-vm", var.environment, var.azure_region_code, var.name)
    admin_username = "guvnor"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = data.azurerm_key_vault_secret.ssh_key.value
      path     = "/home/guvnor/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_virtual_machine_extension" "virtual_machine_msi" {
  name                 = format("%s-vx-%s-%s-vm-msi", var.environment, var.azure_region_code, var.name)
  publisher            = "Microsoft.ManagedIdentity"
  type                 = "ManagedIdentityExtensionForLinux"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id = azurerm_virtual_machine.virtual_machine.id
}
