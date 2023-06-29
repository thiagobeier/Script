#Region : Set CLI to the Workgin Dir and Log
$FullDate = Get-Date -Format "yyyy-MM-dd"
$FullDate.Split("-")
$DTYear  = $FullDate.Split("-")[0]
$DTMonth = $FullDate.Split("-")[1]
$DTDay   = $FullDate.Split("-")[2]
$WorkDir = "C:\temp\$DTYear\$DTMonth\$DTDay"

# Test to see if folder [$LogFolder] exists
if (Test-Path -Path $WorkDir) {
    "Working dir folder exists!"
} else {
    "Working dir folder doesn't exist. Creating."
       New-Item -ItemType Directory -Path $WorkDir
       }
Set-Location "$WorkDir"