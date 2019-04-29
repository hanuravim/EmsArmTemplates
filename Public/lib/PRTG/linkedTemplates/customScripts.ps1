Param (
    [Parameter()]
    [String]$PRTG_SetupLocation
)
# Target path for PRTG setup
$File = $($env:TEMP) + '\PRTG.EXE'
# Download
Invoke-WebRequest -Uri $PRTG_SetupLocation -OutFile $File
# Install
Start-Process -Wait -FilePath $File -ArgumentList "/silent"
