# Azure Function with Private Endpoint and Regional VNet Integration

## Overview
Organizations in regulated industries are often required to mediate and sometimes inspect traffic to and from applications or code that providing access to or are capable of accessing sensitive data. These applications or code may also need to access resources which exists on-premises or are being exposed only within a customer's private network within a public cloud provider using a feature such as Microsoft Azure's [Private Endpoints](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview). While influencing incoming and outgoing network for applications or code running in an IaaS (Infrastructure-as-a-Service) offering is straightforward, the patterns differ when using PaaS (Platform-as-a-Service).

[Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/) is a serverless PaaS offering in Microsoft Azure which can be used to run code based upon a trigger or event. Common use cases include Web APIs, performing simple data processing, or even automatically remediating a resource which has drifted out of compliance. Azure Functions can run in both a dedicated enviroment with an [ASE (App Services Environment)](https://docs.microsoft.com/en-us/azure/app-service/environment/) or in a multi-tenant environment with a [Consumption or Premium plan](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale#overview-of-plans).

When running an Azure Function in a multi-tenant environment using a Premium Plan, Microsoft provides two separate features to allow for influencing incoming and outgoing networking traffic. [Private Endpoints](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview) provide the customer with the ability to create a network interface for the Azure Function within their Azure VNet (Virtual Network) to influence incoming traffic. [Regional VNet Integration](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration) provides the customer with the ability to force outgoing traffic from the Azure Function to flow through the customer's VNet.

This deployable lab provides a simple way to test and experiment with these features. It deploys an Azure Function configured with a Private Endpoint and Regional VNet integration. A [simple web application](https://github.com/mattfeltonma/azure-function-example) is deployed to the Azure Function which upon accessed will query a public API for the current time. The function is deployed into a [hub and spoke networking architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli). [UDRs (User defined routes)](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview#user-defined) assigned to the subnet delegated for Regional VNet integration are used to force outgoing traffic from the function through an Azure Firewall which is provisioned into the hub VNet.

A Windows Server 2019 VM (virtual machine) is deployed into the hub VNet and is provisioned with Windows Remote Server Administration Tools, Google Chrome, Azure CLI, Azure PowerShell, and Visual Studio Code. UDRs assigned to the VM's subnet are used to force traffic destined to the Azure Function through the Azure Firewall instance.

Additional features included:

* Azure Bastion provisioned in the hub to provide secure RDP (Remote Desktop Protocol) access to the VM
* Azure Firewall configured to send diagnostic logs to an instance of Log Analytics Workspace to allow for inspection of the traffic flowing to and from the Azure Function
* Azure Function integrated with an instance of App Insights
* Azure Key Vault which stores the user configured VM administrator username and password

![lab image](../images/lab_visual.svg)

## Installation
1.  Create a resource group.
2.  Deploy the template to the resource group using the New-AzResourceGroupDeployment cmdlet.  Example: **New-AzResourceGroupDeployment -Name "myDeployment" -ResourceGroupName "myResourceGroup" -TemplateUri "https://raw.githubusercontent.com/mattfeltonma/azure-labs/master/app-service-force-tunnel/deploy.json"**  
3.  You will be prompted to provide an administrator user name and password for the local administrator accounts on the virtual machines.
4.  Use a web browser or curl to access the website.




