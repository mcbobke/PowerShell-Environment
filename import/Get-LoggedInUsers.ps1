function Get-LoggedInUsers {
    <#
        .SYNOPSIS
        Returns the session and user information of the currently logged-on users of the designated PC, or the local PC.

        .DESCRIPTION
        Uses WMI to query the current logon sessions and users by matching their session IDs.

        .PARAMETER ComputerName
        The name of a remote computer to query.

        .PARAMETER Credential
        The credentials to use when querying. Formatted as DOMAIN\USERNAME. Use a desktop admin account.

        .EXAMPLE
        Get-LoggedInUsers -Credential domain\username -ComputerName computername
        For a remote computer.

        .EXAMPLE
        Get-LoggedInUsers
        For the local computer.

        .NOTES
        If running on the local computer, ensure PowerShell is running with admin rights.

        .LINK
        https://stackoverflow.com/questions/23219718/powershell-script-to-see-currently-logged-in-users-domain-and-machine-status

        .COMPONENT
        WMI
    #>

    param(
        [Parameter()][System.Management.Automation.PSCredential]$Credential,
        [Parameter()][String]$ComputerName
    )

    if ($PSVersionTable.PSVersion.ToString() -notmatch '^5.1') {
        Write-Error -Message "This function requires Windows PowerShell on Windows OS."
        break
    }

    $Script:local = $false

    if (!$PSBoundParameters.ContainsKey('ComputerName')) {
        $Script:local = $true
    }

    if (!$Script:local -and !(Test-Connection -ComputerName $ComputerName -Quiet)) {
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

    if ($PSBoundParameters.ContainsKey('Credential')) {
        if (!$Script:local) {
            $logon_users = @(Get-WmiObject -ClassName Win32_LoggedOnUser -ComputerName $computername -Credential $Credential)
            $logon_sessions = @(Get-WmiObject -ClassName Win32_LogonSession -ComputerName $computername -Credential $Credential)
        }
        else {
            $logon_users = @(Get-WmiObject -ClassName Win32_LoggedOnUser -Credential $Credential)
            $logon_sessions = @(Get-WmiObject -ClassName Win32_LogonSession -Credential $Credential)
        }
    }
    else {
        if (!$Script:local) {
            $logon_users = @(Get-WmiObject -ClassName Win32_LoggedOnUser -ComputerName $computername)
            $logon_sessions = @(Get-WmiObject -ClassName Win32_LogonSession -ComputerName $computername)
        }
        else {
            $logon_users = @(Get-WmiObject -ClassName Win32_LoggedOnUser)
            $logon_sessions = @(Get-WmiObject -ClassName Win32_LogonSession)
        }
    }

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