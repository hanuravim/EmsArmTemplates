This template creates 2 new Windows VMs (2016-Datacenter), create a new AD Forest, Domain and 2 DCs in an availability set.
Prerequisites:
•	Virtual network and Subnet of the domain controller
•	OMS Log Analytics Workspace
Parameters:
Parameter Name	Description
ApplicationName
	Application identifiers as desired. Max length – 3 characters. E.g.: EMS
Environment_Category
	Quality of the deployment e.g.: dev, prod, qa. Max length – 1 character, e.g.: d,p,q
shortlocation
	Location acronym. Max length – 3. E.g.: eu for east US, eu2 for east US 2
resourcelocation
	Location of the resource to be created. Eg: east us, west us.
Tenant
	Customer acronym. Max length – 4 characters. Eg: AAL
Role	Functionality of the deployed resource. Max length – 3.eg: web, net
keyVault_Name	Name of the existing keyvault in same subscription
keyVault_ResourceGroup	Resource group containing the above keyvault
subnet_Names
	Names of the existing subnets created by the Network template
vnet_addressPrefix	CIDR notations of the VNET address space
omsWorkspaceOrdinal	Numeric difference in OMS workspace names for different environments. Eg: prod – 1, dev - 2
vpn_GatewaySubnet_pop
	VPN gateway Point of Presence to create the respective IP address
vpnClientAddressPoolPrefix	IP address pool for the VPN connection to use
vpnRootCertName	Root certificate name existing in the keyvault
ExternalSubnet_pop
	Jumpbox Point of Presence to create the respective IP address
dc_virtualMachineSize	Size of Virtual machine
domainName	Name of the domain
secrets	Keyvault secret names of the respective secrets
_artifactsLocationSasToken	SAS token for accessing the blobs (code repo)
_artifactsURI
	Base URI of the storage account. Eg: https://emsdstgemsarm001.blob.core.windows.net/
_artifactsBranch
	Branch name corresponding to the Azure devops repository


Using the template
PowerShell: Install the Azure Az module
New-AzDeployment -Name 'deployment-name' -Location 'deployment-location' -TemplateParameterUri '_artifactsURI + _artifactsBranch + /AD/deploy.parameters.json + _artifactsLocationSasToken' -TemplateUri '_artifactsURI + _artifactsBranch + /AD/deploy.json + _artifactsLocationSasToken' -Verbose 


