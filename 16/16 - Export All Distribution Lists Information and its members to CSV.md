Export All Distribution Lists Information and its members to CSV

Hi again,

Today's script runs after you connect on Office 365 Tenant Domain and need to
export all DL (Distribution List) information (Name) and its contents (users by
mailbox type).

Run this script for assessment, inventoroy or a backup during any changes you're
planning to make on your Tenant Domain.

Use the previous script I posted to manage your Office 365 Tenant
Domains <https://gallery.technet.microsoft.com/Office365-Azure-Powershell-2e65bdc2?redir=0>

Feel free to reach me anytime to share your experiences on using this script.

Always evaluate this script on a sandbox environment if possible.

Reach MSFT Technet Forums and Documentation to double check commands and its
syntaxes because sometimes a few commands get its switches updated or new are
introduced and you could expirience issues when running them.

 

 

**PowerShell**

\#  Copyright (C) 2019 by Thiago Beier (thiago.beier\@gmail.com)   

\#  Toronto, CANADA V1.0 

\#  All Rights Reserved.   

\#  This Script Export All Distribution Groups and Members List to CSV 

\#  CSV file syntax "All-Distribution-Group-Members-\$(get-date -f yyyy-MM-dd).csv" where "-\$(get-date -f yyyy-MM-dd)" add the date with 2019-02-03 format in the file name 

\#  There's an option to enable / disable the PowerShell Transcript (uncomment the \#start-transcript and \#stop-transcript on line \#9 and \#30  

\#  It generates the files under c:\\users\\%username% folder (user running the script) and be aware that if you're running as administrator sometimes it goes to c:\\users\\administrator instead your current user 

\$dateandtime = (**get-date** -f yyyy-MM-dd-mm-ss) 

\#start-transcript c:\\users\\%usrename%\\transcript-\$dateandtime.txt 

 

\$Result=\@() 

\$groups = Get-DistributionGroup -ResultSize Unlimited 

\$totalmbx = \$groups.Count 

\$i = 1  

\$groups \| **ForEach**-Object { 

**Write-Progress** -activity "Processing \$_.DisplayName" -status "\$i out of \$totalmbx completed" 

\$group = \$_ 

Get-DistributionGroupMember -Identity \$group.Name -ResultSize Unlimited \| **ForEach**-Object { 

\$member = \$_ 

\$Result += **New-Object** PSObject -property \@{  

GroupName = \$group.DisplayName 

Member = \$member.Name 

EmailAddress = \$member.PrimarySMTPAddress 

RecipientType= \$member.RecipientType 

}} 

\$i++ 

} 

\$Result \| **Export-CSV** "All-Distribution-Group-Members-\$dateandtime.csv" -NoTypeInformation -Encoding UTF8 

\#end 

\#stop-transcript

 
