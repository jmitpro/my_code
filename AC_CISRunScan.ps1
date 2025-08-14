# Written by: John Muhar - jmuhar@allstate.ca
# Modified by: <TBD>
# Original Construction Dated: 05-31-2021
# Last Revision Date: 03-10-2022 - version 2.00. Modified the script (step 3, server OS detection) to enable supporting Server 2012 and 202 R2. Supporting XML was also modified to support server 2012 and 2012 R2

# This script resides in the CIS folder and is run from a shortcut on the ALLUSERS desktop. This script will check for the Java client and install it if necessary and then run the appropriate CIS scan and create
# a report on the ALLUSERS desktop 
#==========================================================================================================================================================================================================
#Steps
#1. Check for Admin rights
#2. Check to ensure Java is installed. If not, install it
#3. Run a CIS scan based on OS version - Member server only supported
#4. Remove the Java client

$ComponentName = 'CISScan'
$OSSupported = "NO"
$numsteps = 4
$i = 0
$Compname = $env:COMPUTERNAME
$MessageBoxTitle = "Windows Server CIS Scan"
$CISInstallDir = "$env:ProgramFiles\CIS"
$javaruntime = "$env:ProgramFiles\Java\jre1.8.0_161\bin\java.exe"
$JavaInstaller = 'jre-8u161-windows-x64.exe'
$JavaInstallLog = 'jre-8u161-windows-x64_install.log'
$JavaRemovalLog = 'jre-8u161-windows-x64_remove.log'
$JavaPackageID = '{26A24AE4-039D-4CA4-87B4-2F64180161F0}'
$SettingsXML = 'AC_CISRunScan.xml'
$MSIExecPath = "$env:SystemRoot\system32\msiexec.exe"
$CISReportPath = "$env:PUBLIC\Desktop"
$CISScanProfile = "Level 1 - Member Server"
$Server2012 = 'No'

#change directory to script location
Push-Location $PSScriptRoot
#==========================================================================================================================================================================================================

# Import the OSD Functions module
#==========================================================================================================================================================================================================
Import-Module .\_AC_Functions.psm1
#==========================================================================================================================================================================================================

#Check if script is running in a Task Sequence
Try {
	$TSEnv = New-Object -ComObject 'Microsoft.SMS.TSEnvironment' -ErrorAction Stop
    $SMSEnv = 'YES'
    #define the log folder
    $logPath = $TSEnv.Value("_SMSTSLogPath")
}
Catch {
    $SMSEnv = 'NO'
    #define the log folder
    $logpath = $env:TEMP
}

#construct the log path The $Logpath is already defined in the Task Sequence Check
#==========================================================================================================================================================================================================
$logfile = $MyInvocation.MyCommand
$logfileNoExt = [io.path]::GetFileNameWithoutExtension($logfile)
$logFile = "$logPath\$logfileNoExt.log"
#==========================================================================================================================================================================================================

#Quit if this script is not being run from a Task Sequence
#==========================================================================================================================================================================================================
If ($SMSEnv -eq 'NO') {
    	#Write-Log $logfile 'Unable to load COM Object [Microsoft.SMS.TSEnvironment]. Script is not currently running from a SCCM Task Sequence. This script cannot execute.' $ComponentName 3
        #Exit 1 
}
#==========================================================================================================================================================================================================

#==========================================================================================================================================================================================================
Function Display-Message
{
Param (
      #Display Message
      [parameter(Mandatory=$True)]
      [String]$Message,

      #Icon in messagebox
      [parameter(Mandatory=$True)]
      [String]$MessageIconType
)
	$BoxTitle = $MessageBoxTitle
	#$Message must be supplied by the ocurring error to supply details
	# Pop up a message
	Add-Type -AssemblyName PresentationCore, PresentationFramework
	$ButtonType = [System.Windows.MessageBoxButton]::Ok
	$MessageIcon = [System.Windows.MessageBoxImage]::$MessageIconType
	[System.Windows.MessageBox]::Show($Message, $BoxTitle, $ButtonType, $messageicon)
}
#==========================================================================================================================================================================================================
Function Update-ProgressBar {
    [int]$pct = ($i/$numsteps) * 100
    #update the progress bar
    $progressbar1.Value = $pct
    start-sleep -Seconds 2
}
#==========================================================================================================================================================================================================
Function Update-RunningGUI {
    #update the form
    $label1.text = $Message
    $form1.Refresh()
    start-sleep -Seconds 2
}
#==========================================================================================================================================================================================================
#draw the form
Add-Type -assembly System.Windows.Forms

#title for the winform
$Title = $MessageBoxTitle
#winform dimensions
$height = 160
$width = 520
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

#update the form
$Message = "Starting CIS scan process..."
Update-RunningGUI

#==========================================================================================================================================================================================================
#1. Detect Elevated rights
$Message = "Checking for elevated rights..."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

$CurrentUser=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$UserPrincipal=New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)
$AdminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin=$UserPrincipal.IsInRole($AdminRole)

If ($IsAdmin -eq $True) {
    $Message = "Elevated rights found, continuing..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
}
else {
    $Message = "Elevated rights NOT found."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
    $Message = "Elevated rights are required to run the CIS Scan. Please ensure that you are logged in with an account that has Administrator rights."
    Write-Log $logFile $Message $ComponentName 1
    Display-Message $Message "Error"
    $form1.Close()
    exit 1
}
$i++
Update-ProgressBar
#==========================================================================================================================================================================================================
#2 Check for existenc of Java, if not present, install it.

$Message = "Verifying instance of the Java client..."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

$Software = "Java 8 Update"
$searchresult = Get-WmiObject -class SMS_InstalledSoftware -Namespace "root\cimv2\sms" | Where-Object {$PSItem.ProductName -like "*$Software*"}

If (!($searchresult)) {
    $Message = "Java client NOT found..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
    
    #check to make sure the Java installer is in the root of the CIS folder
    $Message = "Checking for the Java Installer file $PSScriptRoot\$JavaInstaller..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
    If ((Test-Path "$PSScriptRoot\$JavaInstaller")) {
        $Message = "File $PSScriptRoot\$JavaInstaller found, starting the installation of the Java client..."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
        
        #start the java client installation
        $arguments = '/s /l ' + '"' + "$logpath\$JavaInstallLog" +'"'
        $process = Start-Process -FilePath "$PSScriptRoot\$JavaInstaller" -ArgumentList $arguments -Wait -PassThru
        $JavaExitCode = $process.ExitCode

        If ($JavaExitCode -eq 0) {
            $Message = "Successfully installed the Java client."
            Write-Log $logfile $Message $ComponentName 1
            Update-RunningGUI
        }
        else {
            $Message = "There was a problem installing the Java client. Exit code: $JavaExitCode. Check the logfile $logpath\$JavaInstallLog for details."
            Write-Log $logfile $Message $ComponentName 3
            Update-RunningGUI
            Display-Message $Message "Error"
            $form1.Close()            
            Exit 1 
        }

    }
    else {
        $Message = "File $PSScriptRoot\$JavaInstaller NOT found, the CIS scan cannot continue."
        Write-Log $logFile $Message $ComponentName 3
        Update-RunningGUI
        Display-Message $Message "Error"
        $form1.Close()
        Exit 1
    }
 
}
else {
    $Message = "Java client found, continuing CIS scan"
    Write-Log $logfile $Message $ComponentName 1
    Update-RunningGUI
}
$i++
Update-ProgressBar
#==========================================================================================================================================================================================================
#3 Run a CIS scan based on OS version - Member server only supported
$Message = "Checking prerequisites for the CIS scan..."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

#ensure this is Windows Server
$RegLocation = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
If (!(Test-Path $RegLocation)) {
    $Message = "Registry path $RegLocation NOT found. This script is exiting. The CIS scan cannot continue."
    Write-Log $logFile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()
    Exit 1
}

If (!($Winedition = Get-ItemProperty -Path $RegLocation -Name 'ProductName')) { #something is wrong, this value should exist
    $Message = "Could not find the ProductName value in $RegLocation. The CIS scan cannot continue."
    Write-Log $logFile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()
    Exit 1
}

$ServerOS = $Winedition.ProductName

If ($ServerOS -like 'Windows Server*') {
    $Message = "Windows Server found, CIS scan is continuing..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
}
else {
    $Message = "Windows Server NOT found. The CIS scan cannot continue."
    Write-Log $logFile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()
    Exit 1     
}

If ($ServerOS -like '*Server 2012*') {
    $Server2012 = 'Yes'
    $Message = "Windows Server 2012 found. The CIS scan can continue."
    Write-Log $logFile $Message $ComponentName 1
}


If ($Server2012 -eq 'No') {
    If (!($Winver = Get-ItemProperty -Path $RegLocation -Name 'ReleaseId')) { #something is wrong, this value should exist
        $Message = "Could not find the ReleaseId value in $RegLocation. The CIS scan cannot continue."
        Write-Log $logFile $Message $ComponentName 3
        Update-RunningGUI
        Display-Message $Message "Error"
        $form1.Close()
        Exit 1         
    }
    $WinRelease = $Winver.ReleaseId
    $Message = "$ServerOS release version: $WinRelease."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
}

If ($Server2012 -eq 'Yes') {
    If (!($Winver = Get-ItemProperty -Path $RegLocation -Name 'CurrentVersion')) { #something is wrong, this value should exist
        $Message = "Could not find the CurrentVersion value in $RegLocation. The CIS scan cannot continue."
        Write-Log $logFile $Message $ComponentName 3
        Update-RunningGUI
        Display-Message $Message "Error"
        $form1.Close()
        Exit 1         
    }
    $WinRelease = $Winver.CurrentVersion
    $Message = "$ServerOS release version: $WinRelease."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
}


#Make sure settings file exists
If (!(Test-Path "$PSScriptRoot\$SettingsXML"))
{
	$Message = "File $PSScriptRoot\$SettingsXML not found. Unable to load configuration settings. The CIS scan cannot continue."
    Write-Log $logfile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()
    Exit 1
}


Try {
    $Message = "Loading the CIS scan configuration file $PSScriptRoot\$SettingsXML..."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI   
    [xml]$XmlSettingsDocument = Get-Content -Path "$PSScriptRoot\$SettingsXML"
} Catch {
    $ErrorMessage = $_.Exception.Message
    $Message = "There was a problem loading the CIS scan configuration file $PSScriptRoot\$SettingsXML"
    Write-Log $logFile "$Message : $ErrorMessage" $ComponentName 3
    Update-RunningGUI
    $Message = "$Message : `r`n$ErrorMessage"
    Display-Message $Message "Error"
    $form1.Close()
    Exit 1
}

$Message = "Verifying operating system support..."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI 

#check AC_CISRunScan.xml if the Server version found is supported
$WinSrvVerList = $XmlSettingsDocument.DocumentElement.WinSrv

ForEach ($WinSrvVer in $WinSrvVerList) {
    $WinVerXML = $WinSrvVer.Version
    If ($WinverXML -eq $WinRelease) {#supported version found, get the CIS benchmark XML file name
        $OSSupported = "YES"
        $Message = "Supported Windows Server version found, getting CIS benchmark file name..."
        Write-Log $logFile $Message $ComponentName 1
        Update-RunningGUI
        $CISBenchMarkFile = $WinSrvVer.CISBenchMarkFile
        $Message = "CIS benchmark file: $CISBenchMarkFile"
        Write-Log $logfile $Message $ComponentName 1
        Update-RunningGUI
    }
}
If ($OSSupported -eq "NO") {
    $Message = "No supported operating system found. The CIS scan cannot continue."
    Write-Log $logFile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()
    Exit 1
}
#start the scan and create a report
#CIS scan arguments
$Message = "Running the CIS Scan. This will take a while...."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

$CISArgs = "-jar CISCAT.jar -b /Benchmarks/$CISBenchMarkFile -p " + '"' + $CISScanProfile + '"' + " -r $CISReportPath" + " -rn  $Compname" + " -a"
#change working folder\
Push-Location $CISInstallDir
$process = Start-Process -FilePath "$javaruntime" -ArgumentList $CISArgs -Wait -PassThru -WindowStyle Hidden

$CISScanExitCode = $process.ExitCode
If ($CISScanExitCode -eq 0) {
    $Message = "Successfully completed the CIS Scan. Scan results are located on your desktop, file name: $Compname.html "
    Write-Log $logfile $Message $ComponentName 1
    Update-RunningGUI
}
else {
    $Message = "There was a problem running the CIS scan. Exit code: $CISScanExitCode."
    Write-Log $logfile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()            
    Exit 1 
}

#check for finished report file
If (Test-Path "$CISReportPath\$Compname.html")
{
	$Message = "CIS scan results report file: $CISReportPath\$Compname.html"
    Write-Log $logfile $Message $ComponentName 1
    Update-RunningGUI
 }
 else {
    $Message = "Unable to find CIS scan results report file $CISReportPath\$Compname.html. There was a problem running the CIS scan."
    Write-Log $logfile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()            
    Exit 1 
 }
$i++
Update-ProgressBar
#==========================================================================================================================================================================================================
#4 Remove the Java client
$Message = "Removing the Java client..."
Write-Log $logFile $Message $ComponentName 1
Update-RunningGUI

$Software = "Java 8 Update"

$searchresult = Get-WmiObject -class SMS_InstalledSoftware -Namespace "root\cimv2\sms" | Where-Object {$PSItem.ProductName -like "*$Software*"}
If ($searchresult) {
    #start the java removal
    $arguments = '/X' + $JavaPackageID + " /l " + '"' + "$logpath\$JavaRemovalLog" +'"' + " /qn"
    $process = Start-Process -FilePath "$MSIExecPath" -ArgumentList $arguments -Wait -PassThru
    $JavaExitCode = $process.ExitCode
}
If ($JavaExitCode -eq 0) {#removal was successful
    $Message = "The Java Client was successfuly removed."
    Write-Log $logFile $Message $ComponentName 1
    Update-RunningGUI
}
else {
    $Message = "There was an error removing the Java Client. Exit code: $JavaExitCode. Check log file $logpath\$JavaRemovalLog for details."
    Write-Log $logFile $Message $ComponentName 3
    Update-RunningGUI
    Display-Message $Message "Error"
    $form1.Close()            
    Exit 1 
}
$i++
Update-ProgressBar

$Message = "1.) Completed the CIS scan. `r`n2.) Removed the Java Client. `r`n3.) CIS Report $CISReportPath\$Compname.html ready for review."
Display-Message $Message "Asterisk"

#launch the report for viewing
If (Test-Path -Path "$CISReportPath\$Compname.html") {
    Invoke-Item "$CISReportPath\$Compname.html"
}
#==========================================================================================================================================================================================================
$form1.Close()
exit


$env:SystemRoot