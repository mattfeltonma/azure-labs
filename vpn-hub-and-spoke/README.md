# Azure VPN Gateway Lab

## Overview
Microsoft documentation around routing in a hub and spoke architecture with an ExpressRoute Gateway is very [well documented](https://github.com/microsoft/Common-Design-Principles-for-a-Hub-and-Spoke-VNET-Archiecture).  The same cannot be said for routing when using a VPN Gateway.  While the VPN Gateway pattern is much less common in an enterprise, it provides a wonderful solution to practice with BGP and route propagation with a [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke).

This ARM template creates a small lab in Azure that includes a hub and spoke architecture with a VPN Gateway that is configured for a site-to-site VPN connection with your VPN appliance.  Azure supports a variety of [devices](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices) such as the open source solution [pfSense](https://www.pfsense.org/).  An example of the lab is illustrated below:

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/routing-in-azure/lab_visual.PNG)

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



