# Azure VWAN Multi-Region Simple Any/Any Lab

## Updates
12/2022 - Initial release

## Overview
[Azure Virtual WAN](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) is an Azure product that provides transitive routing capabilities for Azure. It attempts to be the next evolution to the traditional [hub and spoke networking architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli) simplifying the management of routing between on-premises locations and virtual networks both within regions and across regions. While you may not be using VWAN yet due to limitations within the product, you will be at some point.

This lab deploys a very simple VWAN implementation allowing you to experiment with the basic transitive features of the service. For those coming from a traditional hub-and-spoke it can be a helpful learning tool. It can also be used to establish a base to build more complex patterns such those documented by [Dan Mauser in this repository](https://github.com/dmauser/azure-virtualwan).

The resources deployed to your Azure subscription include an Azure Virtual WAN with two VWAN Hubs in a primary and secondary region of your choosing. Each VWAN Hub is provisioned with a VPN Gateway. Within each region, two virtual networks are created named workload 1 and workload 2. Each virtual network is connected to the VWAN to demonstrate the transitive routing capabilities. 

An Ubuntu virtual machine is created within each virtual network and is provisioned with basic networking tools. Each VM is provisioned with a public IP address and is wrapped with a network security group configured to allow SSH sessions from an IP of your choosing.

Additional features included:

* An Azure Key Vault is provisioned to store the username and password configured for the virtual machines during deployment.
* A Log Analytics Workspace is provisioned and can be used for centralized logging.
* Network Security Groups are configured to store NSG Flow Logs in a storage account and additionally delivering logs to traffic analytics.

![lab image](images/lab_image.svg)

## Prerequisites
1. You must hold at least the Contributor role within each Azure subscription you configure the template to deploy resources to.

2. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance. This will be used for the keyVaultAdmin parameter of the template. Ensure you are using the most up to date version of az cli.

**az ad user show --id someuser@sometenant.com --query id --output tsv**

3. Enable Network Watcher in the region you plan to deploy the resources using the Azure Portal method described in this link. Do not use the CLI option because the templates expect the Network Watcher resource to be named NetworkWatcher_REGION, such as NetworkWatcher_eastus2. The CLI names the resource watcher_REGION such as watcher_eastus2 which will cause the deployment of the environment to fail.

## Installation with Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmattfeltonma%2Fazure-labs%2Fmaster%2Fmulti-region-vwan-simple%2Fazuredeploy.json)

## Installation with Azure CLI
1. Set the following variables:
   * DEPLOYMENT_NAME - The name of the location
   * DEPLOYMENT_LOCATION - The location to create the deployment
   * PRIMARY_LOCATION - The primary Azure region to deploy the resources to.
   * SECONDARY_LOCATION - The secondary Azure region to deploy the resources to.
   * ADMIN_USER_NAME - The name to set for the VM administrator username
   * ADMIN_OBJECT_ID - The object ID of the Azure AD User that will have full permissions on the Key Vault instances
   * SUBSCRIPTION - The name or id of the subscription you wish to deploy the resources to
   * TRUSTED_IP - The IP address that will be allowed through NSGs for SSH connections.

2. Set the CLI to the subscription you wish to deploy the resources to:

   * **az account set --subscription SUBSCRIPTION_ID**

4. Deploy the lab using the command (tags parameter is optional): 

   * **az deployment sub create --name $DEPLOYMENT_NAME --location $DEPLOYMENT_LOCATION --template-uri https://raw.githubusercontent.com/mattfeltonma/azure-labs/master/multi-region-vwan-simple/azuredeploy.json --parameters primaryLocation=$PRIMARY_LOCATION secondaryLocation=$SECONDARY_LOCATION trustedIp=$TRUSTED_IP vmAdminUsername=$ADMIN_USER_NAME keyVaultAdmin=$ADMIN_OBJECT_ID tags='{"mytag":"value"}'**

3.  You will be prompted to provide a password for the local administrator of the virtual machines. The username and password you set will be available to you as secrets in the Key Vault provisioned as part of this lab.

## Post Installation
Once the lab is deployed, you can SSH into the virtual machines from a machine associated with the trusted IP.


