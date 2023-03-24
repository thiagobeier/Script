# script to set the group tag on one or more devices
# niall brady 2023/03/17
# version 0.01 2023/03/17 Script creation
# version 0.02 2023/03/22 adding bulk logic to read serials from csv
# version 0.03 2023/03/23 by Thiago Beier @thiagobeier , https://thebeier.com added write-log function (saves to c:\logs\) and its funtion to all entries before write-host

clear-host

function Write-Log {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [Alias('LogPath')]
        [string]$Path = 'C:\Logs\PowerShellLog.log',
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Error", "Warn", "Info")]
        [string]$Level = "Info",
        
        [Parameter(Mandatory = $false)]
        [switch]$NoClobber
    )

    Begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process {
        
        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
        }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
        }

        else {
            # Nothing to see here yet.
        }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
            }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
            }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
            }
        }
        
        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End {
    }
}

function Select-GroupTag {
    do {
        Write-Host "Select the Group Tag you want to use:" `r`r
        Write-host "1. GroupTag1 `n2. GroupTag2 `n3. GroupTag3 `n4. Remove Group Tag"
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {
                $Global:newGroupTag = "GroupTag1"
                Write-host "Group tag will be set to: "$Global:newGroupTag
                write-host "`n"
            }
            "2" {
                $Global:newGroupTag = "GroupTag2"
                Write-host "Group tag will be set to: "$Global:newGroupTag
                write-host "`n"
            }
            "3" {
                $Global:newGroupTag = "GroupTag3"
                Write-host "Group tag will be set to: "$Global:newGroupTag
                write-host "`n"
            }
            "4" {
                $Global:newGroupTag = ""
                Write-host "Group tag will be set to: "$Global:newGroupTag
                write-host "`n"
            }

        }
    }
    until (1..4 -contains $menuresponse) 
}

function Select-ImportType {
    do {
        Write-Host "Select the import type:" `r`r
        Write-host "1. Single computer `n2. Multiple computers"
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {
                $Global:ImportType = "Single"
                Write-host "Group tag will be set to: "$Global:ImportType
                write-host "`n"
            }
            "2" {
                $Global:ImportType = "Multiple"
                Write-host "Group tag will be set to: "$Global:ImportType
                write-host "`n"
            }
        }
    }
    until (1..2 -contains $menuresponse) 
}

function YesNo {
    Do {
        #[System.Console]::CursorTop = $Cursor
        #Clear-Host
        $Answer = Read-Host -Prompt 'Set the group tag (y/n)'
    }
    Until ($Answer -eq 'y' -or $Answer -eq 'n')
    $Global:Answer = $Answer
}

function get-serial {
    $global:serialnumber = Read-Host -Prompt "Enter the serial number that you want to set the Group tag on..."
    $global:serialnumber = $global:serialnumber.ToUpper()
}

#########################################################################################################################################

$script = "Set-GroupTag"
$version = "0.03"
$importpath = "C:\temp\2023\03\23\computers.txt"
write-host "Starting script '$script' version '$version'."
write-host "`nPlease note: If you want to set the group tag of multiple computers, add them to the following text file one SERIAL number per line: '$importpath'`n"

if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Log -Level Info "User has correct permissions.. continuing."
    write-host "User has correct permissions.. continuing."
}
else {
    Write-Log -Level Info "Please run this script as a user with local Administrator permissions."
    write-host "Please run this script as a user with local Administrator permissions."

    break
}

# script magic starts here
Write-Log -Level Info "Please wait, installing Graph..."
write-host "Please wait, installing Graph..."

Install-Module -name Microsoft.Graph.Intune -Scope AllUsers 
#Connect-MgGraph -TenantId "yourTenant GUID" 
Write-Log -Level Info "Connecting to Graph..."
write-host "Connecting to Graph..."

Connect-MSGraph
write-host "Updating Graph..."
Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet
Connect-MSGraph -Quiet
$selecteddevice = $null

Select-GroupTag
Select-ImportType
#write-host "'$Global:ImportType'"

Write-Log -Level Info "reading current group tag values, please wait..."
write-host "reading current group tag values, please wait..."

# Get all autopilot devices (even if more than 1000)
$autopilotDevices = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities" | Get-MSGraphAllPages


If ($Global:ImportType -eq "Single") {
    # get specific device based on serial number
    get-serial
    #$global:serialnumber = "5CG1081VHY"
    Write-Log -Level Info "you entered: $global:serialnumber"
    write-host "you entered: $global:serialnumber"
    $selecteddevice = $autopilotDevices | Where-Object { $_.serialNumber -eq $global:serialnumber }
    #$autopilotDevices.serialNumber | -Match $global:serialnumber
    #write-host $selecteddevice

    if ($selecteddevice) {
        $Global:oldGroupTag = $selecteddevice.groupTag
        Write-Log -Level Info "Old group tag: $Global:oldGroupTag"
        Write-Log -Level Info "New group tag: $Global:newgroupTag"
        write-host "Old group tag: " $Global:oldGroupTag
        write-host "New group tag: " $Global:newgroupTag

        # final confirmation should we set it ?
        YesNo
        if ($global:answer -eq "y") {
            write-host "The user chose to set the group tag" 
            $autopilotDevice = $selecteddevice
            $autopilotDevice.groupTag = $Global:newgroupTag
            #$autopilotDevice.orderIdentifier = "ORDER1234" | updating orderidentifier is currently not supported

            $requestBody =
            @"
{
groupTag: `"$($autopilotDevice.groupTag)`",
}
"@
            Write-Log -Level Info "Updating entity: $($autopilotDevice.id) | groupTag: $($autopilotDevice.groupTag) | orderIdentifier: $($autopilotDevice.orderIdentifier)"
            Write-Output "Updating entity: $($autopilotDevice.id) | groupTag: $($autopilotDevice.groupTag) | orderIdentifier: $($autopilotDevice.orderIdentifier)"
            Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody -Url "deviceManagement/windowsAutopilotDeviceIdentities/$($autopilotDevice.id)/UpdateDeviceProperties" 
            #}

            # Invoke an autopilot service sync
            Invoke-MSGraphRequest -HttpMethod POST -Url "deviceManagement/windowsAutopilotSettings/sync"


        }
        else {
            Write-Log -Level Info "The user chose to cancel setting the group tag"
            write-host "The user chose to cancel setting the group tag"
        }

    }
    else {
        Write-Log -Level Warn "that serial number was not found in Windows Autopilot devices"
        write-host "that serial number was not found in Windows Autopilot devices"
    }

}

If ($Global:ImportType -eq "Multiple") {

    $ComputersArray = Get-Content $importpath
    # final confirmation should we set it ?
    write-host "`nNote: You are about to set the group tag of all the computers in the list, you will only be prompted once !`n"
    YesNo
    write-host "`n"
    ForEach ($Computer in $ComputersArray) {
        $global:serialnumber = $Computer
        Write-Log -Level Info "Bulk set: $global:serialnumber"
        write-host "Bulk set: $global:serialnumber"

        $selecteddevice = $autopilotDevices | Where-Object { $_.serialNumber -eq $global:serialnumber }
        #$autopilotDevices.serialNumber | -Match $global:serialnumber
        #write-host $selecteddevice

        if ($selecteddevice) {
            $Global:oldGroupTag = $selecteddevice.groupTag
            Write-Log -Level Info "Old group tag: " $Global:oldGroupTag
            Write-Log -Level Info "New group tag: " $Global:newgroupTag
            write-host "Old group tag: " $Global:oldGroupTag
            write-host "New group tag: " $Global:newgroupTag

            if ($global:answer -eq "y") {
                write-host "The user chose to set the group tag" 
                $autopilotDevice = $selecteddevice
                $autopilotDevice.groupTag = $Global:newgroupTag
                #$autopilotDevice.orderIdentifier = "ORDER1234" | updating orderidentifier is currently not supported

                $requestBody =
                @"
{
groupTag: `"$($autopilotDevice.groupTag)`",
}
"@
                Write-Log -Level Info "Updating entity: $($autopilotDevice.id) | groupTag: $($autopilotDevice.groupTag) | orderIdentifier: $($autopilotDevice.orderIdentifier)"
                Write-Output "Updating entity: $($autopilotDevice.id) | groupTag: $($autopilotDevice.groupTag) | orderIdentifier: $($autopilotDevice.orderIdentifier)"
                Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody -Url "deviceManagement/windowsAutopilotDeviceIdentities/$($autopilotDevice.id)/UpdateDeviceProperties" 
                #}

            }
            else {
                Write-Log -Level Info "The user chose to cancel setting the group tag"
                write-host "The user chose to cancel setting the group tag"
            }
        } 
        else {
            Write-Log -Level Warn "that serial number was not found in Windows Autopilot devices"
            write-host "that serial number was not found in Windows Autopilot devices"
        }
    }
    # Invoke an autopilot service sync
    Invoke-MSGraphRequest -HttpMethod POST -Url "deviceManagement/windowsAutopilotSettings/sync"
}

Write-Log -Level Info "all done!, exiting script."
write-host "all done!, exiting script."
