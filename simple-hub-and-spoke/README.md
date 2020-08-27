# Azure Simple Hub and Spoke Lab

## Overview
This ARM template creates a small lab in Azure that can be used for learning the Azure platform.  It uses a [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) with a single spoke.  East/West traffic (traffic between resources in the hub and resources in the spoke) and North/South traffic (traffic between the Internet and resources in the hub or spoke) is routed through and mediated with an instance of Azure Firewall.  

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/simple-hub-and-spoke/lab.jpeg)

Additional features of the lab are:

* Azure Bastion for remote access 
* Log Analytics Workspace
* The Azure Firewall instance has been configured to write its logs to a Log Analytics Workspace.  You can leverage [these Kusto queries](https://docs.microsoft.com/en-us/azure/firewall/log-analytics-samples) to analyze Azure Firewall log data written to Log Analytics.  
* A single Windows Server 2016 Virtual Machine in both the hub and spoke Virtual Networks
* Virtual Machines are configured with the Microsoft Monitoring Agent and integrated with the Log Analytics Workspace

A sample parameters file is included in the repository demonstrating how to reference a local administrator password stored in an existing instance of Azure Key Vault.

## Installation
1.  Create a resource group.
2.  Deploy the template to the resource group using the New-AzResourceGroupDeployment cmdlet.  Example: **New-AzResourceGroupDeployment -Name "myDeployment" -ResourceGroupName "myResourceGroup" -TemplateUri "https://raw.githubusercontent.com/mattfeltonma/azure-labs/master/simple-hub-and-spoke/deploy.json"**  
3.  You will be prompted to provide an administrator user name and password for the local administrator accounts on the virtual machines.



