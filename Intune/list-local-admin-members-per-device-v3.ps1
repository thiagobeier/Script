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
Version: 3.0
#>


# Date and Time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"

        $thisPC = $env:COMPUTERNAME
        $list = new-object -TypeName System.Collections.ArrayList
        foreach ($computer in $thisPC) {
            $admins = Get-WmiObject -Class win32_groupuser -ComputerName $computer | 
                Where-Object {$_.groupcomponent -like '*"Administrators"'} 
            $obj = New-Object -TypeName PSObject -Property @{
                ComputerName = $computer
                LocalAdmins = $null
            }
            foreach ($admin in $admins) {
                $null = $admin.partcomponent -match '.+Domain\=(.+)\,Name\=(.+)$' 
                $null = $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
                $obj.Localadmins += $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
            }
            $null = $list.add($obj)
        }
$list
# Create an empty array
$admins = @()

# Loop through the $result object and add each row as a new item in the $admins array
foreach ($row in $result) {
    $admin = [PSCustomObject]@{
        "DeviceName" = $env:COMPUTERNAME
        "Name" = $row.Name
        "Source" = $row.PrincipalSource
    }
    $admins += $admin
}

# Output the $admins array to the console
$admins | Export-Csv $env:COMPUTERNAME-admins-$dt.csv -NoTypeInformation