<#
.SYNOPSIS
This script list current devices enrolled into intune or registered in autopilot and add to cloud-based security group

.DESCRIPTION
This script list current autopilot enrollment status
Checks IDs across Intune, Windows Autopilot devices and Azure AD and validate which device by name and objectID is the device to be added to sec. group
Please check Diagarm to understand IDs correlation and usage in ADDS, AzureAD (AAD) and Intune.

.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 05/11/2023
Version: 1.0
#>

clear-host


$targetAzureADGroupName = "Windows Autopilot Temporary"

$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"
$logfile = "$env:temp\windows-autopilot-temporary-$dt.log"

Start-Transcript -Path $logfile

Write-Host "Connecting with MSGraph and AzureAD"
Connect-MSGraph # Please update as per your environment
Connect-AzureAD # Please update as per your environment

#start date to list devices enrolled or registered to autopilot
$startdate = "2023-05-10" 

#add devices by name, object it to AAD sec. group
Write-Host "Fetching Target Group"
$targetGroup = (Get-AzureADGroup -All:$true | Where-Object { ($_.DisplayName -like "$($targetAzureADGroupName)") })

Write-Host "Windows Autopilot Device"
$windowsAutopilot = Get-AutopilotEvent | Where-Object { $_.deploymentEndDateTime -gt $startdate } 

Write-Host "Intune Managed Device"
$windowsAutopilot | ForEach-Object {

    $b = $_.deviceSerialNumber

    $MyDevice = Get-IntuneManagedDevice | Get-MSGraphAllPages | Where-Object { $_.SerialNumber -match $b }
    $intune = $MyDevice | Select-Object devicename, id, userid, managedDeviceId, enrolleddateimte, lastsyncdatetime, serialnumber, userprincipalname
    #$intune

    $intune | ForEach-Object {
        Write-Host "AAD device"
        $_.deviceName
        $_.serialnumber

        $aad = get-azureaddevice -all:$true -SearchString "$($_.deviceName)" #| fl displayname,deviceid,objectid,*time*,profiletype,accountenabled
        $aad.DisplayName
        $aad.DeviceId
        $aad.ObjectId

        ##
        # Get the members of the Azure AD group
        $groupMembers = Get-AzureADGroupMember -ObjectId $targetgroup.ObjectId

        # Check if the device exists in the group
        $deviceExists = $false

        foreach ($member in $groupMembers) {
            if ($member.ObjectId -eq $aad.ObjectId) {
                $deviceExists = $true
                break
            }
        }

        # Output the result
        if ($deviceExists) {
            Write-Host "The device $($aad.deviceName) exists in the Azure AD group."
        }
        else {
            Write-Host "The device $($aad.deviceName) does not exist in the Azure AD group."
            Write-Host "Adding $($aad.deviceName) , SerialNumber $($_.serialnumber) to Group $($targetgroup.DisplayName)"
            Add-AzureADGroupMember -ObjectId $targetgroup.ObjectId -RefObjectId $aad.ObjectId
        
        }
        ##

    }

    
}

$windowsAutopilot.managedDeviceName
$windowsAutopilot.deviceSerialNumber

Stop-Transcript
