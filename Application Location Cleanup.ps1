$app = "bba1z - hkhkhhkjh.v2.4.56"


#[regex]$regex = '(^[a-zA-Z0-9]*$)'

[regex]$regex = '^[a-zA-Z0-9]{0,5}$'

$distcode = ($app.Split("-")[0]).Trim()

$message = "'" + $distcode + "'"

Write-Host $message

If ($distcode -match $regex){
    Write-Host "Dist code format is good"

}
else {
    Write-Host "Dist code format is NOT good"
}

#change directory to script location
Push-Location $PSScriptRoot

$ComponentName = 'CISScan'
$OSSupported = "NO"
$numsteps = 4
$i = 0
$Compname = $env:COMPUTERNAME
$MessageBoxTitle = "Windows Server CIS Scan"

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
	#$Message must be supplied by the ocurring error to supply details
	# Pop up a message
	Add-Type -AssemblyName PresentationCore, PresentationFramework
	$ButtonType = [System.Windows.MessageBoxButton]::Ok
	$MessageIcon = [System.Windows.MessageBoxImage]::$MessageIconType
	[System.Windows.MessageBox]::Show($Message, $BoxTitle, $ButtonType, $messageicon)
}


Function Update-RunningGUI {
    #update the form
    $label1.text = $Message
    $form1.Refresh()
    start-sleep -Seconds 2
}

Function Update-ProgressBar {
    [int]$pct = ($i/$numsteps) * 100
    #update the progress bar
    $progressbar1.Value = $pct
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

