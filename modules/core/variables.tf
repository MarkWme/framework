variable "location" {
  default     = "westeurope"
  description = "The location for the deployments"
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
