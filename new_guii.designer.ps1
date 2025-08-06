$Form1 = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.GroupBox]$GroupBox1 = $null
[System.Windows.Forms.TextBox]$TextBox1 = $null
[System.Windows.Forms.Button]$Button1 = $null
[System.Windows.Forms.GroupBox]$GroupBox2 = $null
[System.Windows.Forms.ListBox]$ListBox1 = $null
[System.Windows.Forms.Button]$Button2 = $null
[System.Windows.Forms.GroupBox]$GroupBox3 = $null
[System.Windows.Forms.ProgressBar]$ProgressBar1 = $null
[System.Windows.Forms.TextBox]$TextBox2 = $null
[System.Windows.Forms.Button]$Button3 = $null
[System.Windows.Forms.Button]$Button4 = $null
function InitializeComponent
{
$GroupBox1 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$TextBox1 = (New-Object -TypeName System.Windows.Forms.TextBox)
$Button1 = (New-Object -TypeName System.Windows.Forms.Button)
$GroupBox2 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$ListBox1 = (New-Object -TypeName System.Windows.Forms.ListBox)
$Button2 = (New-Object -TypeName System.Windows.Forms.Button)
$GroupBox3 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$TextBox2 = (New-Object -TypeName System.Windows.Forms.TextBox)
$ProgressBar1 = (New-Object -TypeName System.Windows.Forms.ProgressBar)
$Button3 = (New-Object -TypeName System.Windows.Forms.Button)
$Button4 = (New-Object -TypeName System.Windows.Forms.Button)
$GroupBox1.SuspendLayout()
$GroupBox2.SuspendLayout()
$GroupBox3.SuspendLayout()
$Form1.SuspendLayout()
#
#GroupBox1
#
$GroupBox1.Controls.Add($TextBox1)
$GroupBox1.Controls.Add($Button1)
$GroupBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]26,[System.Int32]12))
$GroupBox1.Name = [System.String]'GroupBox1'
$GroupBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]205,[System.Int32]75))
$GroupBox1.TabIndex = [System.Int32]0
$GroupBox1.TabStop = $false
$GroupBox1.Text = [System.String]'Enter Distribution Code:'
#
#TextBox1
#
$TextBox1.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]11.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$TextBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]87,[System.Int32]30))
$TextBox1.Name = [System.String]'TextBox1'
$TextBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]26))
$TextBox1.TabIndex = [System.Int32]1
#
#Button1
#
$Button1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]30))
$Button1.Name = [System.String]'Button1'
$Button1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
$Button1.TabIndex = [System.Int32]0
$Button1.Text = [System.String]'Search'
$Button1.UseVisualStyleBackColor = $true
$Button1.add_Click($Button1_Click)
#
#GroupBox2
#
$GroupBox2.Controls.Add($ListBox1)
$GroupBox2.Controls.Add($Button2)
$GroupBox2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]250,[System.Int32]12))
$GroupBox2.Name = [System.String]'GroupBox2'
$GroupBox2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]525,[System.Int32]75))
$GroupBox2.TabIndex = [System.Int32]1
$GroupBox2.TabStop = $false
$GroupBox2.Text = [System.String]'Select Application To Import:'
#
#ListBox1
#
$ListBox1.FormattingEnabled = $true
$ListBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]87,[System.Int32]30))
$ListBox1.Name = [System.String]'ListBox1'
$ListBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]422,[System.Int32]30))
$ListBox1.TabIndex = [System.Int32]2
#
#Button2
#
$Button2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]30))
$Button2.Name = [System.String]'Button2'
$Button2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
$Button2.TabIndex = [System.Int32]0
$Button2.Text = [System.String]'Import'
$Button2.UseVisualStyleBackColor = $true
$Button2.add_Click($Button2_Click)
#
#GroupBox3
#
$GroupBox3.Controls.Add($ProgressBar1)
$GroupBox3.Controls.Add($TextBox2)
$GroupBox3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]26,[System.Int32]103))
$GroupBox3.Name = [System.String]'GroupBox3'
$GroupBox3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]749,[System.Int32]90))
$GroupBox3.TabIndex = [System.Int32]2
$GroupBox3.TabStop = $false
$GroupBox3.Text = [System.String]'Status'
#
#TextBox2
#
$TextBox2.Enabled = $false
$TextBox2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]20))
$TextBox2.Name = [System.String]'TextBox2'
$TextBox2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]727,[System.Int32]21))
$TextBox2.TabIndex = [System.Int32]0
#
#ProgressBar1
#
$ProgressBar1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]58))
$ProgressBar1.Name = [System.String]'ProgressBar1'
$ProgressBar1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]727,[System.Int32]23))
$ProgressBar1.TabIndex = [System.Int32]1
#
#Button3
#
$Button3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]290,[System.Int32]216))
$Button3.Name = [System.String]'Button3'
$Button3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]70,[System.Int32]25))
$Button3.TabIndex = [System.Int32]3
$Button3.Text = [System.String]'Reset'
$Button3.UseVisualStyleBackColor = $true
#
#Button4
#
$Button4.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Button4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]386,[System.Int32]216))
$Button4.Name = [System.String]'Button4'
$Button4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$Button4.TabIndex = [System.Int32]4
$Button4.Text = [System.String]'Close'
$Button4.UseVisualStyleBackColor = $true
$Button4.add_Click($Button4_Click)
#
#Form1
#
$Form1.CancelButton = $Button4
$Form1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]798,[System.Int32]254))
$Form1.Controls.Add($Button4)
$Form1.Controls.Add($Button3)
$Form1.Controls.Add($GroupBox3)
$Form1.Controls.Add($GroupBox2)
$Form1.Controls.Add($GroupBox1)
$Form1.MaximizeBox = $false
$Form1.MaximumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]814,[System.Int32]293))
$Form1.MinimizeBox = $false
$Form1.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]814,[System.Int32]293))
$Form1.SizeGripStyle = [System.Windows.Forms.SizeGripStyle]::Hide
$Form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Form1.Text = [System.String]'RBC - SMDS Import Application Utility'
$GroupBox1.ResumeLayout($false)
$GroupBox1.PerformLayout()
$GroupBox2.ResumeLayout($false)
$GroupBox3.ResumeLayout($false)
$GroupBox3.PerformLayout()
$Form1.ResumeLayout($false)
Add-Member -InputObject $Form1 -Name GroupBox1 -Value $GroupBox1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name TextBox1 -Value $TextBox1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button1 -Value $Button1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox2 -Value $GroupBox2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name ListBox1 -Value $ListBox1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button2 -Value $Button2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox3 -Value $GroupBox3 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name ProgressBar1 -Value $ProgressBar1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name TextBox2 -Value $TextBox2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button3 -Value $Button3 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button4 -Value $Button4 -MemberType NoteProperty
}
. InitializeComponent
