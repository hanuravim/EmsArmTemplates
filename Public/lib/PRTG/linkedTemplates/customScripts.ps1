Param (
    [Parameter()]
    [String]$ResourceGroupName,
    [String]$VMName

)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Azure -Confirm:$False
Install-Module AzureRm -Confirm:$False
Import-Module Azure
Import-Module AzureRm
Restart-Computer -Force
Remove-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name 'customScripts' -Force
