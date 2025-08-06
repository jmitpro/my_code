$Button4_Click = {
}
$Button3_Click = {
}
$Button2_Click = {
}
$Button1_Click = {
}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'new_guii.designer.ps1')
$Form1.ShowDialog()