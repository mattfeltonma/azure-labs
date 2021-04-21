# Azure Simple Landing Zone

## Overview
This project creates an environment I'm branding a "simple landing zone". It is loosely based off the [Microsoft Enterprise-Scale Landing Zone](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/architecture) but is intended to be more simplistic and for the purposes of proof-of-concepts and experimentation. The project uses a combination of ARM templates and PowerShell DSC to deploy to create a security-driven "Enterprise-Scale like" environment for organizations to use for proof-of-concepts in Microsoft Azure.

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/simple-landing-zone/images/simple-landing-zone.png)

## Key Design Principles

**Provide a centralized authentication service for virtual machine access**
* Windows Active Directory domain complete with sample users and groups

**Restrict access to Azure resources from the Internet**
* Hub and spoke architecture for central management of north-south traffic
* Traffic to and from the Internet is mediated by an instance of Azure Firewall
* Azure PaaS services like Azure Storage and Azure Monitor utilize Azure Private Endpoints
* Azure Bastion used for RDP and SSH access to Virtual Machines

**Microsegmentation of resources**
* Hub and spoke architecture for central management of east-west traffic
* Traffic between spokes is mediated by an instance of Azure Firewall
* Network Security Groups are enabled for subnets within a Virtual Network (where supported)
* Sample spoke deployed supporting three tiered architecture with additional subnet pre-allocated for PaaS services enabled for Private Endpoints

**Encryption-at-rest**
* Virtual Machines are encrypted with SSE w/ Managed Disk and CMK

**Central secrets storage**
* Domain username and password are stored in Azure Key Vault
* CMK used for Virtual Machine encryption stored in Azure Key Vault

**Centralization of logs and metrics**
* Logs and metrics centralized in instance of Log Analytics
* Diagnostic logging enabled for PaaS resources 
* Microsoft Monitoring Agent, VM Insights deployed to virtual machines to improve visiblity to performance and security
* Network Security Groups configured to centralize flow logs in storage account
* Traffic Analytics monitoring solution enabled for NSG flow logs
* Key Vault Analytics monitoring solution enabled for visibility into Key Vault access

**Additional Features**
* Windows Server VM utility server joined to Active Directory domain with SQL Server Management Studio, Remote Server Administration Tools, Az CLI, and Az PowerShell modules installed
* Ubuntu Server VM utility server with Az CLI, kubectl, and Docker installed

## Prerequisites
1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance. This will be used for the keyVaultAdminObjectId parameter of the template.

    `az ad user show --id someuser@sometenant.com --query objectId --output tsv`

## Installation

The template will take about 2 hour to fully deploy. Ensure you have the Contributor or greater on the subscription you are deploying the lab to.

**The template allows for the following parameters**
* adDomainName - The DNS domain name assigned to the Active Directory domain.
* adNetBiosName - The NetBIOS name assigned to the Active Directory domain.
* location - The region the resources will be provisioned to.
* keyVaultAdminObjecId - The user account that will be the administrator of the Key Vault. Note that the permissions assigned to the is account exclude destructive permissions such as purge. Review the permissions in the /templates/shared/deploy-keyvault.json template for a detailed list of the permissions.
* vmAdminUsername - The username for the local administrators of the two virtual machines provisioned. This will also be the name of the built-in Domain Administrator in the Active Directory domain.
* vmAdminPassword - The password assigned to the local administrator account of the virtual machines, the Active Directory domain administrator account, and the sample Active Directory user accounts. You can change these later on to improve the security posture of the environment. This must be supplied as a secure string.

![Deploy to Azure](https://aka.ms/deploytoazurebutton)


## Change Log
* 4/20/2021
  * Added centralized Azure Container Registry behind a Private Endpoint

* 4/18/2021
  * Added Docker installation to Ubuntu server post-provisioning script
  * Modified Firewall Policy to include empty DNAT rule collection
  * Modified Log Analytics Private Endpoint to provision first to address issue where it would fail randomely
  
* 4/8/2021
  * Added provisioning script to install SQL Server Management Studio, Az CLI, Az PowerShell module, and Windows Remote Server Administration Tools
  * Added Ubuntu VM and a post-provisioning script to install Az CLI and kubectl

* 3/16/2021
  * Converted Azure Firewall rules to Firewall Policy to support eventual testing with Azure Firewall Premium SKU

* 3/11/2021
  * Added support for SSE for Managed Disks with CMK
  * Configured username and password set by user to be stored as secrets in Key Vault
  * Added Key Vault Analytics solution


