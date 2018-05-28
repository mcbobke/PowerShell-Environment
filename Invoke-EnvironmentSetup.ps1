Param(
    [Switch]$InstallSSH,
    [Switch]$InstallWinDbg
)

$Global:psenvPath = "$Env:SystemDrive\psenv"
$Global:win10sdkPath = "$Global:psenvPath\win10sdk"
$Global:opensshPath = "$Global:psenvPath\openssh"
$Global:setupScriptsPath = "$Global:psenvPath\scripts\setuphelpers"
$Global:modulesToInstall = @('ImportExcel', 'Plaster', 'InvokeBuild', 'Pester', 'BuildHelpers', 'PSDeploy')

# Tests to see if the script is being run with local admin privileges
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

# Check for PSVersion 5.1
try {
    if (($PSVersionTable.PSVersion.Major -lt 5) -and ($PSVersionTable.PSVersion.Minor -lt 1)) {
        Write-Warning -Message "Your version of PowerShell ($($PSVersionTable.PSVersion.ToString())) is not compatible with this profile."
        Write-Warning -Message "Your Major/Minor version needs to be at least 5.1."
        exit
    }
}
catch {
    Write-Warning -Message '$PSVersionTable not available, your PowerShell version is too old for this profile.'
    exit
}

# Check for existence of current profile
if (Test-Path -Path "$Global:psenvPath" -PathType "Container") {
    Write-Warning -Message "Previous environment found; uninstalling first before continuing with setup."
    & "$Global:psenvPath\Invoke-EnvironmentTeardown.ps1"
}

New-Item -Path "$Env:SystemDrive\" -Name "psenv" -ItemType "Directory" -Force | Out-Null

# Copy files
Write-Host "Copying the entire contents of the directory to $Global:psenvPath..." -ForegroundColor Cyan
$EntireDirectoryParams = @{
    Path        = "$PSScriptRoot\*";
    Destination = "$Global:psenvPath";
    Force       = $True;
    Recurse     = $True;
    Exclude     = @("*git*", "*images*", "*README*");
}
Copy-Item @EntireDirectoryParams | Out-Null

Write-Host "Copying profile..." -ForegroundColor Cyan
$ProfileParams = @{
    Path        = "$Global:psenvPath\scripts\profile.ps1";
    Destination = $PROFILE.AllUsersAllHosts;
    Force       = $True;
}
Copy-Item @ProfileParams | Out-Null

# If switch, install OpenSSH
if ($InstallSSH -and !(Test-Path -Path "C:\Windows\System32\OpenSSH")) {
    Write-Host "Installing WinOpenSSH..." -ForegroundColor Cyan
    & "$Global:setupScriptsPath\Install-WinOpenSSH.ps1"
    Write-Host "    WinOpenSSH installed!" -ForegroundColor Cyan
}

# If switch, install WinDbg
# Not testing path as other versions of WinDbg may be installed
if ($InstallWinDbg) {
    Write-Host "Installing WinDbg..." -ForegroundColor Cyan
    & "$Global:setupScriptsPath\Install-WinDbg.ps1"
    Write-Host "    Waiting 30 seconds for WinDbg to install..."
    Start-Sleep -Seconds 30 # Needed to let install WinDbg process complete
    Write-Host "    WinDbg installed!" -ForegroundColor Cyan
}

Write-Host "Evaluating PowerShellGet and modules..." -ForegroundColor Cyan
& "$Global:setupScriptsPath\Install-Modules.ps1"

Write-Host "Profile installation complete!" -ForegroundColor Green