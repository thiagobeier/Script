<#
Name: Import-AutopilotHash
Author: Thiago Beier, twitter @thiagobeier, https://thebeier.com thiago.beier@gmail.com
Version: 2.0
.Synopsis
   This script is meant to be used as part of provisioning package to automate importing autopilot hashes. It can be run from within the full OS or from the OOBE experience. Also send a notification to a Teams Channel
   This script checks if Windows Autopilot Device exists and import / update it based on Default or Bsiness code
.DESCRIPTION
    Import-AutopilotHash is part of a solution to autopmatically upload autopilot hashes directly to Microsoft Intune without direct interaction.
    It was created to be used as part of a provisioning package to allow hashes to be uploaded from the Out of Box experience with little to no interaction. After running the computer
    will return to the out of box experience and the user can continue to log in or a technician can take it through pre-provisioning. Please note that this script will exit once the first stage
    of the import has been completed. I recommend checking the Autopilot devices list to know when they upload has been completed.
    This script will leverage MSGraph. It was built for authentication with a client secret, but could be adjusted to allow for certificate based authentication. Since the
    client secret is hardcoded in the script, I recommend password protecting the PPKG file. The app registration used should also have limited permissions to limit it to being used for the
    specific purpose.
    Usage: Onboarding Windows devices to autopilot - Intune - Group Tag selected menu, where selection is from a central repository (TXT file from Azure blob storage)
    Additonal info: Check PS2EXE project https://www.powershellgallery.com/packages/ps2exe/1.0.11 to wrap this PS1 into EXE
.
#>

Clear-Host


#region requirements
$LogFolder = 'C:\Logs'
#endregion

#Date and time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"
$logfile = "$LogFolder\contoso-upload-hash-$dt.log"
Start-Transcript -Path $logfile

#region logfolder
#Test to see if folder [$LogFolder]  exists"
if (Test-Path -Path $LogFolder) {
"Log folder exists!"
} else {
"Log folder doesn't exist."
	New-Item -ItemType Directory -Path $LogFolder
	}
#endregion

#region functions
#Functions


function CollectSerial {
#add code here
write-host -ForegroundColor Cyan "CollectSerial"
}

function UploadToList {
#add code here
write-host -ForegroundColor Cyan "UploadToList"
}

function TeamsNotification {
#add code here
write-host -ForegroundColor Cyan "TeamsNotification"
}

