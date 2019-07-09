if ($IsWindows -or ($PSVersionTable.PSVersion -match '^5.1')) {
    function Test-Administrator {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
        $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
        $IsAdmin = $principal.IsInRole($admin)
        return $IsAdmin
    }
}

function prompt {
    if ($IsWindows -or ($PSVersionTable.PSVersion -match '^5.1')) {
        # If running as administrator, set the following options
        if (Test-Administrator) {
            Write-Host "(ADMINISTRATOR) " -NoNewline -ForegroundColor Red
        }
    }

    Write-Host "$Env:USERNAME" -NoNewline -ForegroundColor Green
    Write-Host "@" -NoNewline -ForegroundColor DarkGray
    Write-Host "$Env:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$(Get-Location)".Replace($Env:USERPROFILE, "~") -ForegroundColor Yellow
    return ">" # The prompt function must return a string, or it will write the default prompt
    
    <# $ESC = "$([char]27)"

    if (Test-Administrator) {
        $promptAdminWarning = "(ADMINISTRATOR) "
    }
    else {
        $promptAdminWarning = ""
    }

    $locationString = "$(Get-Location)".Replace($Env:USERPROFILE, "~")
    
    $promptString = "$ESC[38;5;9m{0}$ESC[0m$ESC[38;5;10m{1}$ESC[0m$ESC[38;5;250m@$ESC[0m$ESC[38;5;200m{2}$ESC[0m $ESC[38;5;250m:$ESC[0m $ESC[38;5;11m{3}$ESC[0m`n`> " `
        -f $promptAdminWarning,$Env:USERNAME,$Env:COMPUTERNAME,$locationString

    Write-Output $promptString #>
}

$psenvPath = "$Env:SystemDrive\psenv"

# Variable to make editing options simpler
$Shell = $Host.UI.RawUI

# Source all of the scripts
foreach ($script in (Get-ChildItem "$psenvPath\import" | Select-Object -ExpandProperty BaseName)) {
    . (Join-Path -Path "$psenvPath\import" -ChildPath $script)
}

<# if (Test-Administrator) {
    $Shell.WindowTitle = "Windows PowerShell (ADMINISTRATOR)"
}
else {
    $Shell.WindowTitle = "Windows PowerShell"
} #>

<# $BufferSize = $Shell.BufferSize
$BufferSize.Width = 150
$BufferSize.Height = 3000
$Shell.BufferSize = $BufferSize

$WindowSize = $Shell.WindowSize
$WindowSize.Width = 150
$WindowSize.Height = 50
$Shell.WindowSize = $WindowSize #>

# Additonal PATH extension
<# $env:Path += ";C:\Program Files\OpenSSH"
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\Debuggers\x64" #>

# Choco tab completion - https://chocolatey.org/docs/troubleshooting#why-does-choco-intab-not-work-for-me
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# PSReadLine Options/Bindings
Set-PSReadLineKeyHandler -Chord 'Ctrl+p' -Function 'CaptureScreen'

# Modules to import
$moduleList = @('posh-git')
foreach ($module in $moduleList) {
    try {
        Import-Module -Name $module -ErrorAction 'Stop'
    }
    catch {
        Write-Verbose -Message "Could not import module [$module]" -Verbose
    }
}