# Nutanix-PoC
3 Scripts are ins this repro

1: createFiles.ps1:  Create Files to Copy, copy and measure the time of copy 

 1.1 Create the Files to Copy
        CreateFiles.ps1 -CreateFiles
	  
 1.2 Copy the Files and measure the Time
	    CreateFiles.ps1
      Inside of the Script you can change the Number of Files $NumberOfFiles to be created and and the Destinationdrive $destdrive for your environment
      
2: CTXNTXLogon.ps1

 attach user volume group during logon. Test if the user have a existing volume group, create from template if not exist and attach during logon. First of all You must create a Volume Group Template with a pre-formated Disk inside each Nutanix Block, this uuid of this Volume Group must entered in the script to create a initial first clone of this volume group during first logon for each user. 
 
3: CTXNTXLogoff.ps1

Detach the User Volume Group from the VM dring Logoff 
