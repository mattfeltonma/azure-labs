# Azure Simple Landing Zone

## Overview
This project creates an environment I'm branding a "simple landing zone". It is loosely based off the [Microsoft Enterprise-Scale Landing Zone](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/architecture) but is intended to be more simplistic and for the purposes of proof-of-concepts and experimentation. The project uses a combination of ARM templates and PowerShell DSC to deploy to create a security-driven "Enterprise-Scale like" environment for organizations to use for proof-of-concepts in Microsoft Azure.

The environment consists of three sets of resources as documented below which include shared services resources, transit resources, and workload resources. These resources are deployed in resource groups named for the function and can optionally be deployed in resource groups in different subscriptions to limit the blast radius of failed changes or security breaches.

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/simple-landing-zone/images/simple-landing-zone-v2.png)

## Key Design Principles

**Support for smaller blast radius**
* Allows for multi-subscription deployment
* Deploys resources into separate resource groups based on function and likely administration model
* Separate Key Vault instances for core services and workloads

**Provide a centralized authentication service for Windows virtual machine access**
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
* Shared Services Virtual Machines are encrypted with SSE w/ Managed Disk and CMK

**Support Least Privilege**
* Three resource groups deployed with one for shared services, one for network transit, and one for workload allowing fine grained access for systems, networking, and development teams

**Central secrets storage**
* Domain username and password are stored in core services' Azure Key Vault
* CMK used for core services' Virtual Machine encryption stored Azure Key Vault
* Instance of Azure Key Vault available for workload secrets storage

**Centralization of logs and metrics**
* Logs and metrics centralized in instance of Log Analytics
* Diagnostic logging enabled for PaaS resources 
* Microsoft Monitoring Agent, VM Insights deployed to virtual machines to improve visiblity to performance and security
* Network Security Groups configured to centralize flow logs in storage account
* Traffic Analytics monitoring solution enabled for NSG flow logs
* Key Vault Analytics monitoring solution enabled for visibility into Key Vault access

**Additional Features and Notes**
* Windows Server VM utility server joined to Active Directory domain with SQL Server Management Studio, Remote Server Administration Tools, Az CLI, and Az PowerShell modules installed
* Ubuntu Server VM utility server with Az CLI, kubectl, and Docker installed
* Ubuntu Server VM uses the administrator username and password supplied at deployment

## Prerequisites
1. You must hold at least the Contributor role within each Azure subscription you configure the template to deploy resources to. 

2. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

3. Ensure the following [resource providers](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types) are registered in each subscriptions you plan to deploy resources to. The required resource providers are:

    * Microsoft.Network
    * Microsoft.Insights
    * Microsoft.Keyvault
    * Microsoft.Compute
    * Microsoft.ContainerRegistery
    * Microsoft.Storage
    * Microsoft.OperationalInsights
    * Microsoft.OperationsManagement
    * Microsoft.Resources

4. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance. This will be used for the keyVaultAdmin parameter of the template.

    `az ad user show --id someuser@sometenant.com --query objectId --output tsv`

5. Enable Network Watcher in the region you plan to deploy the resources using the Azure Portal method described in [this link](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-create#create-a-network-watcher-in-the-portal). Do not use the CLI option because the templates expect the Network Watcher resource to be named NetworkWatcher_REGION, such as NetworkWatcher_eastus2. The CLI names the resource watcher_REGION such as watcher_eastus2 which will cause the deployment of the environment to fail.
    
## Installation

Use the Deploy to Azure button below. Note that the template will take about 2 hour to fully deploy.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmattfeltonma%2Fazure-labs%2Fmaster%2Fsimple-landing-zone%2Fazuredeploy.json)

**The template allows for the following parameters**
* sharedServicesSubId - The subscription id of the subscription to deploy the Shared Services resources to
* transitServicesSubId - The subscription id of the subscription to deploy the Transit resources to
* workloadSubId - The subscription id of the subscription to deploy the Workload resources to 
* adDomainName - The DNS domain name assigned to the Active Directory domain.
* adNetBiosName - The NetBIOS name assigned to the Active Directory domain.
* location - The region the resources will be provisioned to.
* keyVaultAdmin - The object id of the user or group security principal that will be the administrator of the Key Vault. Note that the permissions assigned to the security principal exclude destructive permissions such as purge. Review the permissions in the /templates/general/deploy-keyvault.json template for a detailed list of the permissions.
* vmAdminUsername - The username for the local administrators of the two virtual machines provisioned. This will also be the name of the built-in Domain Administrator in the Active Directory domain.
* vmAdminPassword - The password assigned to the local administrator account of the virtual machines, the Active Directory domain administrator account, and the sample Active Directory user accounts. You can change these later on to improve the security posture of the environment. This must be supplied as a secure string.

## Known Issues
* [Issue 31](https://github.com/mattfeltonma/azure-labs/issues/31) Sometimes the template will fail to deploy in East US 2 at the Log Analytics Private Endpoint deployment step with an InternalServerError. Delete the resources and re-run the template if this occurs. There is no solution for this problem at this time.

## Change Log
* 6/9/2021
  * Added support for multi-subscription deployment
  * Added instance of Azure Key Vault for workload
  * Created linked template for Azure Key Vault key deployment
  * Modified Private Endpoints for core services and moved them into Shared Services Virtual Network
  * Updated lab image and added Visio
  * Adding scaffolding to future workload deployments of different types

* 4/20/2021
  * Added centralized Azure Container Registry behind a Private Endpoint

* 4/18/2021
  * Added Docker installation to Ubuntu server post-provisioning script
  * Modified Firewall Policy to include empty DNAT rule collection
  * Modified Log Analytics Private Endpoint to provision first to address issue where it would fail randomly
  
* 4/8/2021
  * Added provisioning script to install SQL Server Management Studio, Az CLI, Az PowerShell module, and Windows Remote Server Administration Tools
  * Added Ubuntu VM and a post-provisioning script to install Az CLI and kubectl

* 3/16/2021
  * Converted Azure Firewall rules to Firewall Policy to support eventual testing with Azure Firewall Premium SKU

* 3/11/2021
  * Added support for SSE for Managed Disks with CMK
  * Configured username and password set by user to be stored as secrets in Key Vault
  * Added Key Vault Analytics solution


