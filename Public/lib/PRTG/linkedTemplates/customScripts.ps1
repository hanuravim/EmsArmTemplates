Param (
    [Parameter()]
    [String]$PRTG_SetupLocation
)

# Download path for PRTG setup
$File = 'D:\' + '\PRTG.EXE'
# Start Download
Invoke-WebRequest -Uri $PRTG_SetupLocation -OutFile $File
# Install
$myshell = New-Object -com "Wscript.Shell"
$myshell.sendkeys("{ENTER}")

#Start-Process -Wait -FilePath $File -ArgumentList "/S /v /qn" -passthru
