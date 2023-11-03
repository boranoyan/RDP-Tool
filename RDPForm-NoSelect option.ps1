# Load the XML file
$xmlFile = "serverlist.xml"
[xml]$xmlData = Get-Content -Path $xmlFile

# Initialize the dictionary
$dict = @{}

# Create the main form and controls
$form = New-Object System.Windows.Forms.Form
$form.Text = "RDP TOOL"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Size = New-Object System.Drawing.Size(400, 400)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(300, 20)
$label.Text = "Select a key to view its values:"

$dropdown = New-Object System.Windows.Forms.ComboBox
$dropdown.Location = New-Object System.Drawing.Point(10, 30)
$dropdown.Size = New-Object System.Drawing.Size(300, 20)
$dropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList

$descriptionLabel = New-Object System.Windows.Forms.Label
$descriptionLabel.Location = New-Object System.Drawing.Point(10, 60)
$descriptionLabel.Size = New-Object System.Drawing.Size(300, 50)

$listbox = New-Object System.Windows.Forms.ListBox
$listbox.Location = New-Object System.Drawing.Point(10, 110)
$listbox.Size = New-Object System.Drawing.Size(300, 100)

$connectButton = New-Object System.Windows.Forms.Button
$connectButton.Location = New-Object System.Drawing.Point(10, 220)
$connectButton.Size = New-Object System.Drawing.Size(300, 30)
$connectButton.Text = "Connect"

$tasksButton = New-Object System.Windows.Forms.Button
$tasksButton.Location = New-Object System.Drawing.Point(10, 260)
$tasksButton.Size = New-Object System.Drawing.Size(300, 30)
$tasksButton.Text = "Tasks"

# ... (previous code remains the same)

# Add the servers and tasks to the dropdown box and dictionary
foreach ($server in $xmlData.ServerList.Server) {
    $category = $server.category
    $serverName = $server.Name
    $serverDescription = $server.Description

    if (-not $dict[$category]) {
        $dict[$category] = @()
        [void]$dropdown.Items.Add($category)
    }

    $serverTasks = $server.Tasks.Task | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name
            Status = $_.Status
            CompletedDate = $_.CompletedDate
        }
    }

    # Convert the tasks array to a List
    $tasksList = [System.Collections.Generic.List[PSObject]]$serverTasks

    $dict[$category] += [PSCustomObject]@{
        Name = $serverName
        Description = $serverDescription
        Tasks = $tasksList
    }
}

# ... (rest of the code remains the same)


# Define the event handler for the dropdown box
$dropdownHandler = {
    $listbox.Items.Clear()
    $descriptionLabel.Text = ""

    $selectedKey = $dropdown.SelectedItem

    if ($selectedKey) {
        $selectedServers = $dict[$selectedKey]
        foreach ($server in $selectedServers) {
            [void]$listbox.Items.Add($server.Name)
        }
    }
}

$dropdown.add_SelectedIndexChanged($dropdownHandler)

# Define the event handler for the "Connect" button
$connectHandler = {
    $selectedServerIndex = $listbox.SelectedIndex
    if ($selectedServerIndex -ge 0) {
        $selectedKey = $dropdown.SelectedItem
        $selectedServer = $dict[$selectedKey][$selectedServerIndex]
        $rdpPath = "C:\Windows\System32\mstsc.exe"
        $rdpArgs = "/v:" + $selectedServer.Name
        Start-Process $rdpPath $rdpArgs
    }
}

$connectButton.add_Click($connectHandler)

# Define the event handler for updating the description label
$listboxHandler = {
    $selectedServerIndex = $listbox.SelectedIndex

    if ($selectedServerIndex -ge 0) {
        $selectedKey = $dropdown.SelectedItem
        $selectedServer = $dict[$selectedKey][$selectedServerIndex]
        $descriptionLabel.Text = $selectedServer.Description
    }
}

$listbox.add_SelectedIndexChanged($listboxHandler)

# ... (previous code remains the same)

