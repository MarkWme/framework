variable "name" {
  default     = "core"
  description = "This value will be used as part of the names of the resources being created"
}

variable "virtual_network_address_space" {
  description = "The address space for the core virtual network - i.e. 10.0.0.0/16"
}

variable "general_subnet_address_prefix" {
  description = "The address prefix for the general purpose subnet - i.e. 10.0.100.0/24"
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
  default     = "p-rg-euw-core"
  description = "The resource group for the deployments"
}

variable "tenant_id" {
  description = "Tenant ID required for Key Vault creation. Should be the tenant that will be used to authenticate key vault requests."
}

variable "service_principal_object_id" {
  description = "Object ID of the service principal that will be granted access to key vault"
}

variable "ssh_file_location" {
    type = string
    default = "/home/mark/.ssh/id_rsa.pub"
    description = "Locatin of your public SSH key file. This will be uploaded to Key Vault."
}
