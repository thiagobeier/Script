############################################################################################################################################################################################################################################### 
# Author Thiago Beier thiago.beier@gmail.com    
# Version: 1.0 - 2020-04-22   
#
# Search for a user on each Team at Microsoft Teams and remove it from there.
#
# Does not work with you switched your Membership ty into Dynamic at the Office Group (default is assigned)
#
# Toronto, CANADA    
# Email: thiago.beier@gmail.com  
# https://www.linkedin.com/in/tbeier/  
# https://twitter.com/thiagobeier 
# thiagobeier.wordpress.com 
###############################################################################################################################################################################################################################################   



#search for a user on each Team and remove it from there
clear
Start-Sleep 3
Start-Transcript -path "Team-Mgmt-Logfile_$((Get-Date).ToString('MM-dd-yyyy-hh-mm-ss')).txt" -NoClobber -IncludeInvocationHeader
$searchuser ="tcat@collabcan.com"
foreach ($team in Get-Team) {
#$team.DisplayName
write-host -ForegroundColor Green "Group:" $team.DisplayName
write-host -ForegroundColor Green "Groupid:" $team.GroupId
foreach ($user in get-teamuser -GroupId $team.GroupId) {
write-host -ForegroundColor Cyan "User:" $user.name
#Get-MsolUser -ObjectId $user.UserId
$email = (Get-MsolUser -ObjectId $user.UserId).userprincipalname
$email

[bool]$email
if (!$email) {write-host $email -ForegroundColor yellow "string is null or empty" } 
else {
write-host -ForegroundColor red $email "has value"
if ($email -eq $searchuser) {
write-host $email -ForegroundColor yellow "USER found! at" $team.DisplayName "Team"
write-host $email -ForegroundColor Magenta "removing USER from this Team"
Remove-TeamUser -GroupId $team.GroupId -User $email
}
}

}
}
Stop-Transcript
#end this 
