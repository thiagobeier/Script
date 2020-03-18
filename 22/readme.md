SCCM inventory & assessment

Hi everyone,

You can use those scripts to export and generate SCCM inventory & assessment.

You can customize the folder.

Tested on System Center Configuration Manager Current Branch - **SCCM 1902**

Tip:

Run all scripts as Administrator

Set the \$exportpath = "D:\\Export" to a local disk with large size or a UNC
path \\\\server\\export\$ (I prefer to use hidden folders)

You can also mount the UNC path localy 

net user \* \\\\server\\export\$ (That'll give you the next available DRIVE
LETTER to when connecting to the \\\\server\\export\$)

 

**PowerShell**

\#Script 01 - Export SCCM Apps 

 

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#    

\#Author Thiago Beier thiago.beier\@gmail.com    

\#Version: 1.0 - 2019-07-30   

\#Export SCCM Apps and its contents 

\#Export each apps separately  

\#Tested with SCCM Version: 1902  

\#Toronto,CANADA    

\#email: thiago.beier\@gmail.com  

\#https://www.linkedin.com/in/tbeier/  

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#   

 

\$exportpath = "D:\\Export" 

 

\$listappsname = Get-CMApplication \| **select** LocalizedDisplayName 

**foreach** (\$appname **in** \$listappsname) { 

    \$appsname = \$appname.LocalizedDisplayName 

    write-host \$appsname -ForegroundColor Green 

    Export-CMApplication -Name \$appsname -Path \$exportpath\\apps\\\$appsname.zip 

  } 

 

 

\#Script 02 - Export SCCM collections members 

 

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#    

\#Author Thiago Beier thiago.beier\@gmail.com    

\#Version: 1.0 - 2019-07-30   

\#Export SCCM Collections info 

\#Export each collection info separately  

\#Tested with SCCM Version: 1902  

\#Toronto,CANADA    

\#email: thiago.beier\@gmail.com  

\#https://www.linkedin.com/in/tbeier/  

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#   

 

\$exportpath = "D:\\Export" 

 

\#Get-CMCollection 

\$querylist = Get-CMCollection  \#\| select collectionid,name 

**foreach** (\$queryitem **in** \$querylist) { 

    \$name = \$queryitem.Name 

    \$colid = \$queryitem.collectionid 

    write-host \$name -ForegroundColor Green 

    Write-Host \$colid-\$name -ForegroundColor Yellow 

    Get-CMCollection -Id \$colid \| Get-CMCollectionMember \| **select** Name,primaryuser,lastlogonuser,currentlogonuser,adsitename \| **Export-csv** "\$exportpath\\collections\\\$colid-\$name.csv" -Encoding UTF8 

  } 

 

 

\#Script 03 - Export SCCM packages 

 

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#    

\#Author Thiago Beier thiago.beier\@gmail.com    

\#Version: 1.0 - 2019-07-30   

\#Export SCCM Packages and its contents 

\#Export each package separately  

\#Tested with SCCM Version: 1902  

\#Toronto,CANADA    

\#email: thiago.beier\@gmail.com  

\#https://www.linkedin.com/in/tbeier/  

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#   

 

\$exportpath = "D:\\Export" 

 

\$listpackage = Get-CMPackage \| **select** Name 

**foreach** (\$pkgname **in** \$listpackage) { 

    \$name = \$pkgname.Name 

    \#write-host \$pkgname.Name -ForegroundColor Green 

    write-host \$name -ForegroundColor Green 

    Export-CMPackage -Name \$name -ExportFilePath \$exportpath\\pkg\\\$name.zip 

  } 

 

 

\#Script 04 - Export SCCM Queries 

 

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#    

\#Author Thiago Beier thiago.beier\@gmail.com    

\#Version: 1.0 - 2019-07-30   

\#Export SCCM queries 

\#Export each query separately  

\#Tested with SCCM Version: 1902  

\#Toronto,CANADA    

\#email: thiago.beier\@gmail.com  

\#https://www.linkedin.com/in/tbeier/  

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#   

 

\$exportpath = "D:\\Export" 

 

\$querylist = Get-CMQuery \| **select** name 

**foreach** (\$queryitem **in** \$querylist) { 

    \$name = \$queryitem.name 

    \#write-host querylist -ForegroundColor Green 

    write-host \$name -ForegroundColor Green 

    Export-CMQuery -Name \$name -ExportFilePath \$exportpath\\queries\\\$name.mof 

  } 

 

 

\#Script 05 - Export SCCM task sequences 

 

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#    

\#Author Thiago Beier thiago.beier\@gmail.com    

\#Version: 1.0 - 2019-07-30   

\#Export SCCM Task Sequences 

\#Export each TS separately  

\#Tested with SCCM Version: 1902  

\#Toronto,CANADA    

\#email: thiago.beier\@gmail.com  

\#https://www.linkedin.com/in/tbeier/  

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#   

 

\$exportpath = "D:\\Export" 

 

\$querylist = Get-CMTaskSequence \| **select** name 

**foreach** (\$queryitem **in** \$querylist) { 

    \$name = \$queryitem.name 

    \#write-host querylist -ForegroundColor Green 

    write-host \$name -ForegroundColor Green 

    Export-CMTaskSequence -Name \$name -WithDependence \$True -WithContent \$True -ErrorAction **Continue** -ExportFilePath \$exportpath\\ts\\\$name.zip 

  } 

 

 
