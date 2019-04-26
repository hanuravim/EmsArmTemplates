Param (
    [Parameter()]
    [String]$PRTG_SetupLocation
)
# Download path for PRTG setup
$File = 'D:\' + '\PRTG.EXE'
# Start Download
Invoke-WebRequest -Uri $PRTG_SetupLocation -OutFile $File
# Install
Start-Process -Wait -FilePath $File -ArgumentList "/S /v /qn" -passthru
