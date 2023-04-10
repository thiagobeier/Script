#=============================================================================================================================
#
# Script Name:     Remediate_Local_Admin_Account
# Description:     Detect Local Admin Account (Standard Account)
# Notes:           Detect New Local Admin Account (Standard Account)
#                  If User Exists, Update its password to standard
#                  If User doesn't Exist, creates it with standard password
#                  Update all other local accounts to standard password
# Author:          Thiago Beier
#                  @thiagobeier https://thebeier.com https://github.com/thiagobeier 
#                  Toronto, CANADA
# Version:         1.0
#=============================================================================================================================

# Define Variables
# remediate
clear
""
# Create New Local Admin Account
#Variables
$pass = "P@ssword1" #update the password
$password = $pass | ConvertTo-SecureString -AsPlainText -Force
$localadminuser = "NewLocalAdmin" #update the local admin upn
$localadminfullname = "New Local Admin" #update the local admin full name
$localadmindescription = "New Local Admin" #update the local admin description
	
#Functions
function CreateLocalUser {
    New-LocalUser -Name $localadminuser -Password $password -FullName $localadminfullname -Description $localadmindescription
    Add-LocalGroupMember -Group Users -Member NewLocalAdmin
    Add-LocalGroupMember -Group Administrators -Member NewLocalAdmin
}

function UpdateLocalAccountsPassword {
    get-localuser | Where-Object {$_.Name -ne "$($localadminuser)" -and $_.enabled -ne $false} | ForEach-Object {
        $_
        #$_ | Set-LocalUser -Password $Password
    }
}

# Locate local user

try
{   
    $findlocaluser = get-localuser | Where-Object {$_.Name -eq "$($localadminuser)"}
    if ($findlocaluser) {
        write-host -Foregroundcolor green "User $($localadminuser) Found"
        "Updating all other users password"
        UpdateLocalAccountsPassword #set all enabled users new password to Standard Password
        #exit 0
    } else {
        write-host -Foregroundcolor red "User $($localadminuser) not found"
        CreateLocalUser #create new local admin
        UpdateLocalAccountsPassword #set all enabled users new password to Standard Password
        #exit 1
    }   
}
catch{
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    #exit 1
}




""
