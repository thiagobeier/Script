<#
.SYNOPSIS
This script retrieve all devices from Intune older and newer than $limit (30 days default) and add all devices to a cloud-based sec. group AAD / assigned group

.DESCRIPTION
This script retrieve all devices from Intune older and newer than $limit (30 days default)

.NOTES
Due to a limitation on MsGraph we grab the device Name and check its status in AAD isManaged isCompliant than retrieve its objectID (not in intune msgraph module)
Add devices to a cloud-based sec. group used in app deployment exclusion
$olderthanlimit  => list AAD devices older than 30 days / $limit
$newwerthanlimit => list AAD devices newer than 30 days / $limit
$aaddevices => AAD devices that are Intune managed , compliant and newer than 30 days / $limit
$uniqueArray => used to clear all duplicatd devices by name and objectid from aaddevices ( known issues for Hybrid Azure AD joined environment )
$targetGroupmembers => all AAD sec. group members 
Also check filter rules https://thiagobeier.wordpress.com/2023/03/09/automated-filter-population-in-intune/

.AUTHOR
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/21/2023
Version: 1.0
#>

clear

#Date and time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"
$logfile = "$env:temp\lastsynced-devices-$dt.log"
Start-Transcript -Path $logfile

#Variables
$targetaadgroupname = "All-AAD-Devices-Active-30-Days"

#Connect to MSGraph and List all Windows Devices
#Install-Module Microsoft.Graph -Scope AllUsers
#Connect-MSGraph
$Devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'Windows')" | Get-MSGraphAllPages

#Define the amount of days to exclude from the search

$limit = (Get-Date).AddDays(-30) #older than 30 days

<#
#added the opton to list older than 30 days
$olderthanlimit = $Devices | Where-Object {$_.lastsyncdatetime -lt $limit} | select devicename,lastsyncdatetime,azureADDeviceId #older than 30 days
#$olderthanlimit = $Devices | Where-Object {$_.lastsyncdatetime -lt $limit} #all devices info
#$olderthanlimit = $Devices | Where-Object {$_.lastsyncdatetime -lt $limit} | export-csv -NoTypeInformation -Encoding all-devices-older-than-limit.csv #all devices info to csv
"Older: $($olderthanlimit.count)"
#>

#Badr eddine Zaki asked for only devices active in the last 30 days 

$newwerthanlimit = $Devices | Where-Object {$_.lastsyncdatetime -gt $limit} | select devicename,lastsyncdatetime,azureADDeviceId #only devicename and lastsyncdatetime
#$newwerthanlimit = $Devices | Where-Object {$_.lastsyncdatetime -gt $limit}  #all devices info
#$newwerthanlimit = $Devices | Where-Object {$_.lastsyncdatetime -gt $limit} | export-csv -NoTypeInformation -Encoding all-devices-greater-than-limit.csv
"Newer: $($newwerthanlimit.count)"

#add devices by name, object it to AAD sec. group
#connect-azuread
$targetGroup = (AzureADPreview\Get-AzureADGroup -All:$true | Where-Object { ($_.DisplayName -like "$($targetaadgroupname)") }) #list target group info
#$targetGroup #used to debug
$targetGroupmembers = Get-AzureADGroupMember -All:$true -ObjectId $targetGroup.objectid
$targetGroupmembers

# Create empty array to store all Azure AD devices with devicename and objectid that are unique by name and objectid
$aaddevices = ""
$aaddevices = @()

#$top10 = $newwerthanlimit | Select-Object -First 10 #used to test with top 10 entries, uncoment line 75 and comment line 76 for this test with top10

#foreach ($deviceitem in $top10) { #uncoment to test with top 10 devices from aad list
foreach ($deviceitem in $newwerthanlimit) { #default all devices
    "working on Device Name $($deviceitem.devicename) , AzureADOBjectID $($deviceitem.azureADDeviceId)" #from Intune $Deviceslist
    ""
    $validDevice = Get-AzureADDevice -SearchString $deviceitem.devicename | where-object { $_.IsCompliant -eq $true -and $_.ismanaged -eq $true -and $_.ApproximateLastLogonTimeStamp -gt $limit } #fixed ApproximateLastLogonTimeStamp // Activity property in Device Properties (GUI)
    #$validDevice used to debug
    "This device => $($validDevice.displayname)"
    $validDevice | foreach-object {
    "working on device: $($_.displayname) , ID: $($_.objectid)"
    $item = @{devicename = $_.displayname; objectid = $_.objectid}
    $aaddevices += $item
    }
}
#$thearray

# Group objects by devicename and objectid and select the first item in each group
$uniqueArray = $aaddevices | Group-Object -Property @{Expression = {$_.devicename + $_.objectid}} | ForEach-Object { $_.Group[0] }

# Output unique array
#$uniqueArray

$uniqueArray.Count

# Compare arrays and add devices to AAD sec. group if device name with objectid is not member of the AAD sec. group
foreach ($obj1 in $uniqueArray) {
    $matchFound = $false
    foreach ($obj2 in $targetGroupmembers) {
        if ($obj1.objectid -eq $obj2.objectid) {
            $matchFound = $true
            Write-host -ForegroundColor Yellow "Object $($obj1.devicename) with objectid $($obj1.objectid) exist in AD Group"
            break
        }
    }
    if (-not $matchFound) {
        Write-Output "Object $($obj1.devicename) with objectid $($obj1.objectid) does not exist in AD Group"
        Add-AzureADGroupMember -ObjectId "$($targetgroup.ObjectId)" -RefObjectId "$($obj1.objectid)"
    }
}

Stop-Transcript
