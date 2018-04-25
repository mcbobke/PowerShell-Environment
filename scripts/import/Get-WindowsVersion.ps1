function Get-WindowsVersion {
    <#
        .SYNOPSIS
        Returns the major, minor, build, and revision numbers of the Windows OS on the target PC.

        .DESCRIPTION
        Uses registry key HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion to query the full Windows version information.

        .PARAMETER ComputerName
        The name of the remote computer to query.

        .PARAMETER Credential
        The credentials to use when querying a PC (required for Invoke-Command). Formatted as DOMAIN\USERNAME. Use an admin account.

        .EXAMPLE
        Get-WindowsVersion -ComputerName computername -Credential domain\username
        For a remote computer.

        .EXAMPLE
        Get-WindowsVersion
        For the local computer.

        .NOTES
        If running on the local computer, ensure PowerShell is running with admin rights.

        .LINK
        https://superuser.com/a/1160428
    #>

    param(
        [Parameter()][string]$ComputerName,
        [Parameter()][System.Management.Automation.PSCredential]$Credential
    )

    $Script:Path = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion"

    function Get-Value {
        param(
            [String]$ComputerName,
            [System.Management.Automation.PSCredential]$Credential,
            [String]$Property
        )

        $Params = @{
            ComputerName = $ComputerName;
            Credential   = $Credential;
            ScriptBlock  = {Get-ItemProperty -Path $args[0] -Name $args[1]};
            ArgumentList = $Script:Path, $Property;
        }

        $(Invoke-Command @Params).$Property
    }

    $Script:local = $false

    if (!$PSBoundParameters.ContainsKey('ComputerName')) {
        $Script:local = $true
    }

    if (!$Script:local -and !(Test-Connection -ComputerName $ComputerName -Quiet)) {
        throw "That computer is offline or does not exist."
    }

    $WinVer = New-Object -TypeName PSObject

    if (!$Script:local) {
        $WinVer | Add-Member -MemberType "NoteProperty" -Name "Major" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "CurrentMajorVersionNumber")

        $WinVer | Add-Member -MemberType "NoteProperty" -Name "Minor" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "CurrentMinorVersionNumber")

        $WinVer | Add-Member -MemberType "NoteProperty" -Name "Build" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "CurrentBuild")

        $WinVer | Add-Member -MemberType "NoteProperty" -Name "Revision" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "UBR")
    }
    else {
        $Winver | Add-Member -MemberType "NoteProperty" -Name "Major" -Value $(Get-ItemProperty -Path $Script:Path -Name "CurrentMajorVersionNumber").CurrentMajorVersionNumber

        $WinVer | Add-Member -MemberType "NoteProperty" -Name "Minor" -Value $(Get-ItemProperty -Path $Script:Path -Name "CurrentMinorVersionNumber").CurrentMinorVersionNumber

        $WinVer | Add-Member -MemberType "NoteProperty" -Name "Build" -Value $(Get-ItemProperty -Path $Script:Path -Name "CurrentBuild").CurrentBuild

        $WinVer | Add-Member -MemberType "NoteProperty" -Name "UBR" -Value $(Get-ItemProperty -Path $Script:Path -Name "UBR").UBR
    }

    $WinVer
}