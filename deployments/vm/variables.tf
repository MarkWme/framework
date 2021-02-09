variable "name" {
    type = string
    default     = "res"
    description = "This will be used as part of the resource names"
}

variable "key_vault_name" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "key_vault_resource_group" {
    type = string
    default     = null
    description = "Resource group where core components are deployed"
}

variable "virtual_network_name" {
    type = string
    default     = null
    description = "Core virtual network"
}

variable "virtual_network_resource_group" {
    type = string
    default     = null
    description = "Core virtual network"
}

variable "subnet_name" {
    type = string
    default     = null
    description = "Subnet for general purpose use"
}

variable "log_analytics_workspace_name" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "log_analytics_resource_group" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "ssh_key_name" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "azure_region" {
    type = string
    default     = "westeurope"
    description = "The Azure Region where all resources will be deployed"
}

variable "environment" {
    type = string
    default = "development"
    description = "This will be used to add a prefix to resources (d/t/p) to indicate if a resource is part of a dev, test or production environment"
}

variable "azure_regions" {
  type = map(string)
  default = {
    westeurope  = "euw"
    northeurope = "eun"
    uksouth = "uks"
  }
}

variable "environments" {
  type = map(string)
  default = {
    development = "d"
    test        = "t"
    production  = "p"
    temp        = "x"
  }
}

