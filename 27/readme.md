**ADDS, Office365 and Teams Management**

Hi there

This script is based on 02 security groups used for licensing on Azure AD

| Group A                                     | Group B                                     | Group C                                          |
|---------------------------------------------|---------------------------------------------|--------------------------------------------------|
| E1-collab-lic                               | E3-collab-lic                               | O365_Teams_Mgmt                                  |
| All users with E1 license + Microsoft Teams | All users with E3 license + Microsoft Teams | All members from E1-collab-lic and E3-collab-lic |
| Security - Global                           | Security – Global                           | Security – Global                                |
| License only                                | License only                                | Permissions assignment on Teams – check article. |

All groups are synchronized to Azure AD

Regards,

**Thiago
Beier** [https://thiagobeier.wordpress.com](https://thiagobeier.wordpress.com/)

**Copyright © 2020 Thiago Beier Blog**
