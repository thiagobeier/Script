Monitor DFS backlog and Send email notification.

This script monitors DFSR backlog to make sure the files are being synchronized
between all servers on each RF (Replication Folder) published in the AD (Active
Directory) Forest.

Pre-requisites

-   save the script in a folder i.e.: c:\\scripts\\

-   [schedule ](https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/)this
    script on Task Scheduler 

-   open the IP address of the server (DFS member server) where the script is
    scheduled on in the Firewall to send email on TCP port 25 to your
    \$SMTPServer 

Execution

-   changes in the script code

    -   change the \$EMailFrom, \$EmailTo1 or \$EmailTo"X" where "X" is the
        amount of SMTP recipients you're emailing on this script

    -   change the \$SMTPServer IP address or DNS name

    -   there's an output file named "C:\\scripts\\dfslog-\$(get-date -f
        yyyy-MM-dd).txt" where when the powershell runs create the following
        name **dfslog-2019-01-10.txt ; **this file is used on both \$result and
        \$results variables

    -   the script has different thresholds that shows on screen on RED when it
        achieves a high value according to your file server analysis

**PowerShell**

\#DFS Monitor and email message 

\#run as administrator 

\#SMTP configuration 

\$EmailFrom = "alerts\@mydomain.ca" 

\$EmailTo = "alerts\@mydomain.ca" 

\$EmailTo1 = "daniel\@mydomain.ca" 

\$EmailTo2 = "joao\@mydomain.ca" 

\$EmailTo3 = "thiago\@mydomain.ca" 

\$EmailSubject = "DFS Monitoring Report" 

\$emailbody = "Server reached predefined amount of files in backlog" 

\$SMTPServer = "smtp.my-isp.ca" 

 

\#Starts here 

 

\$RGroups = **Get-WmiObject**  -Namespace "root\\MicrosoftDFS" -Query "SELECT \* FROM DfsrReplicationGroupConfig" 

\$ComputerName=\$env:ComputerName 

\$Succ=0 

\$Warn=0 

\$Err=0 

**foreach** (\$Group **in** \$RGroups) 

{ 

    \$RGFoldersWMIQ = "SELECT \* FROM DfsrReplicatedFolderConfig WHERE ReplicationGroupGUID='" + \$Group.ReplicationGroupGUID + "'" 

    \$RGFolders = **Get-WmiObject** -Namespace "root\\MicrosoftDFS" -Query  \$RGFoldersWMIQ 

    \$RGConnectionsWMIQ = "SELECT \* FROM DfsrConnectionConfig WHERE ReplicationGroupGUID='"+ \$Group.ReplicationGroupGUID + "'" 

    \$RGConnections = **Get-WmiObject** -Namespace "root\\MicrosoftDFS" -Query  \$RGConnectionsWMIQ 

    **foreach** (\$Connection **in** \$RGConnections) 

    { 

        \$ConnectionName = \$Connection.PartnerName\#.Trim() 

        **if** (\$Connection.Enabled -eq \$True) 

        { 

            \#if (((New-Object System.Net.NetworkInformation.ping).send("\$ConnectionName")).Status -eq "Success") 

            \#{ 

                **foreach** (\$Folder **in** \$RGFolders) 

                { 

                    \$RGName = \$Group.ReplicationGroupName 

                    \$RFName = \$Folder.ReplicatedFolderName 

                    **if** (\$Connection.Inbound -eq \$True) 

                    { 

                        \$SendingMember = \$ConnectionName 

                        \$ReceivingMember = \$ComputerName 

                        \$Direction="inbound" 

                    } 

                    **else** 

                    { 

                        \$SendingMember = \$ComputerName 

                        \$ReceivingMember = \$ConnectionName 

                        \$Direction="outbound" 

                    } 

                    \$BLCommand = "dfsrdiag Backlog /RGName:'" + \$RGName + "' /RFName:'" + \$RFName + "' /SendingMember:" + \$SendingMember + " /ReceivingMember:" + \$ReceivingMember 

                    \$Backlog = **Invoke-Expression** -Command \$BLCommand 

                    \$BackLogFilecount = 0 

                    **foreach** (\$item **in** \$Backlog) 

                    {                         

                        **if** (\$item -ilike "\*Backlog File count\*") 

                        {                       

                            \$BacklogFileCount = [int]\$Item.Split(":")[1].Trim() 

                        } 

                    } 

                    **if** (\$BacklogFileCount -eq 0) 

                    { 

                        \$Color="white" 

                        \$Succ=\$Succ+1 

                    } 

                    **elseif** (\$BacklogFilecount -lt 10000) 

                    { 

                        \$Color="yellow" 

                        \$Warn=\$Warn+1 

                    } 

                    **else** 

                    { 

                        \$Color="red" 

                        \$Err=\$Err+1 

                    } 

                    \$results = Write-Host "\$BacklogFileCount files in backlog \$SendingMember-\>\$ReceivingMember for \$RGName" -fore \$Color  

                    \$results1 = Write-Output "\$BacklogFileCount files in backlog \$SendingMember-\>\$ReceivingMember for \$RGName" \| Out-File -FilePath C:\\scripts\\dfslog-\$(**get-date** -f yyyy-MM-dd).txt -Append 

                } \# Closing iterate through all folders 

            \#} \# Closing  If replies to ping 

        } \# Closing  If Connection enabled 

    } \# Closing iteration through all connections 

} \# Closing iteration through all groups 

 

 

Send-MailMessage -Port 25 -SmtpServer \$SMTPServer -**From** \$EmailFrom -To \$EmailTo,\$EmailTo1,\$EmailTo2,\$EmailTo3 -Subject \$EmailSubject -Attachments C:\\scripts\\dfslog-\$(**get-date** -f yyyy-MM-dd).txt 

 

\#reference https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/send-mailmessage?f=255&MSPPError=-2147217396 

 

 

References

<https://github.com/N-able/CustomMonitoring/blob/master/DFSR%20Monitoring%20V2/DFSR%20Monitoring%20V2.ps1>
