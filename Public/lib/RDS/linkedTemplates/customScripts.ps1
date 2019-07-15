param (
    [Parameter(Mandatory=$False, HelpMessage="FQDN of RD Web Access\RD Connection Broker and RD Session host roles")]
    [String]
    $serverName='EDSRDRDS01.efoqa.local',

    [Parameter(Mandatory=$False, HelpMessage="Session Collection Name")]
    [String]
    $SessionCollectionName='rdssc',
	
	[Parameter(Mandatory=$False, HelpMessage="Session Discription")]
    [String]
    $CollectionDiscription='rdscd',

    [Parameter(Mandatory=$False, HelpMessage="Domain name ")]
    [String]
    $domain='efoqa.local'
)

# Import the RemoteDesktop module
Import-Module RemoteDesktop

# Create a new RDS deployment
New-RDSessionDeployment -ConnectionBroker $serverName `
   -WebAccessServer $serverName `
   -SessionHost $serverName 
Write-Verbose "Created new RDS deployment on: $serverName"


# Create a new pooled managed desktop collection
New-RDSessionCollection -CollectionName $SessionCollectionName `
   -SessionHost $serverName `
   -CollectionDescription $CollectionDiscription `
   -ConnectionBroker $serverName `
  
   
