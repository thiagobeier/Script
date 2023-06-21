clear

#region Functions

# Functions
# Function to send notificaton to teams
function SendTeamsNotification {
    #sending end-user toast notification
    Write-Output 'sending end-user toast notification'

    $payload = @{
        "channel" = "#general"
        #"text" = "Alert!!! New Windows Autopilot Device Name: $env:COMPUTERNAME added to BULC: $grouptag "
        "text"    = "<style>h1 {text-align: center;}p {text-align: center;}div {text-align: center;}</style><h1><b>Alert</b></h1><br><table border=1><tr><th>Current Device Name</th><th>Current BULC code</th><th>Date & Time</th><th>SERIAL</th><th>New BULC code</th></tr><tr><td>$env:COMPUTERNAME</td><td>$($tmp.grouptag)</td><td>$dt</td><td>$serial</td><td>$DefaultGroupTag</td></tr></table>"
    }

    #then we invoke web request using the uri which is the Teamswebhook url alongside the post method to send our request
    Invoke-WebRequest -UseBasicParsing `
        -Body (ConvertTo-Json -Compress -InputObject $payload) `
        -Method Post `
        -Uri "https://constellationhbs.webhook.office.com/webhookb2/4636b885-c7b5-4775-81b4-006ccae589ba@f65d02be-9231-4769-9120-8d7f799652db/IncomingWebhook/252caf9b1c6a49a09eeeaa4b3d78ac38/7d967b9d-67ca-4833-9ad7-bf0ab5c69fc1"
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
<#
# Get NuGet
$provider = Get-PackageProvider NuGet -ErrorAction Ignore
if (-not $provider) {
Write-Host "Installing provider NuGet"
Find-PackageProvider -Name NuGet -ForceBootstrap -IncludeDependencies -Force:$true
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Confirm:$false -Force:$true
}
#>

$getwindowsautopilotinfocommunity = Get-InstalledScript get-windowsautopilotinfocommunity
if ($getwindowsautopilotinfocommunity) {
"getwindowsautopilotinfocommunity found"
Invoke-RestMethod -Uri https://raw.githubusercontent.com/thiagobeier/Script/master/Other/0/get-windowsautopilotinfo.ps1 -OutFile c:\temp\get-windowsautopilotinfo.ps1
} else {
Install-Script -Name get-windowsautopilotinfocommunity -Confirm:$false -Force:$true
Invoke-RestMethod -Uri https://raw.githubusercontent.com/thiagobeier/Script/master/Other/0/get-windowsautopilotinfo.ps1 -OutFile c:\temp\get-windowsautopilotinfo.ps1
}

Invoke-RestMethod -Uri https://github.com/thiagobeier/Script/raw/master/Other/0/CMTrace.exe -OutFile c:\temp\CMTrace.exe
./CMTrace.exe $logfile

"Registering Device in Windows autopilot devices"
$DefaultGroupTag = "BULC-AADJ"

#Set-executionpolicy -executionpolicy unrestricted -Force:$true
#SendTeamsNotification
#Start-Sleep 10
.\get-windowsautopilotinfo.ps1 -Online -TenantId f65d02be-9231-4769-9120-8d7f799652db -AppId 3e2602c0-9985-494a-aefe-dbecec36fa9a -AppSecret lNS8Q~5I1ccIroSuLOroDia8IVzKoxwo0jmHzaSy -GroupTag $DefaultGroupTag -assign -Reboot -Verbose


# end
Stop-Transcript
