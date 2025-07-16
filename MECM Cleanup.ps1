# Written by: John Muhar for RBC- john.muhar@rbc.com
# Script Purpose: v1.0 - This script will connect to the MECM Primary site and query WMI for the names of all the applications or packages located in the root of Applications\Packages in MECM.
                # Based on the naming convention (RBC Dist code at the beginning of the application\package name as well as application\package version), a folder structure will be created as the destination
                # for the application\package move. The applications\packages will then be moved to their appropriate folder.
#
# Original Construction Date: v1.0 - 07-30-2025
# Modified by: John Muhar for RBC- john.muhar@rbc.com
# Revision Date: v1.1 - MM-DD-YYYY - Modifications
#==============================================================================================================================================================================

#Functions
#==============================================================================================================================================================================
#==============================================================================================================================================================================
Function Write-Log {
#==============================================================================================================================================================================
    <#
    .SYNOPSIS
       Create/Append a log file in the SCCM log file style. Write output to console with color. 

    .DESCRIPTION
       Create/Append a log file in the SCCM log file style. Write output to console with color.

       The severity of the logged line can be set as:

            1 - Information
            2 - Warning
            3 - Error

    .EXAMPLE
       Write-Log c:\output\configure.log "The installation of this component failed." Set_Registry 3

       This will write a line to the configure.log file in c:\output stating that "The installation of this component failed.".
       The source component will be Set_Registry and the line will be highlighted in red as it is an error 
       (severity - 3).

    #>
#==============================================================================================================================================================================

    #Define and validate parameters

    [CmdletBinding()]
    Param(
          #Path to the log file
          [parameter(Mandatory=$True)]
          [String]$OSDLogfile,

          #The information to log
          [parameter(Mandatory=$True)]
          [String]$Message,

          #The source of the error
          [parameter(Mandatory=$True)]
          [String]$Component,

          #The severity (1 - Information, 2- Warning, 3 - Error)
          [parameter(Mandatory=$True)]
          [ValidateRange(1,3)]
          [Single]$Severity
          )


    #Obtain UTC offset
    $DateTime = New-Object -ComObject WbemScripting.SWbemDateTime 
    $DateTime.SetVarDate($(Get-Date))
    $UtcValue = $DateTime.Value
    $UtcOffset = $UtcValue.Substring(21, $UtcValue.Length - 21)


    #Create the line to be logged
    $NewLine =  "<![LOG[$Message]LOG]!>" +`
                "<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
                "date=`"$(Get-Date -Format M-d-yyyy)`" " +`
                "component=`"$Component`" " +`
                "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
                "type=`"$Severity`" " +`
                "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +`
                "file=`"`">"

    #Write the line to the passed log file
    Add-Content -Path $OSDLogFile -Value $NewLine

}
#==============================================================================================================================================================================
Function Update-RunningGUI {
    #update the form
    $TextBox1.text = $Message
    $form1.Refresh()
    start-sleep -Seconds 1
}
#==============================================================================================================================================================================
Function Update-ProgressBar {
    [int]$pct = ($i/$numitems) * 100
    #update the progress bar
    $progressbar1.Value = $pct
    start-sleep -Seconds 1
}
#==============================================================================================================================================================================
Function Display-Message{
    Param (
          #Display Message
          [parameter(Mandatory=$True)]
          [String]$Message,

          #Icon in messagebox
          [parameter(Mandatory=$True)]
          [String]$MessageIconType
    )
	    $BoxTitle = $MessageBoxTitle
	    #$Message must be supplied by the occurring error to supply details
	    # Pop up a message
	    Add-Type -AssemblyName PresentationCore, PresentationFramework
	    $ButtonType = [System.Windows.MessageBoxButton]::Ok
	    $MessageIcon = [System.Windows.MessageBoxImage]::$MessageIconType #Error, Question, Warning, Information 
	    [System.Windows.MessageBox]::Show($Message, $BoxTitle, $ButtonType, $messageicon)
}
#==============================================================================================================================================================================
Function Open-LogFile {
    Try {
        $reglocation = "HKLM:\SOFTWARE\Microsoft\SMS\Client\Configuration\Client Properties"
        $ccminstalled = (Get-ItemProperty $reglocation -Name 'Local SMS Path' -ErrorAction Stop).'Local SMS Path'
        $loglauncher = "$ccminstalled" + "cmtrace.exe"
        Push-Location $ccminstalled
    }
    Catch {
        #use notepad instead
        $loglauncher = "$env:SystemRoot\System32\notepad.exe"
    }
    & $loglauncher $logfile
}
#==============================================================================================================================================================================
#==============================================================================================================================================================================
$Button1_Click = { #the Start button. Main script goes here
	$Button1.Enabled = $false #disable the start button once it is clicked
    $Message = "Starting item cleanup..."
	Write-Log $logFile $Message $ComponentName 1
	Update-RunningGUI

	#Check for MECM console and module
	If (Test-Path Env:PSModulePath) {
		$Message = "PSModule path found.Checking for MECM console path..."
		Write-Log $logFile $Message $ComponentName 1
		Update-RunningGUI
		If ((Get-Item Env:PSModulePath).Value -like "*Configuration Manager*") { #change to CurrentBranchAdmin for RBC
			$Message = "MECM console path found. Loading the PowerShell Configuration Manager module..."
			Write-Log $logFile $Message $ComponentName 1
			Update-RunningGUI
		}
		else {
			$Message = "MECM console path NOT found. This utility is aborting."
			Write-Log $logFile $Message $ComponentName 3
			Display-Message $Message "Error"
			$Form1.Close()
		}
	}
	else {
		$Message = "The PSModulePath environment variable does NOT exist. This utility is aborting."
		Write-Log $logFile $Message $ComponentName 3
		Display-Message $Message "Error"
		$Form1.Close()
	}
    #Load the MECM module
    $initParams = @{}
    Try {
        $Message = "Importing the ConfigurationManager.psd1 module..."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams -ErrorAction Stop
        $Message = "Successfully imported the ConfigurationManager.psd1 module."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
    }
    Catch [System.Exception] {
        $Message = "Failed to import the ConfigurationManager.psd1 module. This utility is aborting. Error: $($_.Exception.Message)"
        Write-Log $logFile $Message $ComponentName 3
        Display-Message $Message "Error"
        $form1.Close()
        Open-LogFile
    }
    # Connect to the site's drive
    If ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        Try {
            $Message = "Connecting to the MECM site drive..."
            Write-Log $logFile $Message $ComponentName 1
            Update-RunningGUI
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams -ErrorAction Stop
            $Message = "Successfully connected to the MECM site drive."
            Write-Log $logFile $Message $ComponentName 1
            Update-RunningGUI
        }
        Catch [System.Exception] {
            $Message = "Failed to connect to the MECM site drive. This utility is aborting. Error: $($_.Exception.Message)"
            Write-Log $logFile $Message $ComponentName 3
            Display-Message $Message "Error"
            $form1.Close()
            Open-LogFile
        }
    }
    else {
        $Message = "Already connected to the MECM site drive..."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
    }

    #Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams
    #Connect to WMI on the MECM Primary site and query for items in the root node
    Try {
        $Message = "Connecting to the MECM Primary Site $ProviderMachineName WMI instance..."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
        $itemlist = (Get-WmiObject -Computername $ProviderMachineName -Namespace "ROOT\SMS\Site_$SiteCode" -Query "select * from $nodelocation where ObjectPath = '/'" -ErrorAction Stop).$NameFormat 
        #Write-Host $itemlist
        $Message = "Successfully connected to the MECM Primary Site $ProviderMachineName WMI instance. Getting list of items in root node."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
    }
    Catch [System.Exception] {
        $Message = "Failed to connect to the MECM Primary Site $ProviderMachineName WMI instance. This utility is aborting. Error: $($_.Exception.Message)"
        Write-Log $logFile $Message $ComponentName 3
        Display-Message $Message "Error"
        $form1.Close()
        Open-LogFile   
    }
    $Message = "Loading item list to process..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
    $Message = "Successfully loaded item list."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI

    #get the number of items in list
    $numitems = $itemlist.Count
    $Message = "Found $numitems item(s) to process."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI

    If ($numitems -eq 0) {#no items in root found
        $Message = "Found no items in the root node. This utility is aborting."
        Write-Log $logFile $Message $ComponentName 2
        Display-Message $Message "Warning"
        $form1.Close()
        Open-LogFile
    }

    Foreach ($item in $itemlist){
        Write-Log $logFile '*****************************************************************************************************************************' $ComponentName 1
        Write-Log $logFile '*****************************************************************************************************************************' $ComponentName 1
        #for each iteration reset variable ErrorFound to 'NO'
        $ErrorFound = 'NO'
        $Message = "Processing $item..."
        Write-Log $logFile $Message $ComponentName 1
        #parse all characters up to the first dash(-) and strip out any spaces
        $distcode = ($item.Split("-")[0]).Trim()

        #test the string against the regular expression as defined in teh Declare variables section
        If ($distcode -match $regex){
            $Message = "Distribution code is $distcode."
            Write-Log $logFile $Message $ComponentName 1
            Update-RunningGUI
            #if distribution code is valid, set the two digit Parent Distribution code
            $ParentDistCode = $distcode.Substring(0,2)
            $Message = "Parent Distribution code is $ParentDistCode..."
            Write-Log $logFile $Message $ComponentName 1
            Update-RunningGUI
            }
        else {
            $ErrorFound = 'YES'
            $numerror++
            $Message = "Distribution code $distcode format is NOT valid. Skipping folder creation and item move..."
            Write-Log $logFile $Message $ComponentName 3
            Update-RunningGUI
        }
        If ($ErrorFound -eq 'NO') {
            #Get item version to set the version folder name
            If ($parentPath -eq 'Application') {
                $itemverfolder ="v" + (Get-CMApplication -Name $item).softwareversion
            }
            If ($parentPath -eq 'Package') {
                $itemverfolder ="v" + (Get-CMPackage -Name $item -Fast).version
            }
            $Message = "Item version folder is $itemverfolder"
            Write-Log $logFile $Message $ComponentName 1
            Update-RunningGUI
        }
        #create folders
        If ($ErrorFound -eq 'NO') {
            $FolderVarList = @(
                [pscustomobject]@{Folder = "$ParentDistCode"; FolderPath="$parentPath\$MasterItemFolder"}
                [pscustomobject]@{Folder = "$distcode"; FolderPath="$parentPath\$MasterItemFolder\$ParentDistCode"}
                [pscustomobject]@{Folder = "$itemverfolder"; FolderPath="$parentPath\$MasterItemFolder\$ParentDistCode\$distcode"}
            )

            ForEach ($FolderVar in $FolderVarList) { 
                $folder = $FolderVar.Folder
                $folderpath = $FolderVar.FolderPath
                If (!(Get-CMFolder -FolderPath $folderpath\$folder)) {
                    $Message = "Folder $folderpath\$folder NOT found"
                    Write-Log $logFile $Message $ComponentName 1
                    Update-RunningGUI
                    Try {
                        $Message = "Creating folder $folderpath\$folder..."
                        Write-Log $logFile $Message $ComponentName 1
                        Update-RunningGUI
                        New-CMFolder -ParentFolderPath "$folderpath" -Name $folder -ErrorAction Stop
                        $Message = "Finished creating folder $folderpath\$folder."
                        Write-Log $logFile $Message $ComponentName 1
                        Update-RunningGUI
                    }
                    Catch [System.Exception] {
                        $Message = "Failed creating folder $folderpath\$folder. Skipping item move. Error: $($_.Exception.Message)"
                        Write-Log $logFile $Message $ComponentName 3
                        Update-RunningGUI
                        $ErrorFound = 'YES'
                        $numerror++
                    }
                }
                else {
                    $Message = "Folder $folderpath\$folder found. Skipping.."
                    Write-Log $logFile $Message $ComponentName 1
                    Update-RunningGUI
                }
            }
            If ($ErrorFound -eq 'NO'){
                $MoveLocation = "$SiteCode" + ":\" + "$parentPath\$MasterItemFolder\$ParentDistCode\$distcode\$itemverfolder"
                $Message = "Moving $item to $MoveLocation"
                Write-Log $logFile $Message $ComponentName 1
                Update-RunningGUI
                Try {
                    If ($parentPath -eq 'Application') {
                        $ItemObject = Get-CMApplication -Name "$item" -ErrorAction Stop
                    }
                    If ($parentPath -eq 'Package') {
                        $ItemObject = Get-CMPackage -Name "$item" -Fast -ErrorAction Stop
                    }
                    Move-CMObject -FolderPath "$MoveLocation" -InputObject $ItemObject -ErrorAction Stop
                    $Message = "Successfully moved $item to $MoveLocation"
                    Write-Log $logFile $Message $ComponentName 1
                    Update-RunningGUI
                }
                Catch [System.Exception] {
                    $Message = "Failed to move $item to $MoveLocation. Error: $($_.Exception.Message)"
                    Write-Log $logFile $Message $ComponentName 1
                    Update-RunningGUI
                    $ErrorFound = 'YES'
                    $numerror++
                }
            }
        }
        $i++ #iterate the item counter list for progress bar update
        Update-ProgressBar
    }
    $Message = "Finished processing all items in list"
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI

    #Check to see if any errors occurred, if so try and open the log file with cmtrace, or notepad if cmtrace not found
    If ($numerror -eq 0) { #no errors found
        $Message = "All items were successfully moved with no errors."
        $form1.Close()
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
        $form1.Close()
        Display-Message $Message "Information"
    }
    else {
        $Message = "There were $numerror error(s) found. Check log file for details."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
        $form1.Close()
        Display-Message $Message "Error"
        Open-LogFile
    }    
    $Button1.Enabled = $true
}
#==============================================================================================================================================================================
#==============================================================================================================================================================================  

$RadioButton1_CheckedChanged = {
}
$GroupBox1_Enter = {
}
$Button2_Click = { #The Close button
	$Form1.Close()
}
$Form1_Load = {

}

$ApplicationCleanup = {
	$Global:nodelocation = "SMS_ApplicationLatest"
    $Global:NameFormat = "LocalizedDisplayName"
    $Global:parentPath = 'Application'
    $Global:MasterItemFolder = "01-All Applications" 
}
$PackageCleanup = {
	$Global:nodelocation = "SMS_Package"
    $Global:NameFormat = "Name"
    $Global:parentPath = 'Package'
    $Global:MasterItemFolder = "01 - All Packages"
}

#==============================================================================================================================================================================
#==============================================================================================================================================================================
#declare variables
$ComponentName = 'RBC SMDS Cleanup Utility' #used in the cmtrace formatted log file
$logpath = [Environment]::GetFolderPath("Desktop")
$MessageBoxTitle = "RBC - SMDS MECM Cleanup Utility"
$i = 0 #counter for the progress bar steps
$numerror = 0 #counter for the number of item processing that fail
#Regular expression used to ensure dist code string only contains letters and numbers and does not exceed 6 characters
[regex]$regex = '^[a-zA-Z0-9]{4,6}$'
#MECM Connection information
#Production
$SiteCode = "PR0" # Site code
$ProviderMachineName = "SE124072.FG.RBC.com"
#SAI
#$SiteCode = "PP0" # Site code
#$ProviderMachineName = "SE132529.SAIFG.RBC.com"
#==============================================================================================================================================================================
#change directory to script location
Push-Location $PSScriptRoot
#construct the log path
#==========================================================================================================================================================================================================
$logfile = $MyInvocation.MyCommand
$logfileNoExt = [io.path]::GetFileNameWithoutExtension($logfile)
$logFile = "$logPath\$logfileNoExt.log"
#==========================================================================================================================================================================================================

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'MECM Cleanup.interface.ps1')
$Form1.ShowDialog()