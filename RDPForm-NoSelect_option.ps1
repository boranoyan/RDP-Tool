<#
***************************************
RDP Server selection script
this script read each row from serverlist.txt which can be found in same folder
If you want to Label the row start list iten with --- 
example: ---TITLE--
This will skip selection.


Bora Noyan
bora@boranoyan.com
05/12/2022
***************************************

#>




# Define the default input file path
$defaultInputFilePath = "serverlist.txt"
$data = Get-Content -Path $defaultInputFilePath



# Initialize the dictionary
$dict = @{}
$currentKey = ""
foreach ($line in $data) {
    if ($line.StartsWith("---") -and $line.EndsWith("---")) {
        # Found a new key, set it as the current key
        $currentKey = $line.Replace("-", "").Trim()
        $dict[$currentKey] = @()
    }
    elseif ($currentKey -ne "") {
        # Add the current line to the current key's list of values
        $dict[$currentKey] += $line.Trim()
    }
}



# Create the form and controls
$form = New-Object System.Windows.Forms.Form
$form.Text = "RDP TOOL"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Size = New-Object System.Drawing.Size(325, 325)


$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(300, 20)
$label.Text = "Select a key to view its values:"

$dropdown = New-Object System.Windows.Forms.ComboBox
$dropdown.Location = New-Object System.Drawing.Point(10, 30)
$dropdown.Size = New-Object System.Drawing.Size(300, 20)
$dropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList

$listbox = New-Object System.Windows.Forms.ListBox
$listbox.Location = New-Object System.Drawing.Point(10, 60)
$listbox.Size = New-Object System.Drawing.Size(300, 100)

$connectButton = New-Object System.Windows.Forms.Button
$connectButton.Location = New-Object System.Drawing.Point(10, 170)
$connectButton.Size = New-Object System.Drawing.Size(300, 30)
$connectButton.Text = "Connect"



# Add the keys to the dropdown box
foreach ($key in $dict.Keys) {
    [void]$dropdown.Items.Add($key)
}

# Define the event handler for the dropdown box
$dropdownHandler = {
    $listbox.Items.Clear()
    $selectedKey = $dropdown.SelectedItem
    foreach ($value in $dict[$selectedKey]) {
        [void]$listbox.Items.Add($value)
    }
}

$dropdown.add_SelectedIndexChanged($dropdownHandler)

# Define the event handler for the "Connect" button
$connectHandler = {
    $selectedValue = $listbox.SelectedItem
    if ($selectedValue) {
        $rdpPath = "C:\Windows\System32\mstsc.exe"
        $rdpArgs = "/v:$selectedValue"
        Start-Process $rdpPath $rdpArgs
    }
}






$connectButton.add_Click($connectHandler)

# Add the controls to the form
$form.Controls.Add($label)
$form.Controls.Add($dropdown)
$form.Controls.Add($listbox)
$form.Controls.Add($connectButton)





# Add the button to the form
$form.Controls.Add($button)

# Show the form
$form.ShowDialog() | Out-Null
