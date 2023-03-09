<#
.SYNOPSIS
This script retrieve all devices from Intune that have Azure AD Device Id as null / 00000000-0000-0000-0000-000000000000

.DESCRIPTION
This script checks for stale devices in Intune and delete them all from Intune

.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/09/2023
Version: 1.0

#>

# Date and Time
$date = Get-Date -Format "yyyy-MM-dd"
$fulldate = $date
$fulldate.Split("-")
$dtyear = $fulldate.Split("-")[0]
$dtmonth = $fulldate.Split("-")[1]
$dtday = $fulldate.Split("-")[2]
$workdir = "c:\temp\$dtyear\$dtmonth\$dtday"

#Test to see if folder [$LogFolder]  exists"
if (Test-Path -Path $workdir) {
    "Working dir folder exists!"
}
else {
    "Working dir folder doesn't exist. Creating."
    New-Item -ItemType Directory -Path $workdir
}
set-location $workdir

# Log folder and Transcript
$LogFolder = "$workdir"
$mainlogfile = $LogFolder + "\" + $logfile

Start-Transcript -Path $mainlogfile

#
Connect-MSGraph                                                                                                                                                                                            

$Devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'Windows')" | Get-MSGraphAllPages                                                                                                    

$Devices | Where-Object {$_.azureADDeviceId -eq "00000000-0000-0000-0000-000000000000"} | Select-Object deviceName,serialnumber,userprincipalname,id | export-csv -NoTypeInformation -Encoding utf8 Intune-Stale-Devices-$dt.csv -Append

$Devices | Where-Object {$_.azureADDeviceId -eq "00000000-0000-0000-0000-000000000000"} | ForEach-Object {
    "Working on Device: $($_.devicename)"
    Remove-IntuneManagedDevice -managedDeviceId $_.id
}

stop-transcript

