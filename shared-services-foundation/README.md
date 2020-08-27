# Shared Services Virtual Network
This template creates a simple Shared Services virtual network (VNet) to be used in an Azure [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke).  It creates necessary networking components such as the VNet, subnets, Virtual Network Gateway, Azure Bastion service, network security groups (NSGs), and application security groups (ASGs).  The environment is pictured in the image below.

The template assumes the shared services environment will include the services below.  It is up to the user to deploy the necessary virtual machine (VM) resources required by these services.  They are not part of this template.

* Windows Active Directory (AD) forest administration of intranet workloads
* Windows AD forest for administration of Internet-facing workloads
* Active Directory Federation Services (AD FS) providing modern authentication support (SAML, Open ID Connect, OAuth)
* Active Directory Certificate Services (AD CS) acting as a certificate authority
* Azure Active Directory Connect (AADC) providing synchronization to Azure Active Directory (AAD)
* Jump server acting as the launch point for RDP and SSH sessions to virtual machines in the Shared Services and spoke VNets
* Azure Bastion providing RDP services to the jump server
* (Optional) A subnet has been reserved for the on-demand deployment of Azure Firewall

NSGs have been created and associated to the Internal Windows AD, DMZ Windows AD, Shared Services, and Management subnets.  Each NSG has been configured to deny all traffic and specific rules have been put in place to allow necessary communication.  This includes:

* Required rules to allow access to Windows AD from Windows clients
* Required rules to allow access to AD FS service for authentication to modern authentication services such as Azure Active Directory
* Required rules to allow access to AD CS services for requesting certificates from the certificate authority
* Required rules to allow for certificate revocation list lookups on a web service running on the AD CS servers
* Required rules to allow for configuration fo AD FS from Azure Active Directory Connect service
* Required rules to allow for RDP from Azure Bastion to Management machines
* Required rules to allow for RDP from Management machines to other shared services subnets

ASGs have been setup and used where possible in NSGs.  This includes ASGs for:
* Internal Windows AD servers
* DMZ Windows AD servers
* AD CS servers
* AD FS servers
* Azure AD Connect servers
* Management servers

The environment is pictured below:
![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/hub-and-spoke/lab_visual.PNG)
