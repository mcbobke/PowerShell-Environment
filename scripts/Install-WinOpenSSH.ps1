[CmdletBinding()]
Param()

# Check to see if the C:\psenv\ directory exists - create it if it doesn't
if (!(Test-Path -Path "C:\psenv" -PathType "Container")) {
    New-Item -Path "C:\" -Name "psenv" -ItemType "Directory" -Force | Out-Null
}

# Get latest version from Github releases
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # Needed to avoid SSL/TLS error
$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'

# SilentlyContinue because on redirect, this will throw a System.InvalidOperationException
# If the error is thrown as a terminating error, the response is lost
$response = Invoke-WebRequest -Uri $url -MaximumRedirection 0 -ErrorAction "SilentlyContinue"

$responseHeaders = $response | Select-Object -ExpandProperty "Headers"
$location = $responseHeaders.Item("Location")
$downloadURL = $location.Replace('tag', 'download') + '/OpenSSH-Win64.zip'

# Build desired file names
$version = $downloadURL.Split('/')[7]
$zippedFileName = "OpenSSH-Win64-$version.zip"
$unzippedFileName = $zippedFileName.Replace(".zip", '')

# Download the zip file, store in C:\psenv\
Write-Host "Downloading version $version..."
try {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($downloadURL, "C:\psenv\$zippedFileName")
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}

# Unzip and copy to Program Files
Write-Host "Unzipping archive and copying to Program Files..."
Expand-Archive -Path "C:\psenv\$zippedFileName" -DestinationPath "C:\psenv\$unzippedFileName"
Copy-Item -Path "C:\psenv\$unzippedFileName\OpenSSH-Win64" -Destination "$Env:ProgramFiles\OpenSSH" -Recurse

# Configuration
Write-Host "Configuring services, inbound on port 22, and registry..."
& "$Env:ProgramFiles\OpenSSH\install-sshd.ps1"
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22
net start sshd
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic

$Params = @{
    Path         = "HKLM:\SOFTWARE\OpenSSH";
    Name         = "DefaultShell";
    Value        = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";
    PropertyType = "String";
    Force        = $True;
}
New-ItemProperty @Params
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name "BobkePSProfileScript" -Value 1 -PropertyType Dword -Force

# Cleanup
Write-Host "Cleaning up..."
$client.Dispose()
Remove-Item -Path "C:\psenv\$zippedFileName" -Force
Remove-Item -Path "C:\psenv\$unzippedFileName" -Recurse -Force

Write-Host "Done!"