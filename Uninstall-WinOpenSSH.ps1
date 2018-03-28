[CmdletBinding()]
Param()

# Run provided uninstall script to stop and remove services
Write-Host "Running uninstall script..."
& "$Env:ProgramFiles\OpenSSH\uninstall-sshd.ps1"

# Delete Program Files folder
Write-Host "Deleting $Env:ProgramFiles\OpenSSH directory..."
Remove-Item -Path "$Env:ProgramFiles\OpenSSH" -Recurse

# Delete firewall rule
Write-Host "Deleting inbound port 22 firewall rule..."
netsh advfirewall firewall delete rule name=sshd dir=in

# Delete registry key
Write-Host "Deleting DefaultShell Registry key..."
Remove-Item -Path "HKLM:\SOFTWARE\OpenSSH" -Recurse

Write-Host "Done!"