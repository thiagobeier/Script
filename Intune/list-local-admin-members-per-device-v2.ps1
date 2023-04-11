<#
.SYNOPSIS
This script retrieve all members from local admin group from a specific device for those with issues on PowerShell from previous script published.
.DESCRIPTION
This script retrieve all members from local admin group from a specific device
V1 PowerShell https://github.com/thiagobeier/Script/blob/master/Intune/list-local-admin-members-per-device.ps1
.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 04/11/2023
Version: 1.0
#>


function Show-AdministratorGroupMembers {
    $administrators = @(
        ([ADSI]"WinNT://./Administrators").psbase.Invoke('Members') |
        ForEach-Object { 
            $_.GetType().InvokeMember('AdsPath', 'GetProperty', $null, $($_), $null) 
        }
    ) -match '^WinNT';
        
    $administrators = $administrators -replace 'WinNT://', ''
    $administrators

}
Show-AdministratorGroupMembers
