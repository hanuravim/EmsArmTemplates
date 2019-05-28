param (
        [Parameter(Mandatory=$false)]
        [string]
        $InputFile,

        [Parameter(Mandatory=$false)]
        [string]
        $Computer= $env:COMPUTERNAME,

        [Parameter(Mandatory=$false)]
        [string]
        $Trustee= 'ADI Supporters',

        [Parameter(Mandatory=$false)]
        [string]
        $group= 'DREFOQA\ADI Supporters'
)
#DISK INITIALIZE
$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
$count = 0
    $letter = "F","L","S"
    foreach ($disk in $disks) {
        $drive = $letter[$count].ToString()
        $disk | 
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $drive |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $letter[$count] -Confirm:$false -Force
    $count++
    }
	
$DvdDrive = Get-CimInstance -Class Win32_Volume -Filter "driveletter='E:'"
Set-CimInstance -InputObject $DvdDrive -Arguments @{DriveLetter="Z:"}

$EDrive = Get-CimInstance -Class Win32_Volume -Filter "driveletter='F:'"
Set-CimInstance -InputObject $EDrive -Arguments @{DriveLetter="E:"}

$FDrive = Get-CimInstance -Class Win32_Volume -Filter "Label='F'"
Set-CimInstance -InputObject $FDrive -Arguments @{Label='sqlData:'}

$LDrive = Get-CimInstance -Class Win32_Volume -Filter "driveletter='L:'"
Set-CimInstance -InputObject $LDrive -Arguments @{Label='sqlLog:'}

$SDrive = Get-CimInstance -Class Win32_Volume -Filter "driveletter='S:'"
Set-CimInstance -InputObject $SDrive -Arguments @{Label='sqlSystem:'}
