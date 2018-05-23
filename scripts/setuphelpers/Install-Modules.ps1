[CmdletBinding()]
Param()

Write-Host "    Installing latest Nuget PackageProvider..."
Install-PackageProvider Nuget | Out-Null

Write-Host "    Setting PSRepository 'PSGallery' to Trusted..."
Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' | Out-Null

Write-Host "    Updating PowerShellGet module..."
Update-Module -Name 'PowerShellGet' -Force | Out-Null
Get-Module -Name 'PowerShellGet' | Remove-Module -Force | Out-Null
Import-Module -Name 'PowerShellGet' -Force | Out-Null
Import-PackageProvider -Name 'PowerShellGet' -Force | Out-Null

Write-Host "    Installing/Updating modules..."
$installedModules = Get-Module -ListAvailable | Select-Object -ExpandProperty 'Name'
foreach ($module in $Global:modulesToInstall) {
    Write-Host "        $module" -ForegroundColor Green
    if (!($module -in $installedModules)) {
        try {
            Install-Module -Name $module -Scope 'CurrentUser' -Repository 'PSGallery' -ErrorAction 'Stop'
        }
        catch {
            Write-Warning -Message "Couldn't install module $module - $($_.Exception.Message)"
        }
    }
    else {
        try {
            Update-Module -Name $module -ErrorAction 'Stop'
        }
        catch {
            Write-Warning -Message "Couldn't update module $module - $($_.Exception.Message)"
            Write-Warning -Message "Installing module $module instead, forcing and skipping publisher check..."
            Install-Module -Name $module -Scope 'CurrentUser' -Repository 'PSGallery' -Force -SkipPublisherCheck
        }
    }
}