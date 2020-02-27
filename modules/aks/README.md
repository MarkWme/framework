# AKS Module

This module deploys an instance of the Azure Kubernetes Service (AKS) including following resources:

* A Service Principal
* A subnet with optional route table
* An AKS cluster with optional Windows container support

The Service Principal is created using the Service Principal Module.

The AKS deployment is configured to use Azure CNI networking and therefore needs to be attached to a subnet. A subnet is created within the specified Virtual Network. If a route table has been specified, it is associated with the newly created subnet. This option allows scenarios such as forcing all traffic through a firewall.

The module expects to find an SSH public key stored in the specified Azure Key Vault. This SSH key is used when deploying the Linux nodes.  For Windows nodes, an admin password is randomly generated and stored in the same Azure Key Vault instance for later reference.

The module expects a Log Analytics Workspace so that Container Insights can be enabled.

The AKS deployment supports the following options

* Use the latest GA or Preview version of Kubernetes
* Auto scaling
* Pod Security Policies
* Private Clusters
* Windows Containers


