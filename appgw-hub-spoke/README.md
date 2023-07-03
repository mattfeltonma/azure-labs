# Application Gateway and Hub and Spoke Lab

## Updates
* 7/2023 - Added support for new Azure Firewall logs
* 12/2022
  * Updated base environment
  * Added more complex web app
  * Added App Gateway private listener
  * Added Private DNS Zone for custom domain

## Overview
Organizations in regulated industries are typically required to mediate and inspect traffic between users and applications when the application provides access to sensitive data. While the capabilities in Web Application Firewalls are becoming more robust, many organizations still prefer to pass the traffic through a traditional firewall for additional IDS/IPS and centralized logging of all network traffic. This pattern demonstrates how organizations can balance democratization of Application Gateway with the needs for IDS/IPS through a centralized security appliance.

Using [a standard hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli) this lab demonstrates a pattern where an [Application Gateway running in the dedicated workload Virtual Network](https://github.com/mattfeltonma/azure-networking-patterns#single-nva-internet-to-azure-http-and-https-with-ids-ips-option-2) exposes an workload running App Services. The App Services instance has been configured with a [Private Endpoint](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview) and [Regional VNet (Virtual Network) Integration](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration) to ensure full visibility of incoming and outgoing traffic. 

An Azure Firewall is provisioned in the hub virtual network with [UDRs (User defined routes)](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview#user-defined) all north, south, east, and west traffic through the Azure Firewall. The Application Gateway subnet is configured to send traffic received by the Application Gateway and destined through the App Service through the Azure Firewall for centralized mediation and optional inspection. The firewall has been configured to SNAT traffic to the workload virtual network to ensure traffic symmetry.

All virtual networks are configured to use the Azure Firewall as a DNS provider to allow for logging of DNS queries. The Azure Firewall is configured to use an Azure Private DNS Resolver in the Shared Services virtual network for its resolution to support conditional forwarding to on-premises. Common Private DNS Zones for Azure PaaS services are created and linked to the Shared Services virtual network which allows the Private DNS Resolver to resolve records for Private Endpoints created in the environment.

Ubuntu and Windows virtual machines are deployed as utility servers. The Windows VM is provisioned with Google Chrome, Visual Studio Code, Azure CLI, and Azure PowerShell. The Linux VM is provisioned with Azure CLI, kubectl, and Docker.

The workload virtual network contains the Application Gateway and App Service running a basic Python application. The Application Gateway is configured to route traffic for the domain you reference using a wildcard record (example: *.wildcard.com).

The application can be accessed both privately and publicly through the application gateway. You can immediately access it from one of the machines included in the lab by opening a web browser and typing in www before your domain name (example: www.mydomain.com). An Azure Private DNS Zone provides resolution for those machines.

To access the application over the Internet from a machine outside of the lab environment, you will need to handle resolution. This can be done by modifying the machines host file.

Additional features included:

* A [simple Python Web App](https://github.com/mattfeltonma/python-sample-web-app) deployed to App Services which retrieves the current time from a public API and a secret from Key Vault
* App Service is provisioned with a managed identity which it used to interact with the Azure Key Vault
* [Application Gateway is configured with a User-Assigned Managed Identity](https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs) which has been granted appropriate permissions to access certificates stored in the Key Vault instance.
* Azure Bastion provisioned in the hub to provide SSH and RDP (Remote Desktop Protocol) to deployed virtual machines
* Diagnostic logging configured for most resources to log to the Log Analytics Workspace
* An Azure Key Vault instance which stores the user configured VM administrator username and password
* All instances of Azure Key Vault are deployed with a Private Endpoint
* Network Security Groups are configured with NSG Flow Logs which are set to an Azure Storage Account and Traffic Analytics
* Subnets are configured so that Private Endpoints support Network Security Groups

![lab image](images/lab_image.svg)

## Prerequisites
1. You must hold at least the Contributor role within each Azure subscription you configure the template to deploy resources to.

2. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance. This will be used for the keyVaultAdmin parameter of the template. Ensure you are using the most up to date version of az cli.

**az ad user show --id someuser@sometenant.com --query id --output tsv**

3. Enable Network Watcher in the region you plan to deploy the resources using the Azure Portal method described in this link. Do not use the CLI option because the templates expect the Network Watcher resource to be named NetworkWatcher_REGION, such as NetworkWatcher_eastus2. The CLI names the resource watcher_REGION such as watcher_eastus2 which will cause the deployment of the environment to fail.

## Installation with Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmattfeltonma%2Fazure-labs%2Fmaster%2Fappgw-hub-spoke%2Fazuredeploy.json)

## Installation with Azure CLI
1. Set the following variables:
   * DEPLOYMENT_NAME - The name of the location
   * DEPLOYMENT_LOCATION - The location to create the deployment
   * LOCATION - The location to create the resources
   * CUSTOM_DOMAIN_NAME - The domain used to access the application publicly. The Application Gateway will be configured with an https listener for this domain. If this is a zone you do not own and do not have access to administer DNS you will need to modify the host file of the machine you are using the test the solution.
   * ADMIN_USER_NAME - The name to set for the VM administrator username
   * ADMIN_OBJECT_ID - The object ID of the Azure AD User that will have full permissions on the Key Vault instances
   * SUBSCRIPTION - The name or id of the subscription you wish to deploy the resources to
   * ON_PREM_ADDRESS_SPACE - This is an optional parameter that represents on-premises address space

2. Set the CLI to the subscription you wish to deploy the resources to:

   * **az account set --subscription SUBSCRIPTION_ID**

4. Deploy the lab using the command (tags parameter is optional): 

   * **az deployment sub create --name $DEPLOYMENT_NAME --location $DEPLOYMENT_LOCATION --template-uri https://raw.githubusercontent.com/mattfeltonma/azure-labs/master/appgw-hub-spoke/azuredeploy.json --parameters location=$LOCATION customDomainName=$CUSTOM_DOMAIN_NAME vmAdminUsername=$ADMIN_USER_NAME keyVaultAdmin=$ADMIN_OBJECT_ID tags='{"mytag":"value"}'**

3.  You will be prompted to provide a password for the local administrator of the virtual machine. The username and password you set will be available to you as secrets in the "central" Key Vault provisioned as part of this lab.

## Post Deployment

Once the lab is deployed, you can access the application both over the public and private IP addresses. 

* To access the application over the private IP address  use one of the machines provisioned into the Shared Services virtual network.

* To access the application over the public IP address use a machine outside the environment. You will need to to ensure the DNS of the machine resolves the www record for the domain you provided to the public IP address of the Application Gateway. This can be done via the local hosts file. You must access the application over port 8443 (ex: https://www.mydomain.com:8443).
## Cleanup

Delete the resource groups created by this lab





