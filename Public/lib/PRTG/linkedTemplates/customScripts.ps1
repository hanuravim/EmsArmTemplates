Param (
    [Parameter()]
    [String]$PRTG_SetupLocation
)
# Download path for PRTG setup
$File = $($env:TEMP) + '\PRTG.EXE'
# Start Download
Invoke-WebRequest -Uri $PRTG_SetupLocation -OutFile $File
# Install
$command = “cmd.exe /c $file /silent /v`”/qn”
$process = [WMICLASS]“\\$env:COMPUTERNAME\ROOT\CIMV2:win32_process“
$process.Create($command)
