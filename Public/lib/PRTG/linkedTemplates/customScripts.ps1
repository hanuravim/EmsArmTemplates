Param (
    [Parameter()]
    [String]$PRTG_SetupLocation = "https://dremsblobstore.blob.core.windows.net/scripts/PRTG_Remote_Probe_Installer_for_adiMonitoring.us.ae.ge.com_with_key_{A30FFAC8}.exe"
)
# Download path for PRTG setup
$File = $($env:TEMP) + '\PRTG.EXE'
# Start Download
#Invoke-WebRequest -Uri $PRTG_SetupLocation -OutFile $File

# Install
$command = “cmd.exe /c $file /silent /v /qn"
$process = [WMICLASS]“\\$env:COMPUTERNAME\ROOT\CIMV2:win32_process“
$process.Create($command)
