variable "name" {
    type = string
    default     = "bastion"
    description = "The name of the Bastion Host instance"
}

variable "location" {
    type = string
    default     = "westeurope"
    description = "The location for the deployments"
}

variable "bastion_resource_group_name" {
    type = string
    default = "p-rg-euw-core"
    description = "The resource group where the Bastion Host will be deployed"
}

variable "subnet_resource_group_name" {
    type = string
    default = "p-rg-euw-core"
    description = "The resource group where the Bastion Host subnet will be created"
}

variable "address_prefix" {
  description = "The network address prefix for the Bastion Host subnet"
}

variable "virtual_network_name" {
  description = "The name of the virtual network to create the subnet in"
}

variable "enable_diagnostics" {
    default = true
    description = "Enables logging of Bastion Host diagnostic data to Log Analytics"
}

variable "log_analytics_workspace_id" {
  default = null
  description = "The id of the Log Analytics instance to send Bastion Host diagnostic data to"
}




