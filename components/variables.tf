variable "name" {
    type = string
    default     = "coredev"
    description = "This will be used as part of the resource names"
}

variable "network_id" {
    type = string
    default     = "100"
    description = "Defines the second octet of the network to be used - i.e. 10.x.0.0/16"
}

variable "aks_private_network_id" {
    type = string
    default     = "101"
    description = "Defines the second octet of the network to be used - i.e. 10.x.0.0/16"
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

variable "ssh_file_location" {
    type = string
    default = "/home/mark/.ssh/id_rsa.pub"
    description = "Locatin of your public SSH key file. This will be uploaded to Key Vault."
}

variable "azure_regions" {
  type = map(string)
  default = {
    westeurope  = "euw"
    northeurope = "eun"
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

variable "networks" {
  type = map(string)
  default = {}
}

