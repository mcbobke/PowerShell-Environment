function Test-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin = $principal.IsInRole($admin)
    return $IsAdmin
}

function prompt {
    # If running as administrator, set the following options
    if (Test-Administrator) {
        Write-Host "(ADMINISTRATOR) " -NoNewline -ForegroundColor Red
    }

    Write-Host "$Env:USERNAME" -NoNewline -ForegroundColor Green
    Write-Host "@" -NoNewline -ForegroundColor DarkGray
    Write-Host "$Env:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$(Get-Location)".Replace($Env:USERPROFILE, "~") -ForegroundColor Yellow
    return ">" # The prompt function must return a string, or it will write the default prompt
}

# Variable to make editing options simpler
$Shell = $Host.UI.RawUI

Import-Module MattBobkeCmdlets

if (Test-Administrator) {
    $Shell.WindowTitle = "Godmode Activated!"
}
else {
    $Shell.WindowTitle = "You are POWERLESS!"
}

$BufferSize = $Shell.BufferSize
$BufferSize.Width = 150
$BufferSize.Height = 3000
$Shell.BufferSize = $BufferSize

$WindowSize = $Shell.WindowSize
$WindowSize.Width = 150
$WindowSize.Height = 50
$Shell.WindowSize = $WindowSize

# Additonal PATH extension
$env:Path += ";C:\Program Files\OpenSSH"
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\Debuggers\x64"