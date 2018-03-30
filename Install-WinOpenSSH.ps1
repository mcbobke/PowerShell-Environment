[CmdletBinding()]
Param()

#### TODO ####
# Replace .NET web request with Powershell Invoke-Webrequest

# Get latest version from Github releases
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # Needed to avoid SSL/TLS error
$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
$request = [System.Net.WebRequest]::Create($url)
$request.AllowAutoRedirect = $false
$response = $request.GetResponse()
$downloadURL = $([String]$response.GetResponseHeader("Location")).Replace('tag', 'download') + '/OpenSSH-Win64.zip'

# Build desired file names
$version = $downloadURL.Split('/')[7]
$zippedFileName = "OpenSSH-Win64-$version.zip"
$unzippedFileName = $zippedFileName.Replace(".zip", '')

# Download the zip file, store in C:\Temp\OpenSSHDownload
Write-Host "Downloading version $version..."
$client = New-Object System.Net.WebClient
$client.DownloadFile($downloadURL, "C:\Temp\$zippedFileName")

# Unzip and copy to Program Files
Write-Host "Unzipping archive and copying to Program Files..."
Expand-Archive -Path "C:\Temp\$zippedFileName" -DestinationPath "C:\Temp\$unzippedFileName"
Copy-Item -Path "C:\Temp\$unzippedFileName\OpenSSH-Win64" -Destination "$Env:ProgramFiles\OpenSSH" -Recurse

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
Remove-Item -Path "C:\Temp\$zippedFileName"
Remove-Item -Path "C:\Temp\$unzippedFileName" -Recurse

Write-Host "Done!"