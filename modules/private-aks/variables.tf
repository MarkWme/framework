variable "location" {
  default     = "westeurope"
  description = "The location for the deployments"
}

variable "core_resource_group_name" {
  description = "The name of the network to peer with"
}

variable "core_network_name" {
  description = "The name of the network to peer with"
}

variable "core_network_id" {
  description = "The id of the network to peer with"
}

variable "key_vault_id" {
  description = "ID of the Key Vault instance to use"
}

variable "ssh_key_name" {
  description = "Name of the Key Vault secret holding the SSH key"
}

variable "log_analytics_workspace_id" {
  description = "The id of the Log Analytics instance to connect to"
}

