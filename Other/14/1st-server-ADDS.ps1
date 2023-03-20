<#

Attention: copy and paste it on the Powershell ISE and run each Steps separately

This is a script to be executed in two parts (Step1 and Step2) 
Where on Step1: it configures your server name, IP address, network mas and gateway and restarts it.
And on Step2: it configures the ADDS parameters such as domain name, netbios name, DataBasePath, ForestMode and DomainMode .

The script waits for an network connection named "Ethernet" , please change it according to your need

.LINK
http://exchangeserverpro.com/powershell-script-health-check-report-exchange-2010

.NOTES
Written by: Thiago Beier

Find me on:

* Our Community Blog: http://www.msbsb.com.br/
* Twitter:	https://twitter.com/thiagobeier
* LinkedIn:	https://br.linkedin.com/in/tbeier


For more Windows Server tips, tricks and news check out MSBSB.

* Website:	http://www.msbsb.com.br
* Twitter:	https://twitter.com/MS_BSB
* Facebook: https://www.facebook.com/comunidademsbsb

For Help with Tzutil check this link https://technet.microsoft.com/en-us/library/hh825053.aspx

Change Log
V1.00, 10/07/2013 - Initial version

#>

#Step1
$novonome = Read-Host  "Enter the name of the server"
$nomedominio = Read-Host "Enter the name of the domain" -ForegroundColor Yellow  
$nomenetbios = Read-Host "Enter the netbios name"
$ipaddr = Read-Host "Enter the ip address"
$mygw = Read-Host "Enter the gateway"
$dnsaddr = Read-Host "Enter the dns ip address"

#configura o timezone ; sets up the timeZone
tzutil /s "E. South America Standard Time"

#renomeia o computador ; rename the computername
Rename-Computer -NewName $novonome

#configura endereço IP na interface de nome "Ethernet" ; sets up an IP address to the "Ethernet" named adapter
New-NetIPAddress -IPAddress $ipaddr -InterfaceAlias Ethernet -DefaultGateway $mygw -AddressFamily IPv4 -PrefixLength 24

#configura o cliente DNS ; sets up the DNS client
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $dnsaddr

#Instala as features de gerencia de ADDS e GroupPolicy ; Installs ADDS and GroupPolicy tools
Install-WindowsFeature –Name AD-Domain-Services,GPMC –IncludeManagementTools

#reinicia o computador para validar as configurações realizadas ; restart computer to make new changes
Restart-Computer



#After the reboot continue with the next code to configure you ADDS on this server

#Step2

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') 
$nomedominio = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the Domain name', 'Domain Name') 
$nomenetbios = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the Netbios name', 'Netbios Name') 
Install-ADDSForest -Domainname $nomedominio -CreateDNSDelegation:$False -DataBasePath “C:\NTDS” -ForestMode Win2012 -DomainMode Win2012 -DomainNetBiosName $nomenetbios -InstallDNS:$True -LogPath “C:\NTDS” -SysvolPath “C:\NTDS\Sysvol”
Restart-Computer
