name = "core"
azure_region = "westeurope"
environment = "production"
ssh_file_location = "/home/mark/.ssh/id_rsa.pub"
networks = {
    virtual_network                = "10.0.0.0/16",
    general_subnet                 = "10.0.100.0/24",
    virtual_network_west_europe    = "10.1.0.0/16",
    general_subnet_west_europe     = "10.1.100.0/24"
    virtual_network_uk_south       = "10.2.0.0/16",
    general_subnet_uk_south        = "10.2.100.0/24"
}