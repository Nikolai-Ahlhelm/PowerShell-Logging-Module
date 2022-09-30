Import-Module -Name .\basic_logging.ps1

#$Log = [Logger]::new("log.txt")

#Arguments: LogPath, PrintToConsole
$Log = New-Object -TypeName Logger -ArgumentList ("log.txt",$TRUE)


$Log.Entry("Info", "Test Message")

pause