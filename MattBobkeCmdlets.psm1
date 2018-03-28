function Get-LoggedInUsers
{
    <#
        .SYNOPSIS
        Returns the session and user information of the currently logged-on users of the designated PC.

        .DESCRIPTION
        Uses WMI to query the current logon sessions and users by matching their session IDs.

        .PARAMETER ComputerName
        The name of the remote computer to query.

        .PARAMETER Credential
        The credentials to use when querying a PC. Formatted as DOMAIN\USERNAME. Use an admin account.

        .EXAMPLE
        Get-LoggedInUsers -ComputerName MBOBKE-INT

        .EXAMPLE
        Get-LoggedInUsers MBOBKE-INT

        .LINK
        https://stackoverflow.com/questions/23219718/powershell-script-to-see-currently-logged-in-users-domain-and-machine-status

        .COMPONENT
        WMI
    #>

    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$ComputerName,
        [Parameter(Mandatory = $true, Position = 1)][System.Management.Automation.PSCredential]$Credential
    )

    if (!Test-Connection -ComputerName $ComputerName -Quiet) {
        throw "That computer is offline or does not exist."
    }

    $regexa = '.+Domain="(.+)",Name="(.+)"$'
    $regexd = '.+LogonId="(\d+)"$'

    $logontype = @{
        "0"  = "Local System"
        "2"  = "Interactive" # (Local logon)
        "3"  = "Network" # (Remote logon)
        "4"  = "Batch" # (Scheduled task)
        "5"  = "Service" # (Service account logon)
        "7"  = "Unlock" # (Screen saver)
        "8"  = "NetworkCleartext" # (Cleartext network logon)
        "9"  = "NewCredentials" # (RunAs using alternate credentials)
        "10" = "RemoteInteractive" # (RDP\TS\RemoteAssistance)
        "11" = "CachedInteractive" # (Local w\cached credentials)
    }

    $logon_sessions = @(Get-WmiObject -ClassName Win32_LogonSession -ComputerName $computername -Credential $Credential)
    $logon_users = @(Get-WmiObject -ClassName Win32_LoggedOnUser -ComputerName $computername -Credential $Credential)

    $session_user = @{}

    $logon_users | ForEach-Object {
        $_.antecedent -match $regexa > $nul
        $username = $matches[1] + "\" + $matches[2]
        $_.dependent -match $regexd > $nul
        $session = $matches[1]
        $session_user[$session] += $username
    }

    [psobject[]] $logons = @()

    $logon_sessions | ForEach-Object {
        $starttime = [management.managementdatetimeconverter]::todatetime($_.starttime)

        $loggedonuser = New-Object -TypeName PSObject
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "Session" -Value $_.logonid
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "User" -Value $session_user[$_.logonid]
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "Type" -Value $logontype[$_.logontype.tostring()]
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "Auth" -Value $_.authenticationpackage
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "StartTime" -Value $starttime
        $logons += , $loggedonuser
    }

    $logons
}

function Get-WindowsVersion
{
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
        Get-WindowsVersion -Credential blizzard\octopus -ComputerName MBOBKE-INT

        .EXAMPLE
        Get-WindowsVersion blizzard\octopus MBOBKE-INT

        .LINK
        https://superuser.com/a/1160428
    #>

    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$ComputerName,
        [Parameter(Mandatory = $true, Position = 1)][System.Management.Automation.PSCredential]$Credential
    )

    if (!Test-Connection -ComputerName $ComputerName -Quiet) {
        throw "That computer is offline or does not exist."
    }

    $WinVer = New-Object -TypeName PSObject

    $WinVer | Add-Member -MemberType NoteProperty -Name Major `
        -Value $(Invoke-Command -comp $ComputerName -cred $Credential -script {Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentMajorVersionNumber}).CurrentMajorVersionNumber

    $WinVer | Add-Member -MemberType NoteProperty -Name Minor `
        -Value $(Invoke-Command -comp $ComputerName -cred $Credential  -script {Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentMinorVersionNumber}).CurrentMinorVersionNumber

    $WinVer | Add-Member -MemberType NoteProperty -Name Build `
        -Value $(Invoke-Command -comp $ComputerName -cred $Credential  -script {Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentBuild}).CurrentBuild

    $WinVer | Add-Member -MemberType NoteProperty -Name Revision `
        -Value $(Invoke-Command -comp $ComputerName -cred $Credential  -script {Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' UBR}).UBR

    $WinVer
}

Export-ModuleMember -Function Get-LoggedInUsers
Export-ModuleMember -Function Get-WindowsVersion