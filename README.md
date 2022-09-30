# Basic Logger Module for Powershell - Version 2.2
 Basic Logger Module made for Powershell
 
 Timeformat: `dd/mm/yyyy-hh:mm:ss:ffff (ffff = milliseonds)`
 
<br>

## Possible Logtypes (case insensitive) 
 - INFO 	(info, inf, i)
 - WARNING  (warning, warn, w)
 - CRITICAL (critical, crit, c)
 - ERROR	(error, err, e)
 - Custom   (Just enter any string you wish)

<br>

## Functions

>### Contructor
>#### `New-Object -TypeName Logger -ArgumentList (string:LOGPATH,bool:PRINTTOLOG)`

<br>

>### Entry(TYPE,MESSAGE)
>Creates a single log entry.

<br>

>### SetLogFilePath(PATH)
>Set the path to the log file.

<br>

>### SetConsoleOut(BOOL)
>Activate/Deactivate console output of log mesages

<br>

>### SetTimeFormat(STRING)
>Set a customized timeformat

<br>

_________________


<br>

# Changelog

## Version 2.2
 - First char of type parameter is now accepted (case insensitive)
 - Log Message is now shown in console
 - Performance improved (removed repetative tasks for each type)
 - Updated `example.ps1` and `README.md`
 - New function `SetConsoleOut`
 - New function `SetTimeFormat`
 

## Version 2.1
 - Function `[void] LogEntry` -> `[void] Entry`
 - Simple Instructions in file header
 - Changed timeformat, now with milliseconds
 - Renamend `test.ps1` -> `example.ps1` and updated file