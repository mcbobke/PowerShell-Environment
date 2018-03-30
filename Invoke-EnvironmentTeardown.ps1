# Delete module folder
Write-Host "Deleting module folder..."
Remove-Item -Path "$Env:ProgramFiles\WindowsPowershell\Modules\MattBobkeCmdlets" -Recurse

# Delete Profile
Write-Host "Deleting profile..."
Remove-Item -Path $profile.AllUsersAllHosts

# Uninstall WinOpenSSH if installed
Try {
    $Params = @{
        Path = "HKLM:\SOFTWARE\OpenSSH\";
        Name = "BobkePSProfileScript";
        ErrorAction = "Stop";
    }
    
    $installedViaScript = Get-ItemPropertyValue @Params
}
Catch {
    $installedViaScript = 0
}
if ((Test-Path -Path "HKLM:\SOFTWARE\OpenSSH") -and ($installedViaScript -eq 1)) {
    Write-Host "Uninstalling WinOpenSSH..."
    & "$PSScriptRoot\Uninstall-WinOpenSSH.ps1"
}

Write-Host "Done!"