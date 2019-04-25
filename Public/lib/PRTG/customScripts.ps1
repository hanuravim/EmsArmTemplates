Param (
  [Parameter()]
  [String]$PRTG_SetupLocation,
  [String]$PRTG_DownloadLocation
  
)

# Download path for PRTG setup
$File = $($env:TEMP) + '\PRTG.EXE'
# Start Download
Invoke-WebRequest -Uri $Uri -OutFile $File
# Install
Start-Process -Wait -FilePath $File -ArgumentList "/S /v /qn" -passthru
