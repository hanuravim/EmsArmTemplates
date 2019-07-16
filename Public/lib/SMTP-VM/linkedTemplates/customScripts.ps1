Install-WindowsFeature smtp-server
New-NetFirewallRule -Name SMTP -DisplayName SMTP -Description SMTP -Profile Any -Direction Inbound -Enabled True -Action Allow -Protocol TCP -LocalPort 25 
Set-Service SMTPSVC -StartupType Automatic
Start-Service SMTPSVC 

$smtpServer = [ADSI]'IIS://localhost/smtpsvc/1'
$smtpServer.SmartHost = 'smtp.sendgrid.net' # this is a constant for SendGrid
$smtpServer.RouteUserName = 'azure_dc7015c0ce207b642f2168f890831221@azure.com' # This is from the Azure portal at Home > Resource groups > ems-d-eus-srd-rgp-01 > EDSENDGRID06 > Settings > Configurations
$smtpServer.RoutePassword = 'Test@123' # This is the password from the SendGrid SMTP deploy.parameters.json file
$smtpServer.SetInfo()
