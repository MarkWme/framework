name = "core"
azure_region = "westeurope"
environment = "production"
ssh_file_location = "/home/mark/.ssh/id_rsa.pub"
networks = {
    virtual_network                = "10.0.0.0/16",
    firewall_subnet                = "10.0.0.0/26",
    bastion_subnet                 = "10.0.0.64/26",
    jumpbox_subnet                 = "10.0.0.128/26",
    aks_subnet                     = "10.0.1.0/24",
    general_subnet                 = "10.0.100.0/24",

    private_aks_virtual_network    = "10.1.0.0/16",
    private_aks_subnet             = "10.1.1.0/24"
}