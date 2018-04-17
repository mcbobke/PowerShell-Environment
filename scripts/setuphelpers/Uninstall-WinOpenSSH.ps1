[CmdletBinding()]
Param()

$opensshProgramPath = "$Env:ProgramFiles\OpenSSH"

Try {
    $Params = @{
        Path        = "HKLM:\SOFTWARE\OpenSSH\";
        Name        = "BobkePSProfileScript";
        ErrorAction = "Stop";
    }
    
    $installedViaScript = Get-ItemPropertyValue @Params
}
Catch {
    $installedViaScript = 0
}
if ((Test-Path -Path "HKLM:\SOFTWARE\OpenSSH") -and ($installedViaScript -eq 1)) {
    Write-Host "    Uninstalling WinOpenSSH..."
}
else {
    Write-Host "    OpenSSH was not installed via script."
    exit
}

# Run provided uninstall script to stop and remove services
Write-Host "    Running uninstall script..."
& "$opensshProgramPath\uninstall-sshd.ps1"

# Delete Program Files folder
Write-Host "    Deleting $opensshProgramPath directory..."
Remove-Item -Path "$opensshProgramPath" -Recurse

# Delete firewall rule
Write-Host "    Deleting inbound port 22 firewall rule..."
netsh advfirewall firewall delete rule name=sshd dir=in | Out-Null

# Delete registry key
Write-Host "    Deleting Registry key..."
Remove-Item -Path "HKLM:\SOFTWARE\OpenSSH" -Recurse

Write-Host "    Done!"