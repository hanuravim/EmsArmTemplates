Install-WindowsFeature -Name 'RDS-Gateway' -IncludeAllSubFeature
Get-WindowsFeature -Name Web-* | Install-WindowsFeature
Install-WindowsFeature –Name 'GPMC'
Get-WindowsFeature -Name RSAT-* | Install-WindowsFeature
Get-WindowsFeature -Name Hyper-V-* | Install-WindowsFeature
Get-WindowsFeature -Name Telnet-*  | Install-WindowsFeature
Get-WindowsFeature -Name Windows-Defender-*  | Install-WindowsFeature
Install-WindowsFeature -Name UpdateServices, UpdateServices-RSAT, UpdateServices-API, UpdateServices-UI
Restart-Computer -Force
