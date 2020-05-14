# Azure VPN Gateway Lab

## Overview
Microsoft documentation around routing in a hub and spoke architecture with an ExpressRoute Gateway is very [well documented](https://github.com/microsoft/Common-Design-Principles-for-a-Hub-and-Spoke-VNET-Archiecture).  The same cannot be said for routing when using a VPN Gateway.  While the VPN Gateway pattern is much less common in an enterprise, it provides a wonderful solution to practice with BGP and route propagation with a [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke).

This ARM template creates a small lab in Azure that includes a hub and spoke architecture with a VPN Gateway that is configured for a site-to-site VPN connection with your VPN appliance.  Azure supports a variety of [devices](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices) such as the open source solution [pfSense](https://www.pfsense.org/).  It can be used to demonstrate routing between spoke virtual networks, forced tunneling back on-premises, and BGP route propagation.  An example of the lab is illustrated below:

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/vpn-hub-and-spoke/vpn-lab.GIF)

## Installation
1.  Create a resource group.
2.  Deploy the template to the resource group using the New-AzResourceGroupDeployment cmdlet.  Example: **New-AzResourceGroupDeployment -Name "myDeployment" -ResourceGroupName "myResourceGroup" -TemplateUri "https://raw.githubusercontent.com/mattfeltonma/arm-templates/master/labs/routing-in-azure/maintemplate.json" -TemplateParameterFile "<FILE_PATH>"**
3.  You will be prompted to provide an administrator user name and password for the local administrator accounts on the virtual machines.

Note that you must provide two secure strings within the parameters file.  The sample parameters file in the repository demonstrates how to pull these secrets from an instance of Azure Key Vault.  Alternative, these two parameters could be provided at the command line using the commmand below:

**New-AzResourceGroupDeployment -Name mydeployment -ResourceGroupName "myresourcegroup" -TemplateUri https://raw.githubusercontent.com/mattfeltonma/arm-templates/master/labs/vpn-hub-and-spoke/main.json -TemplateParameterFile "<FILE_PATH>" -vmAdminPassword (ConvertTo-SecureString -Force -AsPlainText 'somepassword') -vpnSharedSecret (ConvertTo-SecureString -force -AsPlainText 'somepassword')**

