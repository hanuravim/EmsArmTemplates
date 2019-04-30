Param (
    [Parameter()]
    [String]$ResourceGroupName,
    [String]$VMName

)
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
Remove-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name 'customScripts' -Force
