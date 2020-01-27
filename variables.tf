variable "location" {
    type = string
    default     = "westeurope"
    description = "The location for the deployments"
}

variable "ssh_file_location" {
    type = string
    default = "/home/mark/.ssh/id_rsa.pub"
    description = "Locatin of your public SSH key file. This will be uploaded to Key Vault."
}
