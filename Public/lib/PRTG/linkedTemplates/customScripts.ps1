Param (
    [Parameter()]
    [String]$PRTG_SetupLocation
)
# Download path for PRTG setup
$File = $($env:TEMP) + '\PRTG.EXE'
# Start Download
Invoke-WebRequest -Uri $PRTG_SetupLocation -OutFile $File
# Install
Set-Location -Path $env:TEMP
.\PRTG.EXE /VERYSILENT /SUPPRESSMSGBOXES
