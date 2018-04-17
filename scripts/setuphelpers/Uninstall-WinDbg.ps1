[CmdletBinding()]
Param()

$win10sdkPath = "$Global:psenvPath\win10sdk"

# Uninstall WinDbg if switch and uninstaller present
if (Test-Path -Path "$win10sdkPath\win10sdk.exe") {
    Write-Host "    Uninstalling WinDbg using stored win10sdk.exe..."
    & "$win10sdkPath\win10sdk.exe" /uninstall /features OptionId.WindowsDesktopDebuggers /norestart /quiet /log C:\psenv\win10sdk.log | Out-Null
    Write-Warning -Message "    Please check Control Panel to see if older versions of WinDbg need to be uninstalled."
}
elseif (!(Test-Path -Path "$win10sdkPath\win10sdk.exe")) {
    Write-Warning -Message "    There is no available stored win10sdk.exe."
    Write-Warning -Message "    The Win10SDK is not installed or needs to be uninstalled through Control Panel."
}