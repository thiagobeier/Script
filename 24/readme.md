Add Multiple Users Exchange Online contacts permission

This script is going to add permission at user's mailbox for one single manager
at time.

You can manage you domain and tenant's domains using bulk commands to set
permission to all users in you organization.

You can improve this script as needed to your own environment, as we have a
large number of tenants and our customer support have to improve their time when
working in a ticket we're developping script to help us.

1st : connect to you Office 365 Domain

If you don't know how to do it check this
script [here](https://gallery.technet.microsoft.com/Office365-Exchange-bb504cce?redir=0)

Run the Script answer the input data needed and see what happens in real-time.

Once again, thanks for using this script.

 

**Enjoy the journey.**

**Thiago Beier**

 

**PowerShell**

\#  Copyright (C) 2017 by Thiago Beier (thiago.beier\@gmail.com)  

\#  Toronto, CANADA V1.0 A 

\#  All Rights Reserved.  

\#  This Script Add Permission for a specific user at users contacts on Office 365 / Exchange Domains 

\#  It requests Office 365 User Domain Admins account and asks for confirmation before running 

\#  It also show each user where permissions are being applied 

\#  At the line 28 there is the GET command to make sure you're connect at the correct Managed Domain 

 

\$manager = **Read-Host** -Prompt 'Input manager full e-mail address with domain' 

write-host -ForegroundColor Yellow "You have entered \$manager as the account to set the permissions" 

\$windowtitle = **Read-Host** -Prompt 'Name this PowershellWindows' 

\$host.ui.RawUI.WindowTitle = “\$windowtitle” 

 

\$message = "You have entered \$manager as the account to set the permissions" 

\$question = 'Are you sure you want to proceed?' 

 

\$choices = **New-Object** Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription] 

\$choices.Add((**New-Object** Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes')) 

\$choices.Add((**New-Object** Management.Automation.Host.ChoiceDescription -ArgumentList '&No')) 

 

\$decision = \$Host.UI.PromptForChoice(\$message, \$question, \$choices, 1) 

**if** (\$decision -eq 0) { 

  Write-Host -backgroundcolor black -foregroundcolor green 'confirmed' 

 

  \$AllMailboxs = Get-Mailbox -Resultsize Unlimited 

  **Foreach** (\$user **in** \$AllMailboxs)  

    { write-host -BackgroundColor red -ForegroundColor yellow "Executing for user \$user" 

        \#Get-MailboxFolderPermission -Identity \$user.Alias } 

        {add-MailboxFolderPermission –identity (\$user.alias+':\\contacts’)  -User \$manager -AccessRights Editor} 

 

} **else** { 

  Write-Host -BackgroundColor Red -ForegroundColor White 'cancelled' 

}

 
