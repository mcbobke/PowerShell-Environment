[CmdletBinding()]
Param()

# Check to see if the C:\psenv\ directory exists - create it if it doesn't
if (!(Test-Path -Path "C:\psenv" -PathType "Container")) {
    New-Item -Path "C:\" -Name "psenv" -ItemType "Directory" -Force | Out-Null
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
Write-Host "Downloading the installer..."
try {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($downloadURL, "C:\psenv\win10sdk.exe")
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}

# Install WinDbg
Write-Host "Installing WinDbg..."
& "C:\psenv\win10sdk.exe" /features OptionId.WindowsDesktopDebuggers /norestart /ceip off /quiet /log C:\psenv\win10sdk.log

# Cleanup
$client.Dispose()

Write-Host "Done!"