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
    default = "p-rg-euw-core"
    description = "The resource group where the virtual machine will be deployed"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet that the VM's NIC will be attached to"
}

variable "key_vault_id" {
  type        = string
  description = "The name of the Key Vault instance where the SSH public key is stored. Just the name of the vault, not the URI"
}

variable "ssh_key_name" {
  type = string
  description = "The name of the Key Vault secret that holds the SSH public key to be used"
}

variable "enable_diagnostics" {
    default = true
    description = "Enables logging of firewall diagnostic data to Log Analytics"
}

variable "log_analytics_workspace_id" {
  default = null
  description = "The id of the Log Analytics instance to send firewall diagnostic data to"
}