function UploadHashToIntune {
#add code here
write-host -ForegroundColor Cyan "UploadHashToIntune"

#begin
# Device
# Gather Autopilot details
$session = New-CimSession
$serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber
$devDetail = (Get-CimInstance -CimSession $session -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
$hash = $devDetail.DeviceHardwareData
#$env:COMPUTERNAME


#powershell module
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -Confirm:$false
#Install-Module Microsoft.Graph -Scope CurrentUser -Force -Confirm:$false
#try this
#Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser -Force -Confirm:$false
#Install-Module -Name WindowsAutoPilotIntune -Scope CurrentUser -Force -Confirm:$false

# Generate Access Token to use in the connection string to MSGraph
# Contoso Tenant
Import-Module Microsoft.Graph.Intune 
Import-Module WindowsAutopilotIntune
#this is the part that i had to hardcodeinto the runbook.
$tenant = "YOURTENANT.ONMICROSOFT.COM" #YOURDOMAIN.COM
$authority = "https://login.windows.net/$tenant"
$clientid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantId = 'yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'
$clientSecret = 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'

Update-MSGraphEnvironment -AppId $clientId -Quiet 
Update-MSGraphEnvironment -AuthUrl $authority -Quiet 
Connect-MSGraph -ClientSecret $ClientSecret -Quiet

#Get-AutopilotDevice

#$certificate = "CN=PowerShell App-Only"
$certificate = "CERTNAME" #UPATE CERT NAME HERE
Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumbprint "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #UPDATE YOUR SSL CERT THUMBPRINT HERE

#device mgmt
$alldevices = Get-AutopilotDevice | Select ID, serialnumber, Grouptag, addressableUserName
$thisdevice = $alldevices | Where-Object {$_.serialNumber -eq "$serial"}
$thisdevice

if (!$thisdevice) {
"not found in autopilot"
#add device to autopilot
Write-host "Adding $($TAG_Output) grouptag to $($env:COMPUTERNAME)"
Add-AutoPilotImportedDevice -serialNumber $serial -hardwareIdentifier $hash -orderIdentifier $TAG_Output
start-sleep -seconds 10

while ($thisdevice.groupTag -ne $TAG_Output) {
$alldevices = Get-AutopilotDevice | Select ID, serialnumber, Grouptag, addressableUserName
$thisdevice = $alldevices | Where-Object {$_.serialNumber -eq "$serial"}
$thisdevice.groupTag
Write-Output "Waiting to import device to autopilot"
}

} else {
if ($thisdevice.groupTag -eq $TAG_Output) {
write-host "Device GroupTag matches - no update required"

} else {
#updates device tag to new tag
#Add-AutoPilotImportedDevice -serialNumber $serial -hardwareIdentifier $hash -orderIdentifier $TAG_Output
Get-AutopilotDevice -serial $serial | Set-AutopilotDevice -groupTag $TAG_Output
while ($thisdevice.groupTag -ne $TAG_Output) {
$alldevices = Get-AutopilotDevice | Select ID, serialnumber, Grouptag, addressableUserName
$thisdevice = $alldevices | Where-Object {$_.serialNumber -eq "$serial"}
$thisdevice.groupTag
Write-Output "Waiting to update tag to $TAG_Output"
start-sleep -seconds 10
}
}


}
#end

}

function CleanupAutopilotDevices {
#cleanup autopilot devices
#Start-Sleep -Seconds 60
write-host "Autopilot imported device cleanup"
Get-AutopilotImportedDevice | Where-Object { $_.serialNumber -match "$serial" }
(Get-AutopilotImportedDevice | Where-Object { $_.serialNumber -match "$serial" }).count
$deviceStatuses = Get-AutoPilotImportedDevice
$deviceStatuses | Remove-AutopilotImportedDevice
}


function ThisSelection {

Add-Type -AssemblyName System.Windows.Forms

# Download file from Azure blob storage
#$locatoinidfile = "https://csi0101.blob.core.windows.net/scripts/locationid.txt"
$locatoinidfile = "https://csi0101.blob.core.windows.net/scripts/newlocationid.txt"
Invoke-WebRequest -Uri $locatoinidfile -OutFile locationidv2.txt

# Define the path to your text file
$file = "locationidv2.txt"

# Read the contents of the text file into an array
$options = Get-Content $file

# Create a new Windows Forms form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select a (GroupTag)"
$form.AutoSize = $true # enable automatic sizing
$form.StartPosition = "CenterScreen" # center the form on the screen


# Create a new Windows Forms combo box (drop-down menu)
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Location = New-Object System.Drawing.Point(10, 10)
$combo.Width = 150
# Center the combo box within the form
$combo.Left = ($form.ClientSize.Width / 2) - ($combo.Width / 2)
$combo.Top = 20

# Add each option from the text file to the combo box
foreach ($option in $options) {
[void] $combo.Items.Add($option)
}

# Add the combo box to the form
$form.Controls.Add($combo)

# Create a new Windows Forms button
$button = New-Object System.Windows.Forms.Button
$button.Text = "OK"
$button.Location = New-Object System.Drawing.Point(220, 10)
$button.Width = 70
#$button.Height = 70
# Center the combo box within the form
$button.Left = ($form.ClientSize.Width / 2) - ($button.Width / 2)
$button.Top = 70


# Add an event handler to the button's Click event
$button.Add_Click({

$global:selectedOption = $combo.SelectedItem
$form.Close()
# Show confirmation dialog
[System.Windows.Forms.MessageBox]::Show("Are you sure you want to select '$selectedOption'?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) | Out-Null


})

# Add the button to the form
$form.Controls.Add($button)

# Show the form as a dialog box
[void] $form.ShowDialog()


# Display the selected option
if ($global:selectedOption) {
Write-Host -ForegroundColor Green "Selected GroupTag: $selectedOption"

return $selectedOption

} else {
Write-Host -ForegroundColor Red "No option selected."
}

} #end of ThisSelection function


$TAG_Output = ThisSelection
$groupTag = $TAG_Output
$groupTag

# Function to upload imported / updated devices to SharePoint List
# Detect Device Name
function Get-DsRegCmd {
# Dsregcmd powershell
$DsRegCmd = $env:COMPUTERNAME
return $Dsregcmd
}

$DSREG_Output = Get-DsRegCmd
#$DSREG_Output

UploadHashToIntune

CleanupAutopilotDevices

# Get Serial & update to Intune
CollectSerial

UploadHashToIntune

# UploadItem to Spt online lits
UploadToList

# Send Teams notification
TeamsNotification

Stop-Transcript