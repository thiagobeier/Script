Export Office365 User Roles to CSV (Admin Roles)

Hi there

I was creating a runbook to export information from an Office 365 tenant for a
project and in order to break it down into small parts I needed to check all
users and their roles at under this Office 365 tenant.

If you're looking for a script to export all Users' roles at Office 365 Portal /
Tenant please use this script that was initially posted by [Jerry
Yasir](https://twitter.com/jerryyasir) and I modified to fit a blog post
at [https://thiagobeier.wordpress.com](https://thiagobeier.wordpress.com/) 

 

**PowerShell**

\$Creds = **Get-Credential** 

 

Connect-MsolService -Credential \$Creds 

 

\$AllUserRoles = \@() 

 

\$Users = Get-MsolUser -All 

**foreach**(\$user **in** \$Users) 

{ 

    \$UserRoles = Get-MsolUserRole -UserPrincipalName \$User.UserPrincipalName 

    **foreach**(\$role **in** \$UserRoles) 

    { 

        \$aRole = **New-Object** PSObject 

        \$UserName = \$User.UserPrincipalName 

        \$RoleName = \$role.Name.ToString() 

 

        **Add-Member** -input \$aRole noteproperty ‘UserName’ \$UserName 

        **Add-Member** -input \$aRole noteproperty ‘RoleName’ \$RoleName 

        \$AllUserRoles += \$aRole 

    } 

} 

 

\$AllUserRoles \| **export-csv** -Path C:\\Temp\\O365UserRoles.csv -NoTypeInformation -Force

 
