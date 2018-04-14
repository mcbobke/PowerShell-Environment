Param(
    [Switch]$InstallSSH,
    [Switch]$InstallWinDbg
)

$scriptsPath = "$PSScriptRoot\scripts"
$modulePath = "$PSScriptRoot\module\*"

# Check to see if the C:\psenv\ directory exists - create it if it doesn't
if (!(Test-Path -Path "C:\psenv" -PathType "Container")) {
    New-Item -Path "C:\" -Name "psenv" -ItemType "Directory" -Force | Out-Null
}

# Copy files
Write-Host "Copying module and profile..."
$ModuleParams = @{
    Path        = "$modulePath";
    Destination = "$Env:ProgramFiles\WindowsPowershell\Modules\MattBobkeCmdlets";
    Force       = $True;
    Recurse     = $True;
}
if (!(Test-Path $ModuleParams.Destination)) {
    New-Item -Path "$Env:ProgramFiles\WindowsPowershell\Modules" -ItemType "Directory" -Name "MattBobkeCmdlets" `
        | Out-Null
}
Copy-Item @ModuleParams | Out-Null

$ProfileParams = @{
    Path        = "$scriptsPath\profile.ps1";
    Destination = $profile.AllUsersAllHosts;
    Force       = $True;
}
Copy-Item @ProfileParams | Out-Null

# If switch, install OpenSSH
if ($InstallSSH -and !(Test-Path -Path "C:\Windows\System32\OpenSSH")) {
    Write-Host "Installing WinOpenSSH..."
    & "$scriptsPath\Install-WinOpenSSH.ps1"
}

# If switch, install WinDbg
# Not testing path as other versions of WinDbg may be installed
if ($InstallWinDbg) {
    Write-Host "Installing WinDbg..."
    & "$scriptsPath\Install-WinDbg.ps1"
    Write-Host "Waiting 30 seconds for WinDbg to install..."
    Start-Sleep -Seconds 30 # Needed to let install WinDbg process complete
}

# Execute profile - will show errors if certain profiles don't exist
Write-Host 'Executing $profile.AllUsersAllHosts...'
Write-Host "Close and reopen Powershell to enable colored prompt."
& $profile.AllUsersAllHosts

Write-Host "Done!"