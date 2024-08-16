Add-Type -AssemblyName System.Windows.Forms

# Create main window
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Log Viewer"
$Form.Size = New-Object System.Drawing.Size(800, 600)

# Create table
$DataGridView = New-Object System.Windows.Forms.DataGridView
$DataGridView.Dock = "Fill"
$Form.Controls.Add($DataGridView)
$dataGridView.ColumnHeadersVisible = $true

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath("Windows") 
    Filter = '*.txt|*.txt'
}
$null = $FileBrowser.ShowDialog()


$table = New-Object System.Data.DataTable;

#Column1 Date
$column = New-Object System.Data.DataColumn;
$column.DataType = [System.Type]::GetType("System.String");
$column.ColumnName = "Date";
$table.Columns.Add($column);


#Column2 Type
$column = New-Object System.Data.DataColumn;
$column.DataType = [System.Type]::GetType("System.String");
$column.ColumnName = "Type";
$table.Columns.Add($column);

#Column3 Log Message
$column = New-Object System.Data.DataColumn;
$column.DataType = [System.Type]::GetType("System.String");
$column.ColumnName = "Log Message";
$table.Columns.Add($column);

$Path = $FileBrowser.FileName

$LogEntries = @()
Get-Content -Path $Path | ForEach-Object {
    $row = $table.NewRow()
	$row["Date"] = ($_.Split(" ")[0]).TrimStart(" ").TrimEnd(" ")
	$row["Type"] = ($_.Split(" ")[2]).TrimStart(" ").TrimEnd(" ")
	$row["Log Message"] = ($_.Split("]")[2]).TrimStart(" ").TrimEnd(" ")
    
	$table.Rows.Add($row) 

}


$LogName = $Path | Split-Path -Leaf
$table | Out-GridView -Title "[PREVIEW] PSLM Log Viewer | $LogName"