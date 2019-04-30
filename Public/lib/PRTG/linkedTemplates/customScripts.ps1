Param (
    [Parameter()]
    [String]$ResourceGroupName,
    [String]$VMName

)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Azure -Confirm:$False
Import-Module Azure
Restart-Computer -Force
Remove-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name 'customScripts' -Force
