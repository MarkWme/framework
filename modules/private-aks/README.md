# Private AKS

This module creates a virtual network and subnets for deployment of a private AKS cluster with no public IP addresses.

This is designed to be peered to a core / hub network (in a hub / spoke network design) where the hub network contains a firewall and a method of egress to the Internet, thereby allowing controlled access from the AKS cluster to the public Internet to dowmnload host updates, sync time, pull images etc.

