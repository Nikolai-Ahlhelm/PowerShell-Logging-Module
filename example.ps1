<#
    Example file for PSLM
    Example commands found below, further information can be found in the README.md
#>

#Import PSLM like this:
Using module .\PSLM.psd1

#Arguments: LogName[STRING], LogPath[STRING], LogMode[STRING], PrintToConsole[BOOL], [string] $TimestampFormat, RetentionDays[INT]
#LogPath: when using relative paths use  .\[DIRNAME]\  else you'll get errors.
$PSLM = New-Object -TypeName PSLM -ArgumentList ("TEST-log-%hh%-%mm%-%ss%.txt", ".\", "DEBUG", $TRUE, "default")

$PSLM.Entry("Info", "Logging Mode: "+$Log.LogTypes)
$PSLM.Entry("Info", "Info Test Message")
$PSLM.Entry("DEBUG", "Debug Test Message")
$PSLM.Entry("w", "Warning Test Message")
$PSLM.Entry("w", "🔥You can use emojis to make your logs more interesting")
$PSLM.Entry("crit", "Critical Test Message")
$PSLM.Entry("Error", "Error Test Message")

# New Interfaces added in 3.3.0
$PSLM.Info("Info function test")
$PSLM.Debug("Debug function test")
$PSLM.Warning("Warning function test")
$PSLM.Critical("Critical function test")
$PSLM.Error("Error function test")

#Log Cleanup function | Arguments: RetentionDays[INT] (maximum age in days)
$PSLM.LogCleanup(9999)


pause