[CmdletBinding()]
Param()

$scriptsPath = "$PSScriptRoot\scripts"

# Delete module folder
Write-Host "Deleting module folder..."
Remove-Item -Path "$Env:ProgramFiles\WindowsPowershell\Modules\MattBobkeCmdlets" -Recurse

# Delete Profile
Write-Host "Deleting profile..."
Remove-Item -Path $profile.AllUsersAllHosts

# Uninstall WinOpenSSH
& "$scriptsPath\Uninstall-WinOpenSSH.ps1"

# Uninstall WinDbg
& "$scriptsPath\Uninstall-WinDbg.ps1"

# Delete C:\psenv\ folder
Write-Host "Waiting 30 seconds for all processes to finish..."
Start-Sleep -Seconds 30 # Needed to let uninstall WinDbg process complete
Remove-Item -Path "C:\psenv\" -Recurse -Force

Write-Host "Done!"