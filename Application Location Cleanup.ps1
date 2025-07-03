# Written by: John Muhar for RBC- john.muhar@rbc.com
# Script Purpose: This script will ingest a text file containing the names of all the applications located in the root of Applications in MECM.
                # Based on the naming convention (RBC Dist code at the beginning of the application name as well as application version), a folder structure will be created as the destination
                # for the application move. The applications will then be moved to their appropriate folder.
#
# Original Construction Date: v1.0 - 06-30-2025
# Modified by: John Muhar for RBC- john.muhar@rbc.com
# Revision Date: vX.X - MM-DD-YYYY - Modifications -

#==============================================================================================================================================================================
#declare variables
$ComponentName = 'RBC Application Location Cleanup' #used in the cmtrace formatted log file
$logpath = [Environment]::GetFolderPath("Desktop")
$MessageBoxTitle = "RBC Application Cleanup"
$AppListFile = 'Application_List.txt'
$i = 0 #counter for the progress bar steps
$numerror = 0 #counter for the number of application processing tha fail
#Regular expression used to ensure dist code string only contains letters and numbers and does not exceed 5 characters
[regex]$regex = '^[a-zA-Z0-9]{0,5}$'
#MECM Connection information
$SiteCode = "PS1" # Site code
$ProviderMachineName = "CM01.corp.viamonstra.com"
#Top level Application path folders
$parentPath = 'Application'
$MasterAppFolder = "01 - All Applications"

#change directory to script location
Push-Location $PSScriptRoot

#==============================================================================================================================================================================
# Import the Functions module
#==============================================================================================================================================================================
Import-Module .\_RBC_Functions.psm1
#==============================================================================================================================================================================

#construct the log path
#==========================================================================================================================================================================================================
$logfile = $MyInvocation.MyCommand
$logfileNoExt = [io.path]::GetFileNameWithoutExtension($logfile)
$logFile = "$logPath\$logfileNoExt.log"
#=======================================================================================================================================================================================================

#Start script
#==========================================================================================================================================================================================================
#Functions
#==============================================================================================================================================================================
#==============================================================================================================================================================================

Function Update-RunningGUI {
    #update the form
    $label1.text = $Message
    $form1.Refresh()
    start-sleep -Seconds 2
}

Function Update-ProgressBar {
    [int]$pct = ($i/$numapps) * 100
    #update the progress bar
    $progressbar1.Value = $pct
    start-sleep -Seconds 2
}

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

#draw the form
Add-Type -assembly System.Windows.Forms

#title for the winform
$Title = $MessageBoxTitle
#winform dimensions
$height = 160
$width = 720
#winform background color
$color = "White"

#create the form
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = $title
$form1.Height = $height
$form1.Width = $width
$form1.BackColor = $color

$form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
#display center screen
$form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# create label
$label1 = New-Object system.Windows.Forms.Label
$label1.Text = "not started"
$label1.Left = 15
$label1.Top = 10
$label1.Width = $width - 20
#adjusted height to accommodate progress bar
$label1.Height = 40
$label1.Font = "Verdana"
#optional to show border 
#$label1.BorderStyle=1

#add the label to the form
$form1.controls.add($label1)

$progressBar1 = New-Object System.Windows.Forms.ProgressBar
$progressBar1.Name = 'progressBar1'
$progressBar1.Value = 0
$progressBar1.Style = "Continuous"

$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = $width - 40
$System_Drawing_Size.Height = 20
$progressBar1.Size = $System_Drawing_Size

$progressBar1.Left = 15
$progressBar1.Top = 60

$form1.Controls.Add($progressBar1)

$form1.Show() | out-null

#give the form focus
$form1.Focus() | out-null

#==============================================================================================================================================================================
#==============================================================================================================================================================================
$Message = "Starting Application Cleanup..."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

#Check for MECM console and module
If (Test-Path Env:PSModulePath) {
    $Message = "PSModule path found.Checking for MECM console path..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
    If ((Get-Item Env:PSModulePath).Value -like "*Configuration Manager*") {
        $Message = "MECM console path found. Loading the PowerShell Configuration Manager module..."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
    }
    else {
        $Message = "MECM console path NOT found. This utility is aborting."
        Write-Log $logFile $Message $ComponentName 3
        Display-Message $Message "Error"
        $form1.Close()
        Exit 1
    }
}
else {
    $Message = "The PSModulePath environment variable does NOT exist. This utility is aborting."
    Write-Log $logFile $Message $ComponentName 3
    Display-Message $Message "Error"
    $form1.Close()
    Exit 1
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
    Exit 1
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
        Exit 1
    }
}
else {
    $Message = "Already connected to the MECM site drive..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
}

#Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

#check for existence of application list file
If ((Test-Path "$PSScriptRoot\$AppListFile")) {
    $Message = "File $PSScriptRoot\$AppListFile found. Continuing... "
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
}
else {
    $Message = "File $PSScriptRoot\$AppListFile NOT found. This utility is aborting."
    Write-Log $logFile $Message $ComponentName 3
    Display-Message $Message "Error"
    $form1.Close()
    Open-LogFile
    Exit 1
}
#load application list file
$Message = "Loading application list to process..."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI
$applist = Get-Content -Path $PSScriptRoot\$AppListFile
$Message = "Successfully loaded application list."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

#get the number of applications in list
$numapps = $applist.Count
$Message = "Found $numapps applications(s) to process."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI


Foreach ($app in $applist){
    Write-Log $logFile '*****************************************************************************************************************************' $ComponentName 1
    Write-Log $logFile '*****************************************************************************************************************************' $ComponentName 1
    #for each iteration reset variable ErrorFound to 'NO'
    $ErrorFound = 'NO'
    $Message = "Processing $app..."
    Write-Log $logFile $Message $ComponentName 1
    #parse all characters up to the first dash(-) and strip out any spaces
    $distcode = ($app.Split("-")[0]).Trim()

    #test the string against the regular expression as defined at the top of this script
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
        $Message = "Distribution code $distcode format is NOT valid. Skipping folder creation and application move..."
        Write-Log $logFile $Message $ComponentName 3
        Update-RunningGUI
    }
    If ($ErrorFound -eq 'NO') {
        #Get application version to set the version folder name
        $appverfolder ="v" + (Get-CMApplication -Name $app).softwareversion
        $Message = "Application version folder is $appverfolder"
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
    }
    #create folders
    If ($ErrorFound -eq 'NO') {
        $FolderVarList = @(
            [pscustomobject]@{Folder = "$ParentDistCode"; FolderPath="$parentPath\$MasterAppFolder"}
            [pscustomobject]@{Folder = "$distcode"; FolderPath="$parentPath\$MasterAppFolder\$ParentDistCode"}
            [pscustomobject]@{Folder = "$appverfolder"; FolderPath="$parentPath\$MasterAppFolder\$ParentDistCode\$distcode"}
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
                    $Message = "Failed creating folder $folderpath\$folder. Skipping application move. Error: $($_.Exception.Message)"
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
            $MoveLocation = "$SiteCode" + ":\" + "$parentPath\$MasterAppFolder\$ParentDistCode\$distcode\$appverfolder"
            $Message = "Moving $app to $MoveLocation"
            Write-Log $logFile $Message $ComponentName 1
            Update-RunningGUI
            Try {
                $AppObject = Get-CMApplication -Name "$app" -ErrorAction Stop
                Move-CMObject -FolderPath "$MoveLocation" -InputObject $AppObject -ErrorAction Stop
                $Message = "Successfully moved $app to $MoveLocation"
                Write-Log $logFile $Message $ComponentName 1
                Update-RunningGUI
            }
            Catch [System.Exception] {
                $Message = "Failed to move $app to $MoveLocation. Error: $($_.Exception.Message)"
                Write-Log $logFile $Message $ComponentName 1
                Update-RunningGUI
                $ErrorFound = 'YES'
                $numerror++
            }
        }

    }
    $i++ #iterate the application counter list for progress bar update
    Update-ProgressBar
}
$Message = "Finished processing all applications in list"
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

#Check to see if any errors occurred, if so try and open the log file with cmtrace, or notepad if cmtrace not found
If ($numerror -eq 0) { #no errors found
    $Message = "All applications were successfully moved with no errors."
    $form1.Close()
    Write-Log $logFile $Message $ComponentName 1    
    Update-RunningGUI
    $form1.Close()
    Display-Message $Message "Information"
    Exit 0

}
else {
    $Message = "There were $numerror error(s) found. Check log file for details."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
    $form1.Close()
    Display-Message $Message "Error"
    Open-LogFile
    Exit 1
}
