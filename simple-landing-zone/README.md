# Azure Simple Landing Zone (Work in progress)

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
* Log Analytics Workspace where all resources send logs and metrics to
* Storage Account where all Network Security Groups deliver NSG Flow Logs to
* Traffic Analytics configured for all Network Security Groups
* Key Vault instance configured for central secrets storage
* Transit resources, shared services resources, and spoke resources deployed in different resource groups

