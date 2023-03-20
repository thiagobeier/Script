#  Copyright (C) 2019 by Thiago Beier (thiago.beier@gmail.com)   
#  Toronto, CANADA V1.0 - All Rights Reserved.   
#
#  This Script Export All Distribution Groups and Members List to CSV 
#  You can have your file from TXT or CSV to load all Distribution Lists you need to check
#  Make sure you have the c:\work\ directory created where you have the files dl.csv or dl.txt depending on your set up for this run
#  Uncomment the line #16 and comment the line #18 if you want to get content from a TXT file ; Uncomment the line #18 and comment the line #16 if you want to get content from a CSV file
#  There's an option to enable / disable the PowerShell Transcript (uncomment the #start-transcript and #stop-transcript on line #12 and #48 
#  It generates the files under c:\users\%username% folder (user running the script) and be aware that if you're running as administrator sometimes it goes to c:\users\administrator instead your current user 
#
$dateandtime = (get-date -f yyyy-MM-dd-mm-ss) 
#start-transcript c:\users\%usrename%\transcript-df-group-exist-$dateandtime.txt 

# Import the CSV and setup additional variables

#Get-Content c:\work\dl.txt | foreach-object { 

Import-Csv c:\work\dl.csv | foreach-object {

#Variable Attributes created from file

$name = $_.DLName

$usercheck = $null

# check if username exists already in AD

$groupcheck = Get-DistributionGroup -Identity $name

# Check search result to see if it's Null and then create the user

If ($groupcheck -eq $null) {

Write-Host "Group Check Completed - " + $_.DLName + " doesn't exist" `n`r -ForegroundColor Green
write-host "Creating this group" $_.DLName -ForegroundColor Cyan
New-DistributionGroup -Name $_.Displayname -Displayname $_.Displayname -Alias $_.Alias -PrimarySMTPAddress $_.email

}

# If it's not null, print out to screen

Else { Write-Host "User: "$_.DLName "already exists!"`n`r -ForegroundColor Red}

}


#end
#stop-transcript