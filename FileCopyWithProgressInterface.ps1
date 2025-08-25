
$SourcePath = "D:\Temp\ApplicationSource\AA\AACDD\V3.1234\Desktop\*.*"
$DestinationPath = "L:\ApplicationSource\AA\AACDD\V3.1234\Desktop"

$FOF_CREATEPROGRESSDLG = "&H0&"

$objShell = New-Object -ComObject "Shell.Application"

$objFolder = $objShell.NameSpace($DestinationPath) 

$objFolder.CopyHere($SourcePath, $FOF_CREATEPROGRESSDLG)
