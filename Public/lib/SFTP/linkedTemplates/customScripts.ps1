#GET THE OPEN SSH PACKAGE
$Uri = 'https://raw.githubusercontent.com/hanuravim/EmsArmTemplates/master/Public/lib/SFTP/BvSshServer-Inst.exe'
Invoke-WebRequest -Uri $Uri -OutFile "$($env:ProgramFiles)\OpenSSH-Win64.zip"

#NAVIGATE TO THE RESPECTIVE PATH
Expand-Archive "$($env:ProgramFiles)\OpenSSH-Win64.zip" -DestinationPath "$($env:ProgramFiles)\OpenSSH-Win64" -Force
cd "$($env:ProgramFiles)\OpenSSH-Win64\OpenSSH-Win64"

mkdir -Path $env:ProgramData -Name 'ssh' -Force

.\install-sshd.ps1
.\ssh-keygen.exe -A
.\FixHostFilePermissions.ps1 -Confirm:$false

#Open an incoming port in Windows Firewall for the SSH server.
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH
sc.exe start sshd
sc.exe config sshd start= auto
