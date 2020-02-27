# Framework

This repo contains a set of [Terraform](https://www.terraform.io/) scripts and modules that I use to quickly spin-up resources in my Azure subscription.

In my day job, I often need to deploy Azure resources so that I can work on building out proof of concept and demo environments. I created this repo to provide the following

- A base set of resources that are frequently used across a number of Azure services.
- Modules that allow me to quickly deploy instances of Azure resources and any necessary dependencies for those resources, such as service principals.

I will add more resource types to this repo over time, probably as I need to use each of those resource types!

## Pre-requisites

This is intended to be run from the command line and therefore uses Terraform's ability to authenticate to Azure via the Azure CLI. So, you need to be signed in to the appropriate Azure subscription via the Azure CLI before you run anything.

[Authenticating using the Azure CLI](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html)

Terraform stores state information about the resources it creates locally. This state information is easily readable and contains secrets / passwords in clear text. A more secure way of handling this is to get Terraform to use an encrypted Azure Storage account to store the state information. This also means that the state persists, for example, if you get a new laptop.

For the Terraform state information, you therefore need to have pre-created an Azure Storage Account (blob) before running any of the Terraform scripts. The account will need to have the "Storage Blob Data Owner" role assigned to the account you are signed in with via the Azure CLI.

The `backend.hcl` file should contain details of the resource group, storage account, container and blob where your state information will be stored.

| Value | Description |
| --- | --- |
| resource_group_name | Name of the Azure Resource Group where the storage account resides |
| storage_account_name | Name of the Azure Storage Account |
| container_name | Name of the Blob container where the state will be stored |
| key | Name of the Blob (file) that will hold the state information |

## Resources created

The root script calls a number of modules to deploy a set of core and additional resources. See the README files in the respective module folders for more details.

At a high level, the script current deploys

* A resource group
* A virtual network
* A "general purpose" subnet for various resources to be deployed into
* An instance of Azure Key Vault
* An instance of Azure Container Registry
* An instance of Azure Kubernetes Service with optional Windows Container support
* A Linux Virtual Machine with optional data disks
* A "private" network consisting of Azure Firewall, Azure Bastion and a "jumpbox" Linux VM, each residing on a separate subnet
* A "private" instance of Azure Kubernetes Service with no public endpoints and all traffic routed via Azure Firewall

The script is configured to mandate a naming standard, which is often helpful in demonstrating to customers how Terraform can help deploy resources that conform to their standards.

I try to keep all of the variables that need to be defined in the root `terraform.tfvars` file so that it's easy to locate and change values.

### AKS

The AKS module aims to make it easy to deploy a standardised instance of a Kubernetes cluster.

* Subnet x - p-sn-euw-core-xxx, 10.0.x.0/24 : "x" is replaced with the value of the "instance_id" variable
* Service principal for AKS instance is created and stored in the Key Vault instance
* An AKS cluster using Virtual Machine Scale Sets, with autoscaling enabled by default and Advanced Networking.


### Issues
On a clean run (i.e. running against an empty Azure subscription), we're creating secrets that are uploaded to Azure Key Vault. Other modules depend on those secrets. If the secrets don't exist when you run Terraform, even if they are going to be created prior to those dependant modules, you may see an error stating that the secret does not exist. At present, the easiest way to work around this is to comment out other sections of the template and just run the "core" module on its own. Then uncomment everything and re-run.