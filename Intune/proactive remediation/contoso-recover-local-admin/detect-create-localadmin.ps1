#=============================================================================================================================
#
# Script Name:     Detect_Local_Admin_Account
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

# Define Functions
function UpdateLocalAccountsPassword {
    $localadminuser = "NewLocalAdmin" #update the local admin upn
    get-localuser | Where-Object {$_.Name -ne $($localadminuser) -and $_.enabled -ne $false} | ForEach-Object {
        $_
        #$_ | Set-LocalUser -Password $Password
    }
}

# Define Variables
try
{   
    $localadminuser = "NewLocalAdmin" #update the local admin upn
    $findlocaluser = get-localuser | Where-Object {$_.Name -eq "$($localadminuser)"}
    if ($findlocaluser) {
        #write-host -Foregroundcolor green "User $($localadminuser) Found"
        "Compliant"
        #UpdateLocalAccountsPassword #set all enabled users new password to Standard Password
        exit 0
    } else {
        #write-host -Foregroundcolor red "User $($localadminuser) not found"
        "Not Compliant"
		#CreateLocalUser #create new local admin
        #UpdateLocalAccountsPassword #set all enabled users new password to Standard Password
        exit 1
    }   
}
catch{
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}
