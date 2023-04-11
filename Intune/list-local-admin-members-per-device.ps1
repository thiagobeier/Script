<#
.SYNOPSIS
This script retrieve all members from local admin group from a specific device
.DESCRIPTION
This script retrieve all members from local admin group from a specific device
Saves to CSV file using $dt variable on the name as well DEVICE NAME from $env:computername
.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 04/11/2023
Version: 1.0
#>


# Date and Time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"

# Result as the Get-LocalGroupMember

$result = Get-LocalGroupMember -Group administrators | Select-Object Name, PrincipalSource 

$result | Export-Csv $env:COMPUTERNAME-$dt.csv -NoTypeInformation #To CSV using $dt variable on the name as well DEVICE NAME from $env:computername

# Create an empty array
$admins = @()

# Loop through the $result object and add each row as a new item in the $admins array
foreach ($row in $result) {
    $admin = [PSCustomObject]@{
        "DeviceName" = $env:COMPUTERNAME
        "Name" = $row.Name
        "PrincipalSource" = $row.PrincipalSource
    }
    $admins += $admin
}

# Output the $admins array to the console
$admins

# Output the $admins array to CSV file name 
$admins | Export-Csv $env:COMPUTERNAME-admins-$dt.csv -NoTypeInformation #To CSV using $dt variable on the name as well DEVICE NAME from $env:computername
