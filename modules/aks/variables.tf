variable "location" {
    type = string
    default     = "westeurope"
    description = "The location for the deployments"
}

variable "resource_group_name" {
    type = string
    default = "p-rg-euw-core"
    description = "The resource group where the AKS cluster will be deployed"
}

variable "kubernetes_version" {
    type = string
    default = ""
    description = "The version of Kubernetes to deploy"
}