<#
    .SYNOPSIS
        Create Files to Copy, copy and measure the time of copy
	.Description
      	
		use get-help CreateFiles.ps1 -full to see full help
    .EXAMPLE
		1. Create the Files to Copy
        CreateFiles.ps1 -CreateFiles
	.EXAMPLE
		2. Copy the Files and measure the Time
	    CreateFiles.ps1
    .EXAMPLE
    Inside of the Script you can change the Number of Files $NumberOfFiles to be created and and the Destinationdrive $destdrive for your environment
    .Inputs
    .Outputs
    .NOTES
		Author: Matthias Schlimm
      	Company: EUCweb 
		
		History
      	Last Change: 12.02.2018 MS: script created
		
	.Link
#>


Param( 
    [Parameter(Mandatory=$false)][Alias('C')][Switch]$CreateFiles      
) 


$script_path = $MyInvocation.MyCommand.Path
$script_dir = Split-Path -Parent $script_path
$Folders = @("1","1024000","10240000","20480000","51200000","102400000")
$timestamp = Get-Date -Format yyyyMMdd-HHmmss


#### this 2 values can be chaned by your own
$destdrive = "X:"
[int]$NumberOfFiles = 100
############################################

function write-log {
	
	Param( 
	    [Parameter(Mandatory=$True)][Alias('M')][String]$Msg,
        [Parameter(Mandatory=$False)][Alias('S')][switch]$ShowConsole,  
	    [Parameter(Mandatory=$False)][Alias('C')][String]$Color = "",
        [Parameter(Mandatory=$False)][Alias('T')][String]$Type = "",
		[Parameter(Mandatory=$False)][Alias('B')][switch]$SubMsg
        
	) 

	
	                     $LogType = "INFORMATION..."
    IF ($Type -eq "W" ) {$LogType = "WARNING..........."; $Color ="Yellow"}
    IF ($Type -eq "L" ) {$LogType = "EXTERNAL LOG...."; $Color ="DarkYellow"}
    IF ($Type -eq "E" ) {$LogType = "ERROR..............."; $Color ="Red"}

	IF (!($SubMsg))
	{
		$PreMsg = "+"
	} ELSE {
		$PreMsg = "`t>"
	}
	
    $date = get-date -Format G
    Out-File -Append -Filepath $logfile -inputobject "$date | $env:username | $LogType | $Msg" -Encoding default
	If (!($ShowConsole))
     {
        IF (($Type -eq "W") -or ($Type -eq "E" ))
        {
            IF ($VerbosePreference -eq 'SilentlyContinue')
            {
                Write-Host "$PreMsg $Msg" -ForegroundColor $Color
                #$Color = $null
            }
        } ELSE {
			Write-Verbose -Message "$PreMsg $Msg"
			#$Color = $null
        }		

	} ELSE {
	    if ($Color -ne "") 
        {
			IF ($VerbosePreference -eq 'SilentlyContinue')
            {
                Write-Host "$PreMsg $Msg" -ForegroundColor $Color
			    #$Color = $null
		    }
        } else {
			Write-Host "$PreMsg $Msg"
		}	
	}
    
    $Color = $null
    IF ($Type -eq "E" ) {$Global:TerminateScript=$true;start-sleep 30;Exit}
} 



function Create-Files 
{
    clear-host
    ForEach ($Folder in $Folders)
    {
    $destFolder = $script_dir + "\" + $Folder
    IF (!(Test-path "$destFolder")) {new-item -ItemType Directory $destFolder | out-null  }

    $i=0
     While ($true)
        {
            $i++
            $file = $script_dir + "\" + $Folder + "\file" +$i + ".txt"
    
            $size = $Folder
            Write-Host "create file $file with a size of $size"
    
    
            start-process -FilePath "C:\Windows\system32\fsutil.exe" -ArgumentList "file createnew $file $size" -Wait
    
            if ($i -eq $NumberOfFiles) {Break}
        }



    }
}



clear-host
If ($CreateFiles) {Create-Files}
$Global:LogFilePath = $script_dir + "\Log"
$Global:LogFileName = "File2Copy_$timestamp.log"
$Global:LogFileNameCSV = "File2Copy_$timestamp.csv"
$Global:Logfile = $LogFilePath + "\" + $LogFileName
IF (!(Test-path "$LogFilePath")) {new-item -ItemType Directory $LogFilePath | out-null  }


$destfolder = $destdrive +"\" +"VDI_FileCopy"
IF (!(Test-path "$destFolder")) {new-item -ItemType Directory $destFolder | out-null}


ForEach ($Folder in $Folders)
{
    
    $srcfolder =  $script_dir + "\" + $Folder
    Write-Log "Processing folder $srcfolder" -Color Cyan -ShowConsole
    $destFolderSize = $destfolder + "\" + $Folder
    IF (!(Test-path "$destFolderSize")) {new-item -ItemType Directory $destFolderSize | out-null}
    Write-Log "Destination folder $destFolderSize" -Color DarkCyan -ShowConsole -SubMsg
    $AllFiles = Get-ChildItem -Path "$srcfolder" | select Name,Length
    $startTime = (Get-Date)
    $i=0
    ForEach ($AllFile in $AllFiles)
    {
        $i++
        $FileName = $AllFile.Name
        $FileSize = $AllFile.Length
        $File2Copy = $srcfolder + "\" + $FileName
        $time2Copy=Measure-Command -Expression {Copy-Item -Path $File2Copy -Destination $destFolderSize -Force}
        Write-Log "Copy File $File2Copy with a size of $FileSize KB in $time2Copy (hh:mm:ss.ms)"  -Color DarkCyan -ShowConsole -SubMsg
        

    }
    $endTime = (Get-Date)
    $ElapsedTime = (($endTime-$startTime).TotalSeconds)
    
    Write-Log "Need $ElapsedTime to copy all Files in folder $srcfolder" -Color Green -ShowConsole -SubMsg
    "$Folder,$i,$ElapsedTime" | out-file "$LogFileNameCSV" -Append utf8
    $ElapsedTime=@()


   

}
