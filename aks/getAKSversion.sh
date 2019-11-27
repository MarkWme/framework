#!/bin/bash

#
# Populate the kubernetes_version Terraform environment variable
# with the latest available non-preview version of Kubernetes
#

export TF_VAR_kubernetes_version=$(az aks get-versions -l westeurope --query 'orchestrators[?isPreview == null].[orchestratorVersion] | [-1]' -o tsv)