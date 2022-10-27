Using module .\basic_logging.psm1

#Arguments: LogPath[STRING], LogMode[STRING], PrintToConsole[BOOL], RetentionDays[INT]
$Log = New-Object -TypeName Logger -ArgumentList ("log.txt","DEFAULT",$TRUE,7)

$Log.Entry("Info", "Logging Mode: "+$Log.LogTypes)
$Log.Entry("Info", "Info Test Message")
$Log.Entry("DEBUG", "Debug Test Message")
$Log.Entry("w", "Warning Test Message")
$Log.Entry("crit", "Critical Test Message")
$Log.Entry("Error", "Error Test Message")

$Log.Entry("i","Calling Cleanup")
$Log.LogCleanup("C:\Users\ahlhelmn\Documents\GitHub\Powershell_Basic_Logging\Basic-Logger-Module-for-Powershell\logs\")
$Log.Entry("i","Called Cleanup")

pause