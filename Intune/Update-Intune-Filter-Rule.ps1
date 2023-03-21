<#
.SYNOPSIS
This script retrieve all members from a Cloud-based Security Group and add them as Devices into Intune Filter used to Exclude these targeted devcies from getting Existing App reinstalled.

.DESCRIPTION
This script checks created a working dir (c:\temp\YYYY\MM\DD\) and set its location to that workdir then if the list provided and the security group exists in the spcific tenant it runs.
Check Lines 50, 56 and 57 for Input variables $tenant , $filterName and $phase2GroupName

.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/06/2023
Version: 1.0

#>


#Powershell Modules
#Get-Module azuread
#connect-azuread
#Connect-MSGraph
#Connect-MgGraph
#Install-Module azureadpreview -AllowClobber -Force

#region 00 - defaults
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
#endregion

#region 01 - code
#Date and time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"
$LogFolder = "$workdir"
$logfile = "$LogFolder\graphapi-update-filters-$dt.log"
Start-Transcript -Path $logfile

#Tenant Information 
$tenant = “YOURTENANTNAME.onmicrosoft.com”
$Resource = "deviceManagement/assignmentFilters"
$graphApiVersion = "Beta"
$uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"

#variables
$filterName = "Exclude - McAfee" #This is the Filter Name
$phase2GroupName = "Norton Install Phase 2" #This is the Cloud-based sec. group Name for Phase2

#work on filters
$Filters = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
$thisfilter = $Filters.value | Where-Object {$_.displayname -eq "$($filterName)"}

#working on phase2 sec. group
$aadgroup = Get-AzureADGroup -All:$true | Where-Object { ($_.DisplayName -like "$($phase2GroupName)*") }

#clear arrays
$aadgroupsarray = ""
$currentrulelist1 = ""

if ($thisfilter -and $aadgroup) {
#export Backup - all existing filters
Invoke-MSGraphRequest -HttpMethod GET -Url $uri | ConvertTo-Json | Out-File -FilePath .\Intune-Filters-$dt.json

"Filter and Phase2 Group found. Proceeding"
#working o filter
$thisfilter.rule | Out-File thisfilter-$dt.txt
$dd = ($thisfilter.rule -split ' or ') -ne ''
$ee = $dd.Replace('(device.deviceName -eq "',"")
$ff = $ee.Replace('")',"")
$thisfilterdvclist = $ff | ForEach-Object {$_.trim()} | Sort-Object
($thisfilterdvclist | Sort-Object -Unique).count

#device list from AAD device group
$aadgroupsarray = @()
# Loop through each item in the array and write it to the console
foreach ($item in $phase2GroupName) {
    Write-Host $item
    $aadgroup = Get-AzureADGroup -All:$true | Where-Object { ($_.DisplayName -like "$($item)*") }
    $aadgroupmembers = Get-AzureADGroupMember -ObjectId $aadgroup.ObjectId
    $aadgroupsarray += $aadgroupmembers.displayname
}
($aadgroupsarray | Sort-Object -Unique).count
$filterrulelist = $aadgroupsarray | Sort-Object -Unique
$filterrulelist.trim()

#create array from graph api list
#json rule format for devices from text file
$currentrulelist1 = ""
$currentrulelist1 = @()
ForEach ($item in $filterrulelist.trim()) { 

$newdevicetoadd = '(device.deviceName -eq \"' + $item + '\")'
$currentrulelist1 += $newdevicetoadd

}
#list on screen
""
"NEW List from Phase2 Sec. Group has: $($currentrulelist1.count) Devices"

#Create rule list to be parsed in JSON
"JSON rule list"
""
$JsonRuleList = ""
$or = "or "
$or.Length
$newList = $currentrulelist1
# Loop through each item in the array
foreach ($item in $newList) {

    # Check if the current item is not the last item in the array
    if ($item -ne $newList[-1]) {
        # Concatenate the current item with the $or variable and append it to the output string
        $JsonRuleList += "$item $or"
    }
    else {
        # If the current item is the last item in the array, append it to the output string without the $or variable
        $JsonRuleList += "$item"
    }
}

# Output the final concatenated string
$JsonRuleList

#PATCH - Update filter 
"Filter: $($thisfilter.displayname) has ID: $($thisfilter.id)"
$Resource = "deviceManagement/assignmentFilters"
$graphApiVersion = "Beta"
$uri2 = "https://graph.microsoft.com/beta/deviceManagement/assignmentFilters/$($thisfilter.id)" #PROD

#JSON rule and rolescopetags. Only update RULE (add , remove objects + OR)
$JSON = @"
{
"rule":"$($JsonRuleList)","roleScopeTags":["0"]
}
"@
 
$JSON #| Convertfrom-Json
 
Invoke-MSGraphRequest -HttpMethod PATCH -Url $uri2 -Content $JSON #update filter rule

} else {"Contact Automation Team"}


Stop-Transcript

#endregion