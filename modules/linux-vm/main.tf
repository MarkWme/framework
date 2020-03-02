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
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = format("%s-ip-%s-%s-vm-ip-config", var.environment, var.azure_region_code, var.name)
    subnet_id                     = var.subnet_id
    public_ip_address_id          = azurerm_public_ip.virtual_machine_pip.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "virtual_machine_nic_security_group" {
  network_interface_id      = azurerm_network_interface.virtual_machine_nic.id
  network_security_group_id = azurerm_network_security_group.virtual_machine_nsg.id
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                             = format("%s-vl-%s-%s-vm", var.environment, var.azure_region_code, var.name)
  location                         = var.location
  resource_group_name              = var.resource_group_name
  size                             = var.vm_sku
  admin_username                   = var.admin_username
  network_interface_ids            = [azurerm_network_interface.virtual_machine_nic.id]

  admin_ssh_key {
    username = var.admin_username
    public_key = data.azurerm_key_vault_secret.ssh_key.value
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = format("%s-md-%s-%s-vm-disk0", var.environment, var.azure_region_code, var.name)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }
/*
  boot_diagnostics {
    storage_account_uri = var.storage_account
  }
*/
}

resource "azurerm_managed_disk" "vm_data_disk" {
  for_each = var.data_disks
  name                 = format("%s-md-%s-%s-vm-disk%s", var.environment, var.azure_region_code, var.name, each.key)
  location             = var.location
  create_option        = "Empty"
  disk_size_gb         = each.value
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each = var.data_disks
  virtual_machine_id = azurerm_linux_virtual_machine.virtual_machine.id
  managed_disk_id    = azurerm_managed_disk.vm_data_disk[each.key].id
  lun                = each.key
  caching            = "ReadWrite"
}
