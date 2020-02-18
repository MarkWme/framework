variable "name" {
  default     = "core"
  description = "This value will be used as part of the names of the resources being created"
}

variable "network_id" {
  default = "0"
  description = "This provides the second octet of the network address space used during deployments - i.e. 10.x.0.0/16"
}

variable "location" {
  description = "The Azure region where the resources will be deployed"
}

variable "azure_region_code" {
  description = "A three character code used to indicate which region a resource is deployed to. Used as part of the resource name"
}

variable "environment" {
  description = "This will be used to add a prefix to resources (d/t/p) to indicate if a resource is part of a dev, test or production environment"
}

variable "resource_group_name" {
  description = "The resource group where the subnet will be created"
}

variable "virtual_network_name" {
  description = "The virtual network where the subnets will be created"
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
    description = "Enables logging of virtual network diagnostic data to Log Analytics"
}

variable "log_analytics_workspace_id" {
  default = null
  description = "The ID of the Log Analytics instance to be used"
}