# PowerShell Logging Module - Version 3.3.1
 Logging Module made for Powershell.  
 For easy logging into the shell and files.

<br>

![PSLM Example Image](img/example.png)

<br>
<br>

![Pwsh5 Warning](img/ps5-warn.png)

<br>
<br>

## 🚀 Quick Start

```
Using module ".\PSLM.psd1"
$PSLM = New-Object -TypeName PSLM -ArgumentList ("log-%hh%-%m%-%ss%.txt", "C:\DIRECTORY", "DEFAULT", $TRUE, "default")

#Example entries:
$PSLM.Info("Info function test")
$PSLM.Debug("Debug function test")
$PSLM.Entry("crit", "Critical Test Message")
$PSLM.Entry("Error", "Error Test Message")

$PSLM.LogCleanup(7)
```


<br>

## 🧩 Features
- Clean formatteted log entries
- Customisable timestamps for entries
- Colored log output
- Save logs directly to logfiles
- 5 default entry types: info, warn, crit, error, debug
- Defnie your own entry types
- Clean log files after x days automaticaly
- Use multiple PSLM instances in one script, if you want to write more than one log

<br>

## 🏷️ Logentry types (case insensitive) 
 - INFO 	  (info, inf, i)
 - WARNING  (warning, warn, w)
 - CRITICAL (critical, crit, c)
 - ERROR	  (error, err, e)
 - DEBUG    (debug, dbg, d)
 - Custom   (Just enter any string you wish)

<br>

## 🎚️ Logmode / Logtype (case insensitive)

| **Type**       | **Short** | **INFO** | **WARNING** | **CRITICAL** | **ERROR** | **DEBUG** |
|----------------|-----------|----------|-------------|--------------|-----------|-----------|
| **DEFAULT**    | DEF       |     X    |      X      |       X      |     X     |           |
| **DEBUG**      | DBG       |     X    |      X      |       X      |     X     |     X     |
| **PRODUCTIVE** | PROD      |     X    |             |       X      |     X     |           |
| **ERROR**      | ERR       |          |             |              |     X     |           |
| **CRITICAL**   | CRIT      |          |             |       X      |           |           |

<br>

---

<br>

## 🛠️ Contructor
  
 **``New-Object -TypeName PSLM -ArgumentList (string:LOGNAME,string:LOGPATH,string:LOGMODE,bool:PRINTTOCONSOLE,string:TIMESTAMPFORMAT)``**

<br>

### 📜 Contructor Arguments


#### *LOGNAME*:  
**"%yyyy%-%MM%-%dd%-log.txt"**  
Use: <br> ``%dd%`` : Day,  
``%MM%`` : months,  
``%yyyy%`` : year,  
``%hh%`` : hour,  
``%m%`` : minutes,  
``%ss%`` : seconds  
They will be replaced with the acording value e.g. %yyyy% = 2023

<br>

#### *LOGPATH*: 
**``".\logs\"``** or **``"C:\the\path\"``**  

<br>

#### *LOGMODE*:  
**``"Default"``**  
Choose one of the logmodes listed above.  

<br>  

#### *PRINTTOCONSOLE*:  
**``\$TRUE``** or **``\$FALSE``**  
Enable or disable console output. 

<br> 
  
#### *TIMESTAMPFORMAT*: 
**``"default"``**
Set timestamp format, use predefined formats: <br>
**``"default"``** : dd-MM-yyyy-HH:mm:ss.ffff <br>
**``"time"``** : <br>
**``"day"``** : <br>
Or define your own, for examples check the official Microsoft Docs [here](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.3#examples).

<br>

---

<br>
  
## ⚡ Methods

<br>

### 📝 Entry(TYPE,MESSAGE)  
Creates a single log entry with timestamp.
<br>
#### Interfaces (Used to give your code a cleaner look)
``Info(MESSAGE)``
``Debug(MESSAGE)``
``Warning(MESSAGE)``
``Critical(MESSAGE)``
``Error(MESSAGE)``

<br>

### 🪧 SetLogFilePath(PATH)  
Set/change the path to the log file.

<br>

### 📣 SetConsoleOut(BOOL)  
Activate/Deactivate console output of log mesages.

<br>

### ⌚ SetTimeFormat(STRING)  
Set/change the timeformat to a customized format.

<br>

### 🧹 LogCleanup(int:RETENTIONDAYS)  
This method is for cleaning logs that are older than the retention date specified in this function. <br>
⚠️ Warning: This function deletes **all** files inside the logfoler, that are older than the retentiondays! This also effects non log files, because the tool has no feature to detect if the file is a log file or something else! It is recommended to **always** store the logfiles in a designated folder!

<br>

_________________


<br>

# 📒 Changelog

## Version 3.3.1
- Fixed: Relative paths not working Relative paths not working - missing backslash between path and file name #38
- Fixed: Version check not getting installed version UpdateCheck not detecting that v3.3.0 is already present #37

## Version 3.3.0
- Feature: 5 new interfaces for the entry function (Info, Warn, Error, Crit, Debug)
- Feature: New interface examples to example.ps1
- Feature: Warning image in readme.md about use of PowerShell 5
- Change: $Log to $PSLM in the example.ps1
- Change: readme file updated to 3.3.0

## Version 3.2.0
- Feature: UpdateCheck function, that checks GitHub for a new version of PSLM
- Feature: Added example image for readme.md
- Change: Various code optimisations
- Change: Removed the `"Unknown"` company from the module manifest
- Change: Custom log types color is now magenta
- Change: Reworked the README file
- Fix: Fixed bugs from first commit


## Version 3.1.0
- Feature: Info bracket colored in darkcyan
- Feature: Add backslash to end of log path, if not already set by user
- Change: Example file import .psd1 instead od .psm1
- Fix: Timestamp change from minutes from %mm% to %m%
- Fix: Unable to change timestamp format in constructor

## Version 3.0.1
 - INFO color changed to dark cyan
 - LogCleanup now logs how many files got deleted


## Version 3.0
 - Changed name from **Logger** to **PSLM**
 - New LogCleanup Method
 - New Constructor argument `LOGNAME`
 - New Constructor argument `TIMESTAMPFORMAT`
 - Changed from `ps1` to `psm1` file
 - Fixed 12-hour format is now 24-hour format
 - Log output is colored now
   - yellow -> warning
   - red -> error
   - darkred -> critical
   - grey/default -> info


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