# Define the event handler for the "Tasks" button
$tasksButtonHandler = {
    $selectedServerIndex = $listbox.SelectedIndex

    if ($selectedServerIndex -ge 0) {
        $selectedKey = $dropdown.SelectedItem
        $selectedServer = $dict[$selectedKey][$selectedServerIndex]

        # Create and display the "Tasks" form
        $tasksForm = New-Object System.Windows.Forms.Form
        $tasksForm.Text = "Tasks for $($selectedServer.Name)"
        $tasksForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        $tasksForm.MaximizeBox = $false
        $tasksForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        $tasksForm.Size = New-Object System.Drawing.Size(400, 400)

        $tasksLabel = New-Object System.Windows.Forms.Label
        $tasksLabel.Location = New-Object System.Drawing.Point(10, 10)
        $tasksLabel.Size = New-Object System.Drawing.Size(300, 20)
        $tasksLabel.Text = "Tasks for $($selectedServer.Name)"

        $tasksListbox = New-Object System.Windows.Forms.ListBox
        $tasksListbox.Location = New-Object System.Drawing.Point(10, 30)
        $tasksListbox.Size = New-Object System.Drawing.Size(300, 200)

        $editButton = New-Object System.Windows.Forms.Button
        $editButton.Location = New-Object System.Drawing.Point(10, 240)
        $editButton.Size = New-Object System.Drawing.Size(100, 30)
        $editButton.Text = "Edit Task"
        $editButton.Enabled = $false

        $newTaskButton = New-Object System.Windows.Forms.Button
        $newTaskButton.Location = New-Object System.Drawing.Point(120, 240)
        $newTaskButton.Size = New-Object System.Drawing.Size(100, 30)
        $newTaskButton.Text = "New Task"

        $deleteButton = New-Object System.Windows.Forms.Button
        $deleteButton.Location = New-Object System.Drawing.Point(230, 240)
        $deleteButton.Size = New-Object System.Drawing.Size(100, 30)
        $deleteButton.Text = "Delete Task"
        $deleteButton.Enabled = $false

        # Add tasks to the tasks listbox
        foreach ($task in $selectedServer.Tasks) {
            $taskStatus = $task.Status
            $taskName = $task.Name
            $completedDate = $task.CompletedDate

            $taskText = "$taskName - $taskStatus"
            if ($taskStatus -eq "Completed" -and $completedDate) {
                $taskText += " (Completed on $completedDate)"
            }

            [void]$tasksListbox.Items.Add($taskText)
        }

        $tasksListbox.add_SelectedIndexChanged({
            $editButton.Enabled = $tasksListbox.SelectedIndex -ge 0
            $deleteButton.Enabled = $tasksListbox.SelectedIndex -ge 0
        })

        # Event handler for the "Edit Task" button
        $editButton.add_Click({
            $selectedIndex = $tasksListbox.SelectedIndex
            if ($selectedIndex -ge 0) {
                $taskToEdit = $selectedServer.Tasks[$selectedIndex]
                $editedTask = ShowTaskDialog -Title "Edit Task" -Task $taskToEdit
                if ($editedTask) {
                    $selectedServer.Tasks[$selectedIndex] = $editedTask
                    UpdateTasksListbox
                }
            }
        })

       # Event handler for the "New Task" button
$newTaskButton.add_Click({
    $newTask = ShowTaskDialog -Title "New Task"
    if ($newTask) {
        $selectedServer.Tasks.Add($newTask)
        UpdateTasksListbox
        SaveXmlData
    }
})


# Function to update the tasks listbox
function UpdateTasksListbox() {
    $tasksListbox.Items.Clear()
    foreach ($task in $selectedServer.Tasks) {
        $taskStatus = $task.Status
        $taskName = $task.Name
        $completedDate = $task.CompletedDate

        $taskText = "$taskName - $taskStatus"
        if ($taskStatus -eq "Completed" -and $completedDate) {
            $taskText += " (Completed on $completedDate)"
        }

        [void]$tasksListbox.Items.Add($taskText)
    }
}


        # Event handler for the "Delete Task" button
$deleteButton.add_Click({
    $selectedIndex = $tasksListbox.SelectedIndex
    if ($selectedIndex -ge 0) {
        $selectedServer.Tasks.RemoveAt($selectedIndex)
        UpdateTasksListbox
        SaveXmlData
    }
})

function SaveXmlData {
    $xmlData.Save($xmlFile)
}


        # Function to display task dialog for editing and adding new tasks
        function ShowTaskDialog([string]$Title, [PSCustomObject]$Task = $null) {
            $taskForm = New-Object System.Windows.Forms.Form
            $taskForm.Text = $Title
            $taskForm.Size = New-Object System.Drawing.Size(300, 200)

            $taskNameLabel = New-Object System.Windows.Forms.Label
            $taskNameLabel.Location = New-Object System.Drawing.Point(10, 10)
            $taskNameLabel.Size = New-Object System.Drawing.Size(100, 20)
            $taskNameLabel.Text = "Task Name:"

            $taskNameTextBox = New-Object System.Windows.Forms.TextBox
            $taskNameTextBox.Location = New-Object System.Drawing.Point(120, 10)
            $taskNameTextBox.Size = New-Object System.Drawing.Size(150, 20)
            if ($Task) { $taskNameTextBox.Text = $Task.Name }

            $taskStatusLabel = New-Object System.Windows.Forms.Label
            $taskStatusLabel.Location = New-Object System.Drawing.Point(10, 40)
            $taskStatusLabel.Size = New-Object System.Drawing.Size(100, 20)
            $taskStatusLabel.Text = "Status:"

            $taskStatusComboBox = New-Object System.Windows.Forms.ComboBox
            $taskStatusComboBox.Location = New-Object System.Drawing.Point(120, 40)
            $taskStatusComboBox.Size = New-Object System.Drawing.Size(150, 20)
            $taskStatusComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
            $taskStatusComboBox.Items.Add("Active")
            $taskStatusComboBox.Items.Add("Completed")
            if ($Task) { $taskStatusComboBox.SelectedItem = $Task.Status }

            $completedDateLabel = New-Object System.Windows.Forms.Label
            $completedDateLabel.Location = New-Object System.Drawing.Point(10, 70)
            $completedDateLabel.Size = New-Object System.Drawing.Size(100, 20)
            $completedDateLabel.Text = "Completed Date:"

            $completedDateTextBox = New-Object System.Windows.Forms.TextBox
            $completedDateTextBox.Location = New-Object System.Drawing.Point(120, 70)
            $completedDateTextBox.Size = New-Object System.Drawing.Size(150, 20)
            if ($Task) { $completedDateTextBox.Text = $Task.CompletedDate }

            $okButton = New-Object System.Windows.Forms.Button
            $okButton.Location = New-Object System.Drawing.Point(10, 100)
            $okButton.Size = New-Object System.Drawing.Size(100, 30)
            $okButton.Text = "OK"

            $cancelButton = New-Object System.Windows.Forms.Button
            $cancelButton.Location = New-Object System.Drawing.Point(120, 100)
            $cancelButton.Size = New-Object System.Drawing.Size(100, 30)
            $cancelButton.Text = "Cancel"

            $okButton.add_Click({
                $taskName = $taskNameTextBox.Text
                $taskStatus = $taskStatusComboBox.SelectedItem
                $completedDate = $completedDateTextBox.Text

                if (-not [string]::IsNullOrWhiteSpace($taskName)) {
                    $taskData = @{
                        Name = $taskName
                        Status = $taskStatus
                        CompletedDate = $completedDate
                    }

                    $taskForm.Tag = New-Object PSObject -Property $taskData
                    $taskForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Task Name is required.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            })

            $cancelButton.add_Click({
                $taskForm.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            })

            $taskForm.Controls.Add($taskNameLabel)
            $taskForm.Controls.Add($taskNameTextBox)
            $taskForm.Controls.Add($taskStatusLabel)
            $taskForm.Controls.Add($taskStatusComboBox)
            $taskForm.Controls.Add($completedDateLabel)
            $taskForm.Controls.Add($completedDateTextBox)
            $taskForm.Controls.Add($okButton)
            $taskForm.Controls.Add($cancelButton)

            $result = $taskForm.ShowDialog()
            if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                return $taskForm.Tag
            }
        }

        # Function to update the tasks listbox
        function UpdateTasksListbox() {
            $tasksListbox.Items.Clear()
            foreach ($task in $selectedServer.Tasks) {
                $taskStatus = $task.Status
                $taskName = $task.Name
                $completedDate = $task.CompletedDate

                $taskText = "$taskName - $taskStatus"
                if ($taskStatus -eq "Completed" -and $completedDate) {
                    $taskText += " (Completed on $completedDate)"
                }

                [void]$tasksListbox.Items.Add($taskText)
            }
        }

        $tasksForm.Controls.Add($tasksLabel)
        $tasksForm.Controls.Add($tasksListbox)
        $tasksForm.Controls.Add($editButton)
        $tasksForm.Controls.Add($newTaskButton)
        $tasksForm.Controls.Add($deleteButton)

        $tasksForm.ShowDialog() | Out-Null
    }
}

$tasksButton.add_Click($tasksButtonHandler)

# ... (the rest of the code remains the same)


# Add the controls to the main form
$form.Controls.Add($label)
$form.Controls.Add($dropdown)
$form.Controls.Add($descriptionLabel)
$form.Controls.Add($listbox)
$form.Controls.Add($connectButton)
$form.Controls.Add($tasksButton)

# Show the main form
$form.ShowDialog() | Out-Null
