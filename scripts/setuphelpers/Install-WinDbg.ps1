[CmdletBinding()]
Param()

# Check to see if the $Env:SystemDrive\psenv directory exists - create it if it doesn't
if (!(Test-Path -Path "$Global:psenvPath" -PathType "Container")) {
    New-Item -Path "$Env:SystemDrive\" -Name "psenv" -ItemType "Directory" -Force | Out-Null
}

# Check to see if the $Global:psenvPath\win10sdk directory exists - create it if it doesn't
if (!(Test-Path -Path "$Global:win10sdkPath" -PathType "Container")) {
    New-Item -Path "$Global:psenvPath" -Name "win10sdk" -ItemType "Directory" -Force | Out-Null
}

# Get the download link
$url = 'https://developer.microsoft.com/en-US/windows/downloads/windows-10-sdk'
try {
    $response = Invoke-WebRequest -Uri $url -ErrorAction "Stop"
}
catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
$downloadUrl = $response `
    | Select-Object -ExpandProperty "Links" `
    | Where-Object {$PSItem.innerTExt -eq 'Download the .EXE'} `
    | Select-Object -ExpandProperty "href"
$downloadUrl = 'https:' + $downloadUrl

# Download the installer, store in C:\psenv\
Write-Host "    Downloading the installer..."
try {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($downloadURL, "$Global:win10sdkPath\win10sdk.exe")
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}

# Install WinDbg
Write-Host "    Running WinDbg setup executable..."
& "$Global:win10sdkPath\win10sdk.exe" /features OptionId.WindowsDesktopDebuggers /norestart /ceip off /quiet /log C:\psenv\win10sdk.log

# Cleanup
$client.Dispose()