name = "core"
azure_region = "westeurope"
environment = "production"
ssh_file_location = "/home/mark/.ssh/id_rsa.pub"
networks = {
    virtual_network                = "10.0.0.0/16",
    general_subnet                 = "10.0.100.0/24"
}