# Azure Routing Lab

## Overview
Microsoft Azure offers significant flexibility when routing traffic to Azure, within a virtual network in Azure, and across virtual networks within Azure.  Experimentation with these concepts is a necessity to understand the intricacies of Azure's software defined networking implementation.  This is especially important for those people new to the cloud or coming to Azure from other public clouds such as AWS.

This ARM template creates a small lab in Azure that demonstrates the differents options to route traffic in Azure.  It uses a [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) with multiple spokes and another Virtual Network connected to the hub through Vnet-To-Vnet VPN.  A high level image of the lab is pictured below and detailed in the included [PDF](https://github.com/mattfeltonma/azure-labs/blob/master/routing-in-azure/lab_visual.PNG).

![lab image](https://github.com/mattfeltonma/azure-labs/routing-in-azure/blob/master/lab_visual.PNG)

The lab provides for the following traffic mediation patterns where traffic is routed through a network virtual appliance where it can be filtered.  In this scenario Azure Firewall is used but 3rd party NVAs could also leverage this pattern.

* Mediate traffic between virtual machines in a subnet
* Mediate traffic between virtual machines within the same Virtual Network
* Mediate traffic between virtual machines in different peered Virtual Networks
* Mediate traffic between virtual machines in separate spoke Virtual Networks
* Mediate traffic from on-premises to a spoke Virtual Network

The Azure Firewall instance has been configured to write its logs to a Log Analytics Workspace to verify traffic patterns.  You can leverage [these Kusto queries](https://docs.microsoft.com/en-us/azure/firewall/log-analytics-samples) to analyze the data written to Log Analytics.

The lab will cost around $50 - $100 a day if you shut the virtual machines down off hours.

## Installation
1.  Create a resource group.
2.  Deploy the template to the resource group using the New-AzResourceGroupDeployment cmdlet.  Example: **New-AzResourceGroupDeployment -Name "myDeployment" -ResourceGroupName "myResourceGroup" -TemplateUri "https://raw.githubusercontent.com/mattfeltonma/arm-templates/master/labs/routing-in-azure/maintemplate.json"**  
3.  You will be prompted to provide an administrator user name and password for the local administrator accounts on the virtual machines.



