Param(
    [Switch]$InstallSSH,
    [Switch]$InstallWinDbg
)

$Global:psenvPath = "$Env:SystemDrive\psenv"
$Global:win10sdkPath = "$Global:psenvPath\win10sdk"
$Global:opensshPath = "$Global:psenvPath\openssh"
$Global:setupScriptsPath = "$Global:psenvPath\scripts\setuphelpers"

# Check for existence of current profile
if (Test-Path -Path "$Global:psenvPath" -PathType "Container") {
    Write-Warning -Message "Previous environment found; uninstalling first before continuing with setup."
    & "$psenvPath\Invoke-EnvironmentTeardown.ps1"
}

New-Item -Path "$Env:SystemDrive\" -Name "psenv" -ItemType "Directory" -Force | Out-Null

# Copy files
Write-Host "Copy the entire contents of the directory to $Global:psenvPath..."
$EntireDirectoryParams = @{
    Path        = "$PSScriptRoot\*";
    Destination = "$Global:psenvPath";
    Force       = $True;
    Recurse     = $True;
    Exclude     = @("*git*", "*images*", "*README*");
}
Copy-Item @EntireDirectoryParams | Out-Null

Write-Host "Copying profile..."
$ProfileParams = @{
    Path        = "$Global:psenvPath\scripts\profile.ps1";
    Destination = $PROFILE.AllUsersAllHosts;
    Force       = $True;
}
Copy-Item @ProfileParams | Out-Null

# If switch, install OpenSSH
if ($InstallSSH -and !(Test-Path -Path "C:\Windows\System32\OpenSSH")) {
    Write-Host "Installing WinOpenSSH..."
    & "$Global:setupScriptsPath\Install-WinOpenSSH.ps1"
}

# If switch, install WinDbg
# Not testing path as other versions of WinDbg may be installed
if ($InstallWinDbg) {
    Write-Host "Installing WinDbg..."
    & "$Global:setupScriptsPath\Install-WinDbg.ps1"
    Write-Host "    Waiting 30 seconds for WinDbg to install..."
    Start-Sleep -Seconds 30 # Needed to let install WinDbg process complete
    Write-Host "    Done!"
}

# Execute profile - will show errors if certain profiles don't exist
Write-Host 'Executing $profile.AllUsersAllHosts...'
Write-Host "Close and reopen Powershell to enable colored prompt."
Write-Warning -Message "Please run the Invoke-EnvironmentTeardown script in $Global:psenvPath to uninstall."
Write-Host "$($PROFILE.AllUsersAllHosts)"
& $PROFILE.AllUsersAllHosts

Write-Host "Done!"