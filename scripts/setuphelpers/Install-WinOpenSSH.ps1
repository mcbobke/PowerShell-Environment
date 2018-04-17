[CmdletBinding()]
Param()

# Check to see if the $Env:SystemDrive\psenv directory exists - create it if it doesn't
if (!(Test-Path -Path "$Env:SystemDrive\psenv" -PathType "Container")) {
    New-Item -Path "$Env:SystemDrive\" -Name "psenv" -ItemType "Directory" -Force | Out-Null
}

# Check to see if the $Global:psenvPath\openssh directory exists - create it if it doesn't
if (!(Test-Path -Path "$Global:opensshPath" -PathType "Container")) {
    New-Item -Path "$Global:psenvPath" -Name "openssh" -ItemType "Directory" -Force | Out-Null
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
$unzippedFileName = $zippedFileName.Replace('.zip', '')

# Download the zip file, store in C:\psenv\
Write-Host "    Downloading version $version..."
try {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($downloadURL, "$Global:opensshPath\$zippedFileName")
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}

# Unzip and copy to Program Files
Write-Host "    Unzipping archive and copying to Program Files..."
Expand-Archive -Path "$Global:opensshPath\$zippedFileName" -DestinationPath "$Global:opensshPath\$unzippedFileName"
Copy-Item -Path "$Global:opensshPath\$unzippedFileName\OpenSSH-Win64" -Destination "$Env:ProgramFiles\OpenSSH" -Recurse

# Configuration
Write-Host "    Configuring services, inbound on port 22, and registry..."
& "$Env:ProgramFiles\OpenSSH\install-sshd.ps1"
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22 | Out-Null
net start sshd | Out-Null
Set-Service sshd -StartupType Automatic | Out-Null
Set-Service ssh-agent -StartupType Automatic | Out-Null

$Params1 = @{
    Path         = "HKLM:\SOFTWARE\OpenSSH";
    Name         = "DefaultShell";
    Value        = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";
    PropertyType = "String";
    Force        = $True;
}
$Params2 = @{
    Path         = "HKLM:\SOFTWARE\OpenSSH";
    Name         = "BobkePSProfileScript";
    Value        = 1;
    PropertyType = "Dword";
    Force        = $True;
}
New-ItemProperty @Params1 | Out-Null
New-ItemProperty @Params2 | Out-Null

# Cleanup
Write-Host "    Cleaning up..."
$client.Dispose()
Remove-Item -Path "$Global:opensshPath\$zippedFileName" -Force
Remove-Item -Path "$Global:opensshPath\$unzippedFileName" -Recurse -Force

Write-Host "    Done!"