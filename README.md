# Powershell Environment Setup

### Run as Non-Administrator

![Non-Admin](images/ps_standard.png)

### Run as Administrator

![Admin](images/ps_admin.png)

### Installation

```
git clone https://github.com/mcbobke/Powershell-Scripting.git
cd ".\Powershell-Scripting\EnvironmentSetup"
powershell.exe -ExecutionPolicy Bypass -File .\Invoke-EnvironmentSetup.ps1
```

To install Windows OpenSSH and WinDbg at the same time:

```
powershell.exe -ExecutionPolicy Bypass -File .\Invoke-EnvironmentSetup.ps1 -InstallSSH -InstallWinDbg
```

### Uninstallation

```
powershell.exe -ExecutionPolicy Bypass -File .\Invoke-EnvironmentTeardown.ps1
```

### Features

* Installs profile script and custom functions for all users/all hosts on the client machine
* Custom Powershell shell window with a color-coded prompt and environment path extended to include OpenSSH/WinDbg
* Optionally installs Windows OpenSSH [using Microsoft's method](https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH)
* Optionally installs WinDbg (https://developer.microsoft.com/en-US/windows/downloads/windows-10-sdk)
* Uninstall script for full environment included - automatically run by Invoke-EnvironmentSetup if another version of the environment is installed