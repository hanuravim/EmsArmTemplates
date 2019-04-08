Param (
[Parameter()]
[String]$appsecret,
[String]$applicationId,
[String]$tenantId,
[String]$automationAccountResourceGroup,
[String]$automationAccount
)

$appsecret,
$applicationId,
$tenantId,
$automationAccountResourceGroup,
$automationAccount

#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name AzureRM -RequiredVersion 6.9.0 -Confirm:$False
Import-Module AzureRM

$secpasswd = ConvertTo-SecureString $appsecret -AsPlainText -Force
($creds = New-Object System.Management.Automation.PSCredential ($applicationId, $secpasswd))
Connect-AzureRmAccount -ServicePrincipal -Credential $creds -TenantId $tenantId



$Runbook = Get-AzureRmAutomationRunbook -ResourceGroupName $automationAccountResourceGroup -AutomationAccountName $automationAccount
Start-AzureRmAutomationRunbook -Name $Runbook.Name -ResourceGroupName $automationAccountResourceGroup  -AutomationAccountName $automationAccount
Start-Sleep 60
Restart-Computer -Force
