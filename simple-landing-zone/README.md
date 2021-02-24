# Azure Simple Landing Zone

## Overview
This project creates an environment I'm branding a "simple landing zone". It is loosely based off the [Microsoft Enterprise-Scale Landing Zone](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/architecture) but is intended to be more simplistic. The project uses a combination of ARM templates and PowerShell DSC to deploy to create an "Enterprise-Scale like" environment for organizations to use for proof-of-concepts in Microsoft Azure.

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/simple-landing-zone/images/simple-landing-zone.png)

Key design principles include:

* Provide a centralized authentication service for virtual machine access
* Restrict access to Azure resources from the Internet
* Mediate north/south (Internet to Azure) and east/west (spoke to spoke) traffic
* Microsegmentation of resources
* Centrally log security and operationals logs and metrics
* Central secrets storage
* Build for separation of duties

The project includes the following features:
* Active Directory domain provisioned with sample users and groups
* Azure PaaS services are deployed using Private Endpoints
* Azure Bastion for remote access to virtual machines
* Azure Firewall instance mediates north/south and east/west traffic
* Hub and spoke architecture used to control traffic
* Private Endpoints for Shared Services resources deployed in transit virtual network
* Each subnet in a virtual network includes an associated Network Security Group (where supported)
* Azure Firewall and Network Security Group associated with Active Directory subnet are configured with required Active Directory network flows
* Central Log Analytics Workspace configured to collect logs from all Azure resources including Application, System, and Directory Services Event Logs from Azure Virtual Machines
* Storage Account where all Network Security Groups deliver NSG Flow Logs to
* Traffic Analytics configured for all Network Security Groups
* Key Vault instance configured for central secrets storage
* Transit resources, shared services resources, and spoke resources deployed in different resource groups

## Prerequisites
1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance. This will be used for the keyVaultAdminObjectId parameter of the template.

    `az ad user show --id someuser@sometenant.com --query objectId --output tsv`

## Installation

1. The template allows for the following parameters
    * adDomainName - The DNS domain name assigned to the Active Directory domain.
    * adNetBiosName - The NetBIOS name assigned to the Active Directory domain.
    * location - The region the resources will be provisioned to.
    * keyVaultAdminObjecId - The user account that will be the administrator of the Key Vault. Note that the permissions assigned to the is account exclude destructive permissions such as purge. Review the permissions in the /templates/shared/deploy-keyvault.json template for a detailed list of the permissions.
    * vmAdminUsername - The username for the local administrators of the two virtual machines provisioned. This will also be the name of the built-in Domain Administrator in the Active Directory domain.
    * vmAdminPassword - The password assigned to the local administrator account of the virtual machines, the Active Directory domain administrator account, and the sample Active Directory user accounts. You can change these later on to improve the security posture of the environment. This must be supplied as a secure string.

2. Execute the template. Use the object id you collected in the prerequisites for the keyVaultAdminObjectId parameter.

    `az deployment sub create --name slz --location EastUS2 --template-uri "https://raw.githubusercontent.com/mattfeltonma/azure-labs/master/simple-landing-zone/deploy.json" --parameters adDomainName=mydomain.com adNetBiosName=mydomain location=eastus2 keyVaultAdminObjectId=ffffffff-ffff-ffff-ffff-ffffffffffff vmAdminUsername=masteruser`

3. You will be prompted to enter a secure string for the vmAdminPassword. Provide the value and press enter.

The template will take around 1 hour to fully deploy. After the environment is deployed you can access the virtual machines using the Azure Bastion instance.
