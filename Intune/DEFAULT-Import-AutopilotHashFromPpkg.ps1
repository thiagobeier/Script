<#
Name: Import-AutopilotHashFromPpkg
Author: Sean Bulger, twitter @managed_blog, http://managed.modernendpoint.com
Updated by: Thiago Beier, twitter @thiagobeier, https://thebeier.com thiago.beier@gmail.com
Version: 2.0
.Synopsis
   This script is meant to be used as part of provisioning package to automate importing autopilot hashes. It can be run from within the full OS or from the OOBE experience. Also send a notification to a Teams Channel
   This script checks if Windows Autopilot Device exists and import / update it based on Default or Bsiness code
.DESCRIPTION
   Import-AutopilotHashFromPpkg is part of a solution to autopmatically upload autopilot hashes directly to Microsoft Intune without direct interaction.

    Full documentation can be found on my blog at https://www.modernendpoint.com/managed

    It was created to be used as part of a provisioning package to allow hashes to be uploaded from the Out of Box experience with little to no interaction. After running the computer
    will return to the out of box experience and the user can continue to log in or a technician can take it through pre-provisioning. Please note that this script will exit once the first stage
    of the import has been completed. I recommend checking the Autopilot devices list to know when they upload has been completed.

    This script will install and import the MSAL.ps module. It was built for authentication with a client secret, but could be adjusted to allow for certificate based authentication. Since the
    client secret is hardcoded in the script, I recommend password protecting the PPKG file. The app registration used should also have limited permissions to limit it to being used for the
    specific purpose.

    Usage: Onboarding Windows devices to autopilot - Intune - Group Tag = EMPTY
.
#>

Clear-Host

#Date and time
$date = Get-Date -Format "yyyy-MM-dd"
$fulldate = $date
$fulldate.Split("-")
$dtyear = $fulldate.Split("-")[0]
$dtmonth = $fulldate.Split("-")[1]
$dtday = $fulldate.Split("-")[2]
$workdir = "c:\temp\$dtyear\$dtmonth\$dtday"

if (Test-Path -Path $workdir) {
    "Working dir folder exists!"
}
else {
    "Working dir folder doesn't exist. Creating."
    New-Item -ItemType Directory -Path $workdir
}
set-location $workdir

$LogFolder = "$workdir"
$logfile = "$LogFolder\import-autopilot-hash-$dt.log"
Start-Transcript -Path $logfile
Start-Sleep -Seconds 5

# Functions

# Generate Access Token to use in the connection string to MSGraph
$AppId = 'YOUR-AZURE-AD-APP-ID'
$TenantId = 'YOUR-TENANT-ID'
$AppSecret = 'YOUR-AZURE-AD-APP-ID-SECRET'
$GroupTag = "" #Location code for Acquired company or BLANK for CSI Default => TL Joined


"Installing Packages"

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force:$true
Install-Script get-windowsautopilotinfo -Confirm:$false -Force:$true
Install-Module -Name Microsoft.Graph.Intune -Confirm:$false -Force:$true
Install-Module -Name WindowsAutoPilotIntune -Confirm:$false -Force:$true

"Importing hash"

#Get-WindowsAutoPilotInfo -Online -TenantId $TenantId -AppId $AppId -AppSecret $AppSecret -GroupTag $GroupTag

"Retrieving Serial"
#
# Gather Autopilot details
$session = New-CimSession
$serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber
$devDetail = (Get-CimInstance -CimSession $session -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
$hash = $devDetail.DeviceHardwareData

"Connecting MSGraph"

try
{
    Write-host "Attempting to connect to MSGraph (for Intune) 2"
    Import-Module Microsoft.Graph.Intune
    Import-Module WindowsAutopilotIntune
    $tenant = "YOURTENANT.onmicrosoft.com"
    $authority = "https://login.windows.net/$tenant"
    Update-MSGraphEnvironment -AppId $AppId -Quiet
    Update-MSGraphEnvironment -AuthUrl $authority -Quiet
    Connect-MSGraph -ClientSecret $AppSecret -Quiet
}
catch
{
    Write-host "ERROR: Could not connect to MSGraph (for Intune) - exiting!" -ForegroundColor Red
    write-host $_.Exception.Message -ForegroundColor Red
}

"Retrieving AutopilotImportedDevice"
$tmp = Get-AutopilotDevice -serial $Serial

if ($tmp)
{
    "Device Found in Windows Autopilot"
    $tmp.serialNumber
    $tmp.groupTag
    "Updating device to $grouptag"
    #Update Device GroupTag
    Get-AutopilotDevice -serial $Serial | Set-AutopilotDevice -groupTag $Grouptag
    #List Device
    Get-AutopilotDevice -serial $Serial | Select-Object serialnumber, GroupTag
    #$currentgrouptag = (Get-AutopilotDevice -serial $Serial).GroupTag #USED WITH OTHER CODE AS PROD TO UPDATE SHAREPOINT LISTS AND TEAMS NOTIFICATION

    "" | out-file $env:TEMP\autopilot.txt #save autopilot $env:temp


}
else
{
    "Device Not Found in Windows Autopilot"
    $tmp.serialNumber
    $tmp.groupTag
    "Uploading device to Windows Autopilot"
    Start-Sleep -Seconds 5
    $dev = Add-AutoPilotImportedDevice -serialNumber $serial -hardwareIdentifier $hash -orderIdentifier $grouptag
    $processingCount = 1
    while ($processingCount -gt 0)
    {
        $deviceStatuses = Get-AutoPilotImportedDevice -id ($dev).value.id
        $deviceCount = $deviceStatuses.Length
        if (-not $deviceCount -and $deviceStatuses ) { $devicecount = 1 }
        # Check to see if any devices are still processing
        $processingCount = 0
        foreach ($device in $deviceStatuses)
        {
            if ($device.state.deviceImportStatus -eq "unknown")
            {
                $processingCount = $processingCount + 1
            }
        }
        Write-Output "Waiting for $processingCount of $deviceCount"

        # Still processing?  Sleep before trying again.
        if ($processingCount -gt 0)
        {
            Start-Sleep 2
        }
    }
    #Display the statuses
    $deviceStatuses | ForEach-Object { Write-Output "Serial number $($_.serialNumber): $($_.state.deviceImportStatus) $($_.state.deviceErrorCode) $($_.state.deviceErrorName)" }

    "" | out-file $env:TEMP\autopilot.txt #save autopilot $env:temp THIS FILE IS USED IN A PROD ENVIRONMENT TO MAKE SURE DEVICE WAS ENROLLED AND IS OK TO SEND TEAMS NOTIFICATION, SPT LIST NOTIFICATION AND ALSO A TOAST TO LOGGED USER

    $currentgrouptag = (Get-AutopilotDevice -serial $Serial).GroupTag

    Get-AutopilotImportedDevice | Where-Object { $_.serialNumber -match "$serial" }

}

#

"Sending Notifications"
#Sent Teams Notification

"Uploading SharePoint Online List"
#Update SharePoint List

Stop-Transcript

