variable "name" {
    type = string
    default     = "linuxvm"
    description = "The name of the virtual machine"
}

variable "location" {
    type = string
    default     = "westeurope"
    description = "The location for the deployments"
}

variable "azure_region_code" {
  description = "A three character code used to indicate which region a resource is deployed to. Used as part of the resource name"
}

variable "environment" {
  description = "This will be used to add a prefix to resources (d/t/p) to indicate if a resource is part of a dev, test or production environment"
}

variable "resource_group_name" {
    type = string
    description = "The resource group where the virtual machine will be deployed"
}

variable "vm_sku" {
    type = string
    default = "Standard_DS1_v2"
    description = "The SKU to be used for this virtual machine"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet that the VM's NIC will be attached to"
}

variable "key_vault_id" {
  type        = string
  description = "The name of the Key Vault instance where the SSH public key is stored. Just the name of the vault, not the URI"
}

variable "admin_username" {
  type = string
  default = "guvnor"
  description = "Username for the local administrator user account"
}

variable "ssh_key_name" {
  type = string
  description = "The name of the Key Vault secret that holds the SSH public key to be used"
}

variable "data_disks" {
  type = map
  default = {}
  description = "If data disks are to be created for this VM, list their sizes here"
}

/*
variable "storage_account" {
  type = string
  description = "Storage account to store boot diagnostics data in"
}
*/


