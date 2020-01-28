# Framework

This repo contains a set of [Terraform](https://www.terraform.io/) scripts and modules that I use to quickly spin-up resources in my Azure subscription.

In my day job, I often need to deploy Azure resources so that I can work on building out proof of concept and demo environments. I created this repo to provide the following

- A base set of resources that are frequently used across a number of Azure services.
- Modules that allow me to quickly deploy instances of Azure resources and any necessary dependencies for those resources, such as service principals.

I will add more resource types to this repo over time, probably as I need to use each of those resource types!

## Pre-requisites

This is intended to be run from the command line and therefore uses Terraform's ability to authenticate to Azure via the Azure CLI. So, you need to be signed in to the appropriate Azure subscription via the Azure CLI before you run anything.

[Authenticating using the Azure CLI](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html)

Terraform stores state information about the resources it creates locally. This state information is easily readable and contains secrets / passwords in clear text. A more secure way of handling this is to get Terraform to use an encrypted Azure Storage account to store the state information. This also means that the state persists, for example if you get a new laptop.

For the Terraform state information, you therefore need to have pre-created the following before running any of the Terraform scripts

- An Azure Storage Account (blob)
- An access key for the Azure Storage Account

The access key should be stored in an environment variable named `ARM_ACCESS_KEY`. It will then be automatically used by Terraform. You can use the `tf_env.sh` script file to set up this environment variable before you run Terraform.

The details of the storage account need to be provided to Terraform via the `terraform` block. You'll find this at the top of the `main.tf` file in the root of this repository. The values required are as follows:

| storage_account_name | Names of the Azure Storage Account |
| container_name | Name of the Blob container where the state will be stored |
| key | Name of the Blob (file) that will hold the state information |

## Resources created

The script structure aims to provide a set of Core resources that are used / shared by other Azure resources and a set of modules that can be included to deploy specific Azure resources as required.

### Core

This is the set of shared "Core" resources

* Resource group - p-rg-euw-core
* Virtual network - p-vn-euw-core, 10.0.0.0/16. Subnets are not created, this is left for other modules to do.
* Azure Key Vault - p-kv-euw-core - An SSH public key is copied from your local computer to Key Vault to be used in deployments of Virtual Machines.
* Azure Container Register - pcreuwcore


### AKS

The AKS module aims to make it easy to deploy a standardised instance of a Kubernetes cluster.

* Subnet x - p-sn-euw-core-xxx, 10.0.x.0/24 : "x" is replaced with the value of the "instance_id" variable
* Service principal for AKS instance is created and stored in the Key Vault instance
* An AKS cluster using Virtual Machine Scale Sets, with autoscaling enabled by default and Advanced Networking.


### Issues
On a clean run (i.e. running against an empty Azure subscription), we're creating secrets that are uploaded to Azure Key Vault. Other modules depend on those secrets. If the secrets don't exist when you run Terraform, even if they are going to be created prior to those dependant modules, you may see an error stating that the secret does not exist. At present, the easiest way to work around this is to comment out other sections of the template and just run the "core" module on its own. Then uncomment everything and re-run.