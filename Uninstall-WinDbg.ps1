[CmdletBinding()]
Param()

# Uninstall WinDbg if switch and uninstaller present
if (Test-Path -Path "C:\psenv\win10sdk.exe")
{
    Write-Host "Uninstalling WinDbg using stored win10sdk.exe..."
    & "C:\psenv\win10sdk.exe" /uninstall /features OptionId.WindowsDesktopDebuggers /norestart /quiet /log C:\psenv\win10sdk.log
    Write-Warning -Message "Please check Control Panel to see if older versions of WinDbg need to be uninstalled."
}
elseif (!(Test-Path -Path "C:\psenv\win10sdk.exe"))
{
    Write-Warning -Message "There is no available stored win10sdk.exe."
    Write-Warning -Message "The Win10SDK is not installed or needs to be uninstalled through Control Panel."
}