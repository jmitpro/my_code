$Form1 = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.GroupBox]$GroupBox1 = $null
[System.Windows.Forms.Button]$Button2 = $null
[System.Windows.Forms.Button]$Button1 = $null
[System.Windows.Forms.RadioButton]$RadioButton2 = $null
[System.Windows.Forms.RadioButton]$RadioButton1 = $null
[System.Windows.Forms.ProgressBar]$ProgressBar1 = $null
[System.Windows.Forms.GroupBox]$GroupBox2 = $null
[System.Windows.Forms.TextBox]$TextBox1 = $null
function InitializeComponent
{
$GroupBox1 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$Button2 = (New-Object -TypeName System.Windows.Forms.Button)
$Button1 = (New-Object -TypeName System.Windows.Forms.Button)
$RadioButton2 = (New-Object -TypeName System.Windows.Forms.RadioButton)
$RadioButton1 = (New-Object -TypeName System.Windows.Forms.RadioButton)
$ProgressBar1 = (New-Object -TypeName System.Windows.Forms.ProgressBar)
$GroupBox2 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$TextBox1 = (New-Object -TypeName System.Windows.Forms.TextBox)
$GroupBox1.SuspendLayout()
$GroupBox2.SuspendLayout()
$Form1.SuspendLayout()
#
#GroupBox1
#
$GroupBox1.Controls.Add($Button2)
$GroupBox1.Controls.Add($Button1)
$GroupBox1.Controls.Add($RadioButton2)
$GroupBox1.Controls.Add($RadioButton1)
$GroupBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]23,[System.Int32]12))
$GroupBox1.Name = [System.String]'GroupBox1'
$GroupBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]785,[System.Int32]84))
$GroupBox1.TabIndex = [System.Int32]0
$GroupBox1.TabStop = $false
$GroupBox1.Text = [System.String]'MECM Cleanup Options'
#
#Button2
#
$Button2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]657,[System.Int32]26))
$Button2.Name = [System.String]'Button2'
$Button2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]68,[System.Int32]33))
$Button2.TabIndex = [System.Int32]3
$Button2.Text = [System.String]'Close'
$Button2.UseVisualStyleBackColor = $true
$Button2.add_Click($Button2_Click)
#
#Button1
#
$Button1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]566,[System.Int32]26))
$Button1.Name = [System.String]'Button1'
$Button1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]68,[System.Int32]33))
$Button1.TabIndex = [System.Int32]2
$Button1.Text = [System.String]'Start'
$Button1.UseVisualStyleBackColor = $true
$Button1.add_Click($Button1_Click)
#
#RadioButton2
#
$RadioButton2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]361,[System.Int32]20))
$RadioButton2.Name = [System.String]'RadioButton2'
$RadioButton2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]181,[System.Int32]44))
$RadioButton2.TabIndex = [System.Int32]1
$RadioButton2.TabStop = $true
$RadioButton2.Text = [System.String]'Cleanup Root Packages'
$RadioButton2.UseVisualStyleBackColor = $true
$RadioButton2.add_Click($PackageCleanup)
#
#RadioButton1
#
$RadioButton1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]31,[System.Int32]20))
$RadioButton1.Name = [System.String]'RadioButton1'
$RadioButton1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]179,[System.Int32]44))
$RadioButton1.TabIndex = [System.Int32]0
$RadioButton1.TabStop = $true
$RadioButton1.Text = [System.String]'Cleanup Root Applications'
$RadioButton1.UseVisualStyleBackColor = $true
$RadioButton1.add_Click($ApplicationCleanup)
#
#ProgressBar1
#
$ProgressBar1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]18,[System.Int32]57))
$ProgressBar1.Name = [System.String]'ProgressBar1'
$ProgressBar1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]747,[System.Int32]29))
$ProgressBar1.TabIndex = [System.Int32]1
#
#GroupBox2
#
$GroupBox2.Controls.Add($TextBox1)
$GroupBox2.Controls.Add($ProgressBar1)
$GroupBox2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]23,[System.Int32]102))
$GroupBox2.Name = [System.String]'GroupBox2'
$GroupBox2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]785,[System.Int32]103))
$GroupBox2.TabIndex = [System.Int32]3
$GroupBox2.TabStop = $false
$GroupBox2.Text = [System.String]'Status'
#
#TextBox1
#
$TextBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]18,[System.Int32]20))
$TextBox1.Name = [System.String]'TextBox1'
$TextBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]747,[System.Int32]21))
$TextBox1.TabIndex = [System.Int32]2
$TextBox1.ReadOnly = $true
#
#Form1
#
$Form1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]831,[System.Int32]223))
$Form1.Controls.Add($GroupBox2)
$Form1.Controls.Add($GroupBox1)
$Form1.ForeColor = [System.Drawing.Color]::Black
$Form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Form1.Text = [System.String]'RBC - SMDS MECM Cleanup Utility'
$Form1.add_Load($Form1_Load)
$GroupBox1.ResumeLayout($false)
$GroupBox2.ResumeLayout($false)
$GroupBox2.PerformLayout()
$Form1.ResumeLayout($false)
Add-Member -InputObject $Form1 -Name GroupBox1 -Value $GroupBox1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button2 -Value $Button2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button1 -Value $Button1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name RadioButton2 -Value $RadioButton2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name RadioButton1 -Value $RadioButton1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name ProgressBar1 -Value $ProgressBar1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox2 -Value $GroupBox2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name TextBox1 -Value $TextBox1 -MemberType NoteProperty
}
. InitializeComponent
