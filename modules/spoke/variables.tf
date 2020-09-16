variable "name" {
  default     = "spoke"
  description = "This value will be used as part of the names of the resources being created"
}

variable "virtual_network_address_space" {
  description = "The address space for the core virtual network - i.e. 10.0.0.0/16"
}

variable "general_subnet_address_prefix" {
  description = "The address prefix for the general purpose subnet - i.e. 10.0.100.0/24"
}

variable "hub_virtual_network_name" {

}

variable "hub_virtual_network_id" {

}

variable "hub_virtual_network_resource_group" {

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
  default     = "p-rg-euw-spoke"
  description = "The resource group for the deployments"
}

variable "log_analytics_workspace_id" {
  default     = ""
  description = "The resource group for the deployments"
}
