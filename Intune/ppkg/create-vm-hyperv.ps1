<#
.SYNOPSIS
This script creates a vm with specified Name at c:\VMS\ attaching existing ISO from c:\VMS\isos\
This powershell will create c:\VMS\  and  c:\VMS\isos\ if don't exist

.DESCRIPTION
This is customized for my Hyper-v running on Microsoft Windows 11 Enterprise
Have your ISO file downloaded on the folder before you run this powershell
Update $vmFolderPath $isosFolderPath $myvmname and $isofile prior you run this script

.HARDWARE
System Manufacturer	Dell Inc.
System Model	    Latitude 5520
Installed Physical Memory (RAM)	32.0 GB

.REFERENCES
https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vmfirmware?view=windowsserver2019-ps
https://www.itexperience.net/fix-this-device-cant-use-a-trusted-platform-module/


.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/29/2023
Version: 1.0
#>

# Variables
#create folder if don't exist
$vmFolderPath = "c:\vms"
$isosFolderPath = "c:\vms\isos"

#define vm name
$myvmname = "NULL"
#$isofile = "c:\vms\isos\en-us_windows_11_business_editions_version_22h2_updated_oct_2022_x64_dvd_080047de.iso" #windows 11 ISO
$isofile = "c:\vms\isos\en-us_windows_server_2022_updated_dec_2022_x64_dvd_14fe3ddc.iso" #SERVER 2022

#create $vmFolderPath and $isosFolderPath if don't exist

if (!(Test-Path $vmFolderPath)) {
    New-Item -ItemType Directory -Path $vmFolderPath | Out-Null
}

if (!(Test-Path $isosFolderPath)) {
    New-Item -ItemType Directory -Path $isosFolderPath | Out-Null
}

# Functions
#This is a yesNo prompt funcion used on CreateVM function 

function Get-YesNoPrompt {
    [CmdletBinding()]
    param (
        [string] $Message = "Are you sure you want to proceed?"
    )

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Proceed with the operation."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Cancel the operation."
    $choices = [System.Management.Automation.Host.ChoiceDescription[]] ($yes, $no)
    $defaultChoice = [System.Management.Automation.Host.ChoiceDescription] $no

    $decision = $Host.UI.PromptForChoice($null, $Message, $choices, 1)

    if ($decision -eq 0) {
        return $true
    }
    else {
        return $false
    }
}



#This function creates the VM from variable using ISO from variables under $vmFolderPath = "c:\vms" and $isosFolderPath = "c:\vms\isos"
#Asks to confirm before proceeding

function CreateVM {

#prompt yesNo function
if (Get-YesNoPrompt "Are you sure you want to proceed with VM creation => VMName: $($myvmname) and $($isofile) ?") {
    # User chose "Yes", so proceed with the operation.


if ((Test-Path $isofile) -and !(get-vm -Name $myvmname -ErrorAction SilentlyContinue)) { #checks for $myvmname and $isofile ISO not found = error, VM same name exists ERROR
write-host -ForegroundColor Green "Creating VM: $($myvmname) from ISO: $($isofile)" 
#create vm on hyperv
New-VM -Name $myvmname -MemoryStartupBytes 8GB -BootDevice VHD -NewVHDPath C:\VMS\$myvmname\$myvmname.vhdx -Path C:\VMS\$myvmname\ -NewVHDSizeBytes 60GB -Generation 2 -Switch "Default Switch"
Add-VMDvdDrive -Path $isofile -VMName $myvmname
Set-VMProcessor -VMName "$myvmname" -count 2

#update, change boot order
$myvm = Get-VMFirmware -VMName $myvmname
$myvm.bootorder #default vm has pxe, hdd, dvddrive order
$hddrive = $myvm.BootOrder[0]
$pxe = $myvm.BootOrder[1]
$dvddrive = $myvm.BootOrder[2]

Set-VMFirmware -VMName $myvmname -BootOrder $dvddrive,$hddrive,$pxe #update/change bootorder to dvd, hdd, pxe
$myvm = Get-VMFirmware -VMName $myvmname
$myvm.bootorder

#Enable TPM module on vm

#Type the following cmdlet to import the Hyper-V module:
import-module Hyper-V
#Copy-paste the following cmdlets to configure a valid key protector
$owner = Get-HgsGuardian UntrustedGuardian
$kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
#You have now created a valid key protector. You may now apply the HgsKeyProtector to the VM:
Set-VMKeyProtector -VMName $myvmname -KeyProtector $kp.RawData
#(obviously, replace <VMname> with the name of your Virtual Machine, as shown in HyperV Manager.
#You can now turn TPM with this cmdlet:
Enable-VMTPM -VMName $myvmname

#start vm and connect
Checkpoint-VM -Name $myvmname -SnapshotName "FreshVM" #before setup / hash uploaded

#sleep for 10 seconds
Start-Sleep -Seconds 10

#start vm and connect to it
Start-VM -VMName $myvmname
vmconnect.exe localhost $myvmname

} else {write-host -ForegroundColor Red "ISO file not found or VM exists"}

}
else {
    # User chose "No", so cancel the operation.
}

}


<#
Additional commands

#save a checkpoint
#Checkpoint-VM -Name $myvmname -SnapshotName "OSready" #before setup / hash imported to autopilot if that's the case
#Checkpoint-VM -Name $myvmname -SnapshotName "Finished Windows install" #after hash uploaded

#dvd
#Get-VM $myvmname | Get-VMDvdDrive
#Set-VMDvdDrive -VMName $myvmname -ControllerNumber 0 -ControllerLocation 1 -Path $null
#Get-VMDvdDrive -VMName $myvmname | Set-VMDvdDrive -Path "C:\vms\ISOS\Tools.iso"
#Get-VMDvdDrive -VMName $myvmname | Set-VMDvdDrive -Path "C:\vms\ISOS\USB.iso"

#Get-Command -Module hyper-v | Out-GridView
#get-vm -Name $myvmname

#>



CreateVM
