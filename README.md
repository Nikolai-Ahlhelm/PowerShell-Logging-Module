# Basic Logging Module for Powershell - Version 2.3.1
 Basic Logging Module made for Powershell
 
 Timeformat: `dd/mm/yyyy-hh:mm:ss:ffff (ffff = milliseonds)`
 
<br>

## Logentry types (case insensitive) 
 - INFO 	(info, inf, i)
 - WARNING  (warning, warn, w)
 - CRITICAL (critical, crit, c)
 - ERROR	(error, err, e)
 - DEBUG    (debug, dbg, d)
 - Custom   (Just enter any string you wish)

<br>

## Logmode / Logtype (case insensitive)

| **Type**       | **Short** | **INFO** | **WARNING** | **CRITICAL** | **ERROR** | **DEBUG** |
|----------------|-----------|----------|-------------|--------------|-----------|-----------|
| **DEFAULT**    | DEF       |     X    |      X      |       X      |     X     |           |
| **DEBUG**      | DBG       |     X    |      X      |       X      |     X     |     X     |
| **PRODUCTIVE** | PROD      |     X    |             |       X      |     X     |           |
| **ERROR**      | ERR       |          |             |              |     X     |           |
| **CRITICAL**   | CRIT      |          |             |       X      |           |           |

## Functions

>### Contructor
>#### `New-Object -TypeName Logger -ArgumentList (string:LOGPATH,string:LOGMODE,bool:PRINTTOLOG)`

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

## Version 2.3.1 Bugfix
 - Fixed false return if logmode is none or unvalid


## Version 2.3
 - **Logmodes/logtypes** can now be set, to only log certain log entries
 - New Entrytype: `DEBUG`, only displayed when Logmode is set to `DEBUG`
 - Constructor takes a new argument `LOGTYPE`
 - Updated `example.ps1` and `README.md`
 - Deleted old versions folder


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
