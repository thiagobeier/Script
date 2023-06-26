<#############################################################################################################
Description: Check if Windows Autopilot Device exists and import / update it based on Default or LOCATION code
Author: Thiago Beier thiago.beier@gmail.com @thiagobeier 
Usage: registers Windows devices to autopilot - Intune - Default 
Envirionment: DEV - CONTOSO
#############################################################################################################>


clear-host

#region Functions

# Functions
# Function to send notificaton to teams
function SendTeamsNotification {
    #sending end-user toast notification
    Write-Output 'sending end-user toast notification'

    $payload = @{
        "channel" = "#general"
        "text"    = "<style>h1 {text-align: center;}p {text-align: center;}div {text-align: center;}</style><h1><b>Alert</b></h1><br><table border=1><tr><th>Current Device Name</th><th>Current LOCATION-ID code</th><th>Date & Time</th><th>SERIAL</th><th>New LOCATION-ID code</th></tr><tr><td>$env:COMPUTERNAME</td><td>$($tmp.grouptag)</td><td>$dt</td><td>$serial</td><td>$DefaultGroupTag</td></tr></table>"
    }

    #then we invoke web request using the uri which is the Teamswebhook url alongside the post method to send our request
    Invoke-WebRequest -UseBasicParsing `
        -Body (ConvertTo-Json -Compress -InputObject $payload) `
        -Method Post `
        -Uri "<REPLACE-YOUR-TEAMS-CHANNEL-WEBHOOK-URL>"
    Write-Output "The condition was true"
}

#endregion

#region requirements
$LogFolder = 'C:\Logs'
#endregion

#region logfolder
#Test to see if folder [$LogFolder]  exists"
if (Test-Path -Path $LogFolder) {
    "Log folder exists!"
} else {
    "Log folder doesn't exist."
	New-Item -ItemType Directory -Path $LogFolder
	}
#endregion

#region TempFolder
#Test to see if folder [$TempFolder]  exists"
if (Test-Path -Path $TempFolder) {
    "TempFolder folder exists!"
} else {
    "TempFolder folder doesn't exist."
	New-Item -ItemType Directory -Path $TempFolder
	}
#endregion

#Date and time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"
$logfile = "$LogFolder\autopilot-registration-$dt.log"
Start-Transcript -Path $logfile

# begin


# Gather Autopilot details
"Gathering Autopilot details"
$session = New-CimSession
$serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber
$devDetail = (Get-CimInstance -CimSession $session -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
$hash = $devDetail.DeviceHardwareData

"Installing Required PowerShell modules"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Add the .\get-windowsautopilotinfo.ps1 community version requirements to not fail running it straight from PowerShell Gallery
$getwindowsautopilotinfocommunity = Get-InstalledScript get-windowsautopilotinfocommunity
if ($getwindowsautopilotinfocommunity) {
"getwindowsautopilotinfocommunity found"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Confirm:$false -Force:$true
} else {
#Install-Script -Name get-windowsautopilotinfocommunity -Confirm:$false -Force:$true
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Confirm:$false -Force:$true
}

"Registering Device in Windows autopilot devices"
#$DefaultGroupTag = "AADJ" #this is for Azure AD domain join windows autopilot deployment profile
$DefaultGroupTag = "" #this is for Hybrid Azure AD domain join windows autopilot deployment profile (default)

"Sending Teams Notification to Teams Channel"
#SendTeamsNotification

"Wait until device restarts to proceed with Autopilot"
.\get-windowsautopilotinfo.ps1 -Online -TenantId <REPLACE-YOUR-TENANT-ID> -AppId <REPLACE-YOUR-APP-ID> -AppSecret <REPLACE-YOUR-APP-SECRET> -GroupTag $DefaultGroupTag -assign -Reboot -Verbose


# end
Stop-Transcript
