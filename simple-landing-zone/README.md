# Azure Simple Landing Zone

## Overview
This ARM template creates an environment in Microsoft Azure that is based off the [Enterprise-Scale Landing Zone](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/architecture) from the [Microsoft Cloud Adoption Framework](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/).   

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/azure-spring-cloud/images/lab.jpeg)

Features of this lab include:
* Network
* * Azure Firewall is installed in the hub virtual network and is used to mediate traffic between virtual networks and to and from the Internet.
* * Azure Firewall is configured as a [DNS proxy](https://docs.microsoft.com/en-us/azure/firewall/dns-settings#dns-proxy) and all virtual networks are configured to use it for DNS resolution.
* * Azure Private Endpoints are deployed for the Log Analytics instance and centralized logging storage account.
* * Network Security Groups (NSGs) are configured on each subnet which supports them. Note that NSGs are configured on Private Endpoint subnets in anticipation of future support for NSGs with Private Endpoints.
* * Azure Bastion has been deployed in the hub to provide for remote access to virtual machines deployed in the environment.
* Logging
* * Azure Firewall is configured with all diagnostic logs which are sent to a Log Analytics Workspace.  You can leverage [these Kusto queries](https://docs.microsoft.com/en-us/azure/firewall/log-analytics-samples) to analyze Azure Firewall log data written to Log Analytics.
* * Network Security Groups are configured to log to a central storage account.
* Other
* * A Windows Server 2019 virtual machine is deployed in the shared services virtual network and can be used for privileged access to other virtual machines.
* * Network Security Groups in the shared services virtual network have been configured to support inbound flows for anticipated Windows Active Directory virtual machines deployed in the snet-ad subnet.


## Prerequisites
1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. Run the two commands below to add the required extensions to Azure CLI.

    `az extension add --name firewall`

    `az extension add --name spring-cloud`
    
3. Record your tenant id of the Azure AD instance associated with the subscription you will be deploying to.

    `az account show --subscription mysubscription --query tenantId --output tsv`

4. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance.

    `az ad user show --id someuser@sometenant.com --query objectId --output tsv`

5. Get the object id of the Spring Cloud Resource Provider from your Azure AD tenant.

    `az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --output tsv`

6. Create a resource group to deploy the resource to.

    `az group create --name my-resource-group`

## Installation
1. Execute the template including the parameters of the tenant id from step 3, the object id from step 4, the object id from step 5, and a username for the administrator account on the virtual machine created and for the My SQL instance.

    `az deployment group create --resource-group my-resource-group --name initial --template-file="https://raw.githubusercontent.com/mattfeltonma/azure-labs/master/azure-spring-cloud/deploy.json" --parameters tenantId <TENANT_ID>  keyVaultAdminObjectId <KEY_VAULT_ADMIN_OBJECT_ID> springCloudPrincipalObjectId <SPRING_CLOUD_SP_OBJECT_ID>`

You will be prompted to set a password.  This will be the password for the virtual machine and the My SQL instance.

2. Run the add-routes.sh bash script or the commands within it to set the default routes on the Spring Cloud subnets.

## Post Installation
Install one of the following sample applications:
* [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)
* [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices)





