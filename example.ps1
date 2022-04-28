Import-Module -Name .\basic_logging.ps1

#$Log = [Logger]::new("log.txt")

$Log = New-Object -TypeName Logger -ArgumentList "log.txt"

$Log.Entry("Info", "Test Message")