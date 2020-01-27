# Framework

*Used to deploy various Azure services for testing, demonstration and proof of concept development*

## Pre-requisites

- An existing Azure Storage Account (blob) which can be used to store Terraform state data
- An access key for the Azure Storage Account

## Resources created

### Core
* Resource group - p-rg-euw-core
* Virtual network - p-vn-euw-core, 10.0.0.0/16
* Azure Key Vault - p-kv-euw-core
* Azure Container Register - pcreuwcore
* Service principal for AKS is created - p-sp-aks - and stored in the Key Vault instance
* AKS 


### AKS
* Subnet x - p-sn-euw-core-xxx, 10.0.x.0/24 : "x" is replaced with the value of the "instance_id" variable


### Issues
On a clean run (i.e. running against an empty Azure subscription), we're creating secrets that are uploaded to Azure Key Vault. Other modules depend on those secrets. If the secrets don't exist when you run Terraform, even if they are going to be created prior to those dependant modules, you may see an error stating that the secret does not exist. At present, the easiest way to work around this is to comment out other sections of the template and just run the "core" module on its own. Then uncomment everything and re-run.