Param(
    [Switch]$InstallSSH
)

# Copy files
Write-Host "Copying module and profile..."
$ModuleParams = @{
    Path        = "$PSScriptRoot\MattBobkeCmdlets.psm1";
    Destination = "$Env:ProgramFiles\WindowsPowershell\Modules\MattBobkeCmdlets";
    Force       = $True;
}
if (!(Test-Path $ModuleParams.Destination)) {
    New-Item -Path "$Env:ProgramFiles\WindowsPowershell\Modules" -ItemType "Directory" -Name "MattBobkeCmdlets" `
        | Out-Null
}
Copy-Item @ModuleParams | Out-Null

$ProfileParams = @{
    Path        = "$PSScriptRoot\profile.ps1";
    Destination = $profile.AllUsersAllHosts;
    Force       = $True;
}
Copy-Item @ProfileParams | Out-Null

if ($InstallSSH -and !(Test-Path -Path "C:\Windows\System32\OpenSSH")) {
    Write-Host "Installing WinOpenSSH..."
    & "$PSScriptRoot\Install-WinOpenSSH.ps1"
}

# Execute profile - will show errors if certain profiles don't exist
Write-Host 'Executing $profile.AllUsersAllHosts...'
& $profile.AllUsersAllHosts

Write-Host "Done!"