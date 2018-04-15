<#
    .SYNOPSIS
        detach the User Volume Group from the VM dring Logoff
	.Description
      	
		use get-help CTXNTXLogoff.ps1 -full to see full help
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
$VDIuuid =  get-ntnxvm | Where-Object {$_.vmName -eq $env:COMPUTERNAME}  | % {$_.uuid}

DetachVm-NTNXVolumeGroup -Uuid $userISCSIuuid -VmUuid $VDIuuid
Disconnect-NutanixCluster -Servers $NTXBlock

