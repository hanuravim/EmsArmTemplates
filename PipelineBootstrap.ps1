<#
.SYNOPSIS
Runs an Invoke-Build task from an Azure DevOps pipeline after installing dependencies using PSDepend.
#>
[CmdletBinding()]
param(
    [Parameter( Mandatory = $true )]
    [System.String[]] $Task,

    [Parameter( Mandatory = $true )]
    [System.String[]] $Tags
)

$Tags += 'bootstrap'
Write-Verbose -Message ('Beginning ''{0}'' process...' -f ($Task -join ','))

# Bootstrap the environment
$null = Get-PackageProvider -Name NuGet -ForceBootstrap

# Install PSake module if it is not already installed
if (-not (Get-Module -Name PSDepend -ListAvailable)) {
    Install-Module -Name PSDepend -Scope CurrentUser -Force -Confirm:$false
}

# Install dependencies required for the Test task.
Import-Module -Name PSDepend
Invoke-PSDepend `
    -Path $PSScriptRoot `
    -Force `
    -Install `
    -Import `
    -Tags $Tags

Invoke-Build -Task $Task -File "$PSScriptRoot\EmsArmTemplates.build.ps1" -ErrorAction Stop | Out-Host