#!/bin/sh

#
# Environment variables needed to run this script
#
# Obviously, copy this file somewhere else outside of this repo
# and then fill in the blanks with the relevant details.
#
# Do NOT commit this file to your repo once it has all of your
# secrets in it!
#
# Access key for the Azure Storage account where the Terraform
# state will be held
#
export ARM_ACCESS_KEY=
#
# Details of the service principal that Terraform will run as
#
export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
export ARM_SUBSCRIPTION_ID=
export ARM_TENANT_ID=
#
# Set these to enable debug logging if required
#
export TF_LOG=
export TF_LOG_PATH=