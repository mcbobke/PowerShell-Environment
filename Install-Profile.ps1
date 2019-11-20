Write-Verbose -Message "Copying profile to [$($Profile.AllUsersCurrentHost)]" -Verbose
$ProfileParams = @{
    Path        = '.\profile.ps1';
    Destination = $Profile.AllUsersCurrentHost;
    Force       = $true;
}
$null = Copy-Item @ProfileParams

$null = New-Item -Path "$Env:SystemDrive\psenv" -Name 'import' -ItemType 'Directory' -ErrorAction 'SilentlyContinue'

Write-Verbose -Message "Copying helper scripts to [$Env:SystemDrive\psenv]" -Verbose
$ScriptsParams = @{
    Path = ".\import\*"
    Destination = "$Env:SystemDrive\psenv\import"
    Recurse = $true
    Force = $true
}
$null = Copy-Item @ScriptsParams