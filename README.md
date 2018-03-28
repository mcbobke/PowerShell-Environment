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

To install Windows OpenSSH at the same time:

```
powershell.exe -ExecutionPolicy Bypass -File .\Invoke-EnvironmentSetup.ps1 -InstallSSH
```

### Uninstallation

```
powershell.exe -ExecutionPolicy Bypass -File .\Invoke-EnvironmentTeardown.ps1
```

### Features

* Installs module MattBobkeCmdlets and profile script for all users/all hosts on the client machine
* Custom Powershell shell window with a color-coded prompt, larger increased default size, and environment path extended to include OpenSSH
* Optionally installs Windows OpenSSH [using Microsoft's method](https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH)
* Uninstall scripts for both full environment and OpenSSH included