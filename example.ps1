<#
    Example file for PSLM
    Example commands found below, further information can be found in the README.md
#>

#Import PSLM like this:
Using module .\basic_logging.psm1

#Arguments: LogName[STRING], LogPath[STRING], LogMode[STRING], PrintToConsole[BOOL], [string] $TimestampFormat, RetentionDays[INT]
#LogPath: when using relative paths use  .\[DIRNAME]\  else you'll get errors.
$Log = New-Object -TypeName PSLM -ArgumentList ("log-%hh%-%mm%-%ss%.txt",".\logs\","DEBUG",$TRUE,"default",7)

$Log.Entry("Info", "Logging Mode: "+$Log.LogTypes)
$Log.Entry("Info", "Info Test Message")
$Log.Entry("DEBUG", "Debug Test Message")
$Log.Entry("w", "Warning Test Message")
$Log.Entry("w", "Warning Test Message 2")
$Log.Entry("crit", "Critical Test Message")
$Log.Entry("Error", "Error Test Message")

#Log Cleanup function | Arguments: RetentionDays[INT] (maximum age in days)
$Log.LogCleanup(1)


pause