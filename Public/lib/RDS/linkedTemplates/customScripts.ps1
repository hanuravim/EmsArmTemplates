#REMOTE DESKTOP GATEWAY
Install-WindowsFeature -Name 'RDS-Gateway' -IncludeAllSubFeature
$fqdn = (Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
New-RDSessionDeployment –ConnectionBroker $fqdn –WebAccessServer $fqdn –SessionHost $fqdn
