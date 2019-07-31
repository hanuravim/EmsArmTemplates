Install-WindowsFeature @(
    'RDS-Connection-Broker'
    'RDS-Licensing'
    'RDS-RD-Server'
    'RDS-Web-Access' 
) -IncludeAllSubFeature -IncludeManagementTools -Restart

# Must be domain joined computer, logged in with domain account
Import-Module RemoteDesktop
$FQDN = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
New-RDSessionDeployment -ConnectionBroker $FQDN -WebAccessServer $FQDN -SessionHost $FQDN # install the three compulsory RDS components

# associate the new license server with your existing Connection Broker
Set-RDLicenseConfiguration -LicenseServer $FQDN -Mode PerUser -ConnectionBroker $FQDN -Force 
