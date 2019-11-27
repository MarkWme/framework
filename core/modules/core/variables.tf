variable "location" {
  default     = "westeurope"
  description = "The location for the deployments"
}

variable "tenant_id" {
  description = "Tenant ID required for Key Vault creation. Should be the tenant that will be used to authenticate key vault requests."
}