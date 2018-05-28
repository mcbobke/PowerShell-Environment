[CmdletBinding()]
Param()

$Global:psenvPath = "$Env:SystemDrive\psenv"
$Global:win10sdkPath = "$Global:psenvPath\win10sdk"
$Global:opensshPath = "$Global:psenvPath\openssh"
$Global:setupScriptsPath = "$Global:psenvPath\scripts\setuphelpers"

function Test-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin = $principal.IsInRole($admin)
    return $IsAdmin
}

if (!(Test-Administrator)) {
    Write-Warning -Message "You are not running as a local admin; please start this as a local admin!"
    exit
}

# Delete Profile
Write-Host "Deleting profile..." -ForegroundColor Cyan
Remove-Item -Path $profile.AllUsersAllHosts

# Uninstall WinOpenSSH
Write-Host "Attempting to uninstall WinOpenSSH..." -ForegroundColor Cyan
& "$Global:setupScriptsPath\Uninstall-WinOpenSSH.ps1"

# Uninstall WinDbg
Write-Host "Attempting to uninstall WinDbg..." -ForegroundColor Cyan
& "$Global:setupScriptsPath\Uninstall-WinDbg.ps1"

# Delete $Env:SystemDrive\psenv
Write-Host "Waiting 30 seconds for all processes to finish..." -ForegroundColor Cyan
Start-Sleep -Seconds 30 # Needed to let uninstall WinDbg process complete
try {
    Remove-Item -Path "$Global:psenvPath" -Recurse -Force -ErrorAction "Stop"
}
catch {
    Write-Warning -Message "Please delete the folder $Global:psenvPath manually."
}
Write-Host "Profile has been uninstalled!" -ForegroundColor Green