Import-Module -Name .\basic_logging.ps1

#$Log = [Logger]::new("log.txt")

#Arguments: LogPath, PrintToConsole
$Log = New-Object -TypeName Logger -ArgumentList ("log.txt","DEFAULT",$TRUE)


$Log.Entry("DEBUG", "Debug Test Message")
$Log.Entry("Info", "Info Test Message")

pause