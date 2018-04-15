<#
    .SYNOPSIS
        attach user volume group during logon 
	.Description
      	test if the user have a existing volume group, create from template if not exist and attach during logon
        First of all You must create a Volume Group Template with a pre-formated Disk inside each Nutanix Block, this uuid of this Volume Group must entered below
        to create a initial first clone of this volume group during first logon for each user.
		use get-help CTXNTXLogon.ps1 -full to see full help
    .EXAMPLE
		
    .Inputs
    .Outputs
    .NOTES
		Author: Matthias Schlimm
      	Company: EUCweb 
		
		History
      	Last Change: 14.03.2018 MS: script created
		
	.Link
#>

Add-PsSnapin NutanixCmdletsPSSnapin

clear-host
IF ($env:COMPUTERNAME -like "VDIDC1*")
{
    $NTXBlock = "Cluster-NTX-DC1" + $env:userdnsdomain
    $VGRPtemplateuuid= "c7941173-68c0-4e26-a045-5d9eb5fb0757"

} ELSE {
    $NTXBlock = "Cluster-NTX-DC2" + $env:userdnsdomain
    $VGRPtemplateuuid= "e3ff2f36-e627-459d-91f3-14f3df6e440d"
}
$NTXUser = "VDI"
$Secure_String_Pwd = ConvertTo-SecureString "Password" -AsPlainText -Force
$nxCLuster = Connect-NutanixCluster -Server $NTXBlock -UserName $NTXUser -Password $Secure_String_Pwd -AcceptInvalidSSLCerts

$VOLGRP = "VOLGRP_" + $env:username
$userISCSIuuid = Get-NTNXVolumeGroups | Where {$_.name -like "$volgrp"} | % {$_.uuid}



IF ($userISCSIuuid -eq $null)
{
$CloneTask = Clone-NTNXVolumeGroup -SourceVolumeGroupUuid $VGRPtemplateuuid -name $VOLGRP
 
#wait for
Do {
$CloneTaskStats = Get-NTNXTask -Taskid $CloneTask.taskUuid
Write-Host "Waiting for task to Complete "
}
While ($CloneTaskStats.progressStatus -ne "Succeeded")
$userISCSIuuid = Get-NTNXVolumeGroups | Where {$_.name -like "$volgrp"} | % {$_.uuid}
}

$VDIuuid =  get-ntnxvm | Where-Object {$_.vmName -eq $env:COMPUTERNAME}  | % {$_.uuid}


AttachVm-NTNXVolumeGroup -Uuid $userISCSIuuid -VmUuid $VDIuuid
Disconnect-NutanixCluster -Servers $NTXBlock
