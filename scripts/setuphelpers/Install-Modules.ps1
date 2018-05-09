[CmdletBinding()]
Param()

Write-Host "    Installing latest Nuget PackageProvider..."
Install-PackageProvider Nuget -Force | Out-Null

Write-Host "    Setting PSRepository 'PSGallery' to Trusted..."
Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' | Out-Null

Write-Host "    Updating PowerShellGet module..."
Install-Module -Name 'PowerShellGet' -Repository 'PSGallery' -MinimumVersion 1.6.0 -Force | Out-Null # 1.6.0 is the latest to date
Get-Module -Name 'PowerShellGet' | Remove-Module -Force | Out-Null
Import-Module -Name 'PowerShellGet' -MinimumVersion 1.6.0 | Out-Null
Import-PackageProvider -Name 'PowerShellGet' -Force -RequiredVersion 1.6.0 | Out-Null

Write-Host "    Installing modules..."
foreach ($module in $Global:modulesToInstall) {
    Write-Host "        $module" -ForegroundColor Green
    Install-Module -Name $module -Scope 'AllUsers' -Force
}