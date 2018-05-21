[CmdletBinding()]
Param()

Write-Host "    Installing latest Nuget PackageProvider..."
Install-PackageProvider Nuget | Out-Null

Write-Host "    Setting PSRepository 'PSGallery' to Trusted..."
Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' | Out-Null

Write-Host "    Updating PowerShellGet module..."
Install-Module -Name 'PowerShellGet' -Repository 'PSGallery' | Out-Null
Get-Module -Name 'PowerShellGet' | Remove-Module -Force | Out-Null
Import-Module -Name 'PowerShellGet' -Force | Out-Null
Import-PackageProvider -Name 'PowerShellGet' -Force | Out-Null

Write-Host "    Installing modules..."
foreach ($module in $Global:modulesToInstall) {
    Write-Host "        $module" -ForegroundColor Green
    Install-Module -Name $module -Scope 'AllUsers'
}