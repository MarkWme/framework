variable "location" {
  default     = "westeurope"
  description = "The Azure region to create the new network in"
}

variable "resource_group_name" {
  description = "The name of the resource group to create the new network in"
}

variable "network_name" {
  description = "The name of the network to be created"
}

variable "address_space" {
    type = list(string)
    default = ["10.0.0.0/16"]
    description = "The address space of the network to be created"
}

variable "enable_peering" {
    default = false
    description = "If this network is to be peered with another network, set this to true and provide the resource group, name and ID of the network to peer with"
}

variable "peer_with_network_resource_group" {
  default = ""
  description = "The resource group of the network to peer with"
}

variable "peer_with_network_name" {
  default = ""
  description = "The name of the network to peer with"
}

variable "peer_with_network_id" {
  default = ""
  description = "The id of the network to peer with"
}

variable "enable_diagnostics" {
    default = true
    description = "Enables logging of virtual network diagnostic data to Log Analytics"
}

variable "log_analytics_workspace_id" {
  default = ""
  description = "The id of the Log Analytics instance to send virtual network diagnostic data to"
}

