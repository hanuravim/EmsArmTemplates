Param (
    [Parameter()]
    [String]$ResourceGroupName,
    [String]$VMName

)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Az -Confirm:$False
Import-Module Az
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
Remove-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name 'customScripts' -Force
