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

        .EXAMPLE
        Get-WindowsVersion computername domain\username

        .LINK
        https://superuser.com/a/1160428
    #>

    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$ComputerName,
        [Parameter(Mandatory = $true, Position = 1)][System.Management.Automation.PSCredential]$Credential
    )

    function Get-Value {
        param(
            [String]$ComputerName,
            [System.Management.Automation.PSCredential]$Credential,
            [String]$Property
        )

        $Path = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion"

        $Params = @{
            ComputerName = $ComputerName;
            Credential   = $Credential;
            ScriptBlock  = {Get-ItemProperty -Path $args[0] -Name $args[1]};
            ArgumentList = $Path, $Property;
        }

        $(Invoke-Command @Params).$Property
    }

    if (!(Test-Connection -ComputerName $ComputerName -Quiet)) {
        throw "That computer is offline or does not exist."
    }

    $WinVer = New-Object -TypeName PSObject

    $WinVer | Add-Member -MemberType "NoteProperty" -Name "Major" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "CurrentMajorVersionNumber")

    $WinVer | Add-Member -MemberType "NoteProperty" -Name "Minor" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "CurrentMinorVersionNumber")

    $WinVer | Add-Member -MemberType "NoteProperty" -Name "Build" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "CurrentBuild")

    $WinVer | Add-Member -MemberType "NoteProperty" -Name "Revision" -Value $(Get-Value -ComputerName $ComputerName -Credential $Credential -Property "UBR")

    $WinVer
}