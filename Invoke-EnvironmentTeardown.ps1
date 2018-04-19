[CmdletBinding()]
Param()

$Global:psenvPath = "$Env:SystemDrive\psenv"
$Global:win10sdkPath = "$Global:psenvPath\win10sdk"
$Global:opensshPath = "$Global:psenvPath\openssh"
$Global:setupScriptsPath = "$Global:psenvPath\scripts\setuphelpers"

# Delete Profile
Write-Host "Deleting profile..."
Remove-Item -Path $profile.AllUsersAllHosts

# Uninstall WinOpenSSH
Write-Host "Attempting to uninstall WinOpenSSH..."
& "$Global:setupScriptsPath\Uninstall-WinOpenSSH.ps1"

# Uninstall WinDbg
Write-Host "Attempting to uninstall WinDbg..."
& "$Global:setupScriptsPath\Uninstall-WinDbg.ps1"

# Delete $Env:SystemDrive\psenv
Write-Host "Waiting 30 seconds for all processes to finish..."
Start-Sleep -Seconds 30 # Needed to let uninstall WinDbg process complete
try {
    Remove-Item -Path "$Global:psenvPath" -Recurse -Force -ErrorAction "Stop"
}
catch {
    Write-Warning -Message "Please delete the folder $Global:psenvPath manually."
}
Write-Host "Done!"