### PowerShell Logging Module
# 22.08.2024 - v3.4.0

### USAGE
#Import Module:		Using module ".\PSLM.psd1" (Must be the first line!)

#Create Log Obj:	$PSLM = New-Object -TypeName PSLM -ArgumentList ("log-%yyyy%-%MM%-%dd%.txt",".\","DEFAULT",$TRUE,"time")

#LogEntry:			$Log.Entry("Info", "Test Message") ## $Log.Entry(TYPE, MESSAGE)

#Logging Types: 	Default(all except debug), Debug(all), Productive(error,crit), Error(only errors), Critical(only critical), None(no logs)

#LogCleanup:		$this.LogCleanup(int:RETENTIONDAYS)

class PSLM #PowerShell Logging Module
{
	[string] $LogFileName		#Name of log file with file extension
    [string] $LogFilePath 		#Path to log file must end with a \ like: .\logs\
    [string] $LogFileFullPath 	#Full log path
	[string] $LogDate			#Date used for log entries
    [string] $LogMessage		#Message for log entries
    [string] $LogType			#Logging type (Productive, Debug, etc.)
	[string] $ModulePath		#
    [bool] 	 $PrintToConsole	#Should entries be printed out to console
	[string] $logColor			#Color used for entries
	[string] $TimestampFormat 	#Format of the timestamp

	#LogTypeGroups
	$LTDefault
	$LTDebug
	$LTProductive
	$LTError
	$LTCritical


	#Constructor
    PSLM(
		[string] $logFileName,
        [string] $logFilePath,
		[string] $logType,
        [bool] $PrintToConsole,
		[string] $TimestampFormat
    )
	{

		#Generate logFileName - useable variables:
		#%dd% : Day, %MM% : months, %yyyy% : year
		#%hh% : hour, %m% : minutes, %ss% : seconds
		if($null -ne $logFileName)
		{
			$this.LogFileName = $logFileName
					}
		else {
			$this.LogFileName = log-%yyyy%-%MM%-%dd%.txt
		}
		#Set day
		$this.LogFileName = $this.LogFileName -replace "%dd%",((Get-Date -Format "dd").ToString())
		#Set month
		$this.LogFileName = $this.LogFileName -replace "%MM%",((Get-Date -Format "MM").ToString())
		#Set year
		$this.LogFileName = $this.LogFileName -replace "%yyyy%",((Get-Date -Format "yyyy").ToString())
		#Set hour
		$this.LogFileName = $this.LogFileName -replace "%hh%",((Get-Date -Format "HH").ToString())
		#Set minutes
		$this.LogFileName = $this.LogFileName -replace "%m%",((Get-Date -Format "mm").ToString())
		#Set seconds
		$this.LogFileName = $this.LogFileName -replace "%ss%",((Get-Date -Format "ss").ToString())

		

		#Get logFilePath
		$this.LogFilePath = $null -ne $logFilePath ? $logFilePath : ".\"

		#Check if path has backslash or slash at the end
		if (-not $this.LogFilePath.EndsWith("/") -and -not $this.LogFilePath.EndsWith("\")){
			# Append '\'
			$this.LogFilePath += "\"
		}
		$this.LogFilePath = Resolve-Path $this.LogFilePath
		
		# Set full log path
		$this.LogFileFullPath = $this.LogFilePath+"\"+$this.LogFileName

		# Set LogDate
        $this.LogDate = Get-Date -Format "dd/MM/yyyy"

		# Eval. Log Type Fnc
        $this.PrintToConsole = if ($null -eq $PrintToConsole) { $true } else { $PrintToConsole }
		
		# Log type eval
		$this.LogType = if ($null -eq $logType) { "DEFAULT" } else { $logType }
		$this.LogType = $this.EvalLogType($this.LogType)

		#Get timestamp format
		if($null -ne $TimestampFormat) 
		{
			switch ($TimestampFormat) {
				"default" { $this.TimestampFormat = "dd-MM-yyyy-HH:mm:ss.ffff" }
				"time" { $this.TimestampFormat = "HH:mm:ss.ffff" }
				"day" { $this.TimestampFormat = "dd-MM-yyyy" }
				Default {  
					#Check if custom format is valid, else use default
					try {
						Get-Date -Format $TimestampFormat
						$this.TimestampFormat = $TimestampFormat
					}
					catch {
						$this.TimestampFormat = "dd-MM-yyyy-HH:mm:ss.ffff"
					}
				}
			}
		} else {
			$this.TimestampFormat = "dd-MM-yyyy-HH:mm:ss.ffff"
		}


		#LogTypeGroups
		$this.LTDefault 	= "ERROR","INFO","WARNING","CRITICAL"
		$this.LTDebug 		= "ERROR","INFO","WARNING","CRITICAL","DEBUG"
		$this.LTProductive  = "ERROR","INFO","CRITICAL"
		$this.LTError 		= "ERROR"
		$this.LTCritical 	= "CRITICAL"

		#Check for updates
		$this.IsUpdateAvailable()

    }

	[psobject] GetLatestVersionInfo() {
		return Invoke-RestMethod -Uri "https://api.github.com/repos/nikolai-ahlhelm/powershell-logging-module/releases/latest"	
	}

	[string] GetLatestFormattedVersion() { #Return trimmed version (without 'v')
		$latest = $this.GetLatestVersionInfo()
		#Trim 'v' from version
		return $latest.tag_name.TrimStart('v')
	}

	[string] GetInstalledVersion() { #Return version from PSLM.psd1
		$psdData = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName "PSLM.psd1"
		return $psdData.ModuleVersion
	}

	[bool] IsOldVersionInstalled() { #Return $true if an old (version mismatch) version is installed else $false
		$latestVersion = $this.GetLatestVersionInfo()

		# Get ModuleVersion from PSLM.psd1 file with Import-LocalizedData
		$psdData = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName "PSLM.psd1"
		$currentVersion = $psdData.ModuleVersion

		if ($this.GetLatestFormattedVersion() -ne $this.GetInstalledVersion()) {
			return $true
		}
		return $false
	}

	# Check for updates on GitHub
	[bool] IsUpdateAvailable() {
		#Compare versions
		if ($this.IsOldVersionInstalled()) {
			$this.Entry("PSLM-UPDATE","📣 New version available: "+$this.GetLatestFormattedVersion())
			$this.Entry("PSLM-UPDATE","🌐 Release on GitHub: "+$this.GetLatestVersionInfo.html_url)
			return $true
		}
		return $false

	}

	[void] DownloadFile($url, $outputPath) #Download via invoke webrequest
	{
		Invoke-WebRequest -Uri $url -OutFile $outputPath 
	}

	[void] UpdatePSLM($forceUpdate)
	{
		$forceUpdate = if ($null -eq $forceUpdate) { $false } else { $forceUpdate }

		# Execute update check or force update
		# Check if an update is available or force update
		if ($this.IsUpdateAvailable() -or $forceUpdate) {
			$latest = $this.GetLatestVersionInfo()

			$urlPart1 = "https://github.com/Nikolai-Ahlhelm/PowerShell-Logging-Module/releases/download/"
			$urlPart2 = $latest.tag_name
			$downloadFiles = @("/PSLM.psm1", "/PSLM.psd1")
			
			$this.Entry("PSLM-UPDATE","🔄️ Updating to version: "+$latest.tag_name)

			# Download and update each file
			foreach ($file in $downloadFiles) {
				$downloadUrl = $urlPart1+$urlPart2+$file
				$downloadPath = "."+$file
				
				$this.DownloadFile($downloadUrl, $downloadPath)
				$this.Entry("PSLM-UPDATE","📄 $file downloaded to: "+$downloadPath)
			}
			$this.Entry("PSLM-UPDATE","🚀 Update complete . Update will be applied at next script execution.")
		}
	}



	# Change log file path
    [void] SetLogFilePath($FilePath) {
		$FilePath = Resolve-Path $FilePath
		$this.Entry("d","SetLogFilePath: $FilePath")
        $this.logFilePath = $FilePath
    }

	# Change time stamp format
    [void] SetTimeFormat($Format) {
		$this.Entry("d","SetTimeFormat: $Format")
        $this.TimestampFormat = $Format
    }

	# Enable / Disable console output
    [void] SetConsoleOut($BOOL) {
		$this.Entry("d","SetConsoleOut: $BOOL")
        $this.PrintToConsole = $BOOL
    }


	[void] WriteColor([string[]]$Text, [string[]]$ForegroundColor) {

		foreach($textPart in $Text){
			$index = $Text.IndexOf($textPart)

			$lastIndex = $Text.length - 1 

			if ($index -ne $lastIndex) {
				Write-Host $textPart -ForegroundColor $ForegroundColor[$index] -NoNewLine
			}
			else {
				Write-Host $textPart -ForegroundColor $ForegroundColor[$index]
			}

		}

	}


	[string] EvalLogType($Type) {
		$Type = $Type.ToUpper()
		$logTypeMap = @{
			"DEFAULT" = "DEFAULT"
			"DEF" = "DEFAULT"
			"DEBUG" = "DEBUG"
			"DBG" = "DEBUG"
			"PRODUCTIVE" = "PRODUCTIVE"
			"PROD" = "PRODUCTIVE"
			"ERROR" = "ERROR"
			"ERR" = "ERROR"
			"CRITICAL" = "CRITICAL"
			"CRIT" = "CRITICAL"
			"NONE" = "NONE"
		}
	
		return $null -ne $logTypeMap[$Type] ? $logTypeMap[$Type] : "DEFAULT"
	}

	# SelectEntryType | called by $this.Entry
	[string] SelectEntryType($Type) {
		$Type = $Type.ToUpper()
		$entryTypeMap = @{
			"ERROR" = "ERROR"
			"ERR" = "ERROR"
			"E" = "ERROR"
			"INFO" = "INFO"
			"INF" = "INFO"
			"I" = "INFO"
			"WARN" = "WARNING"
			"WARNING" = "WARNING"
			"W" = "WARNING"
			"CRIT" = "CRITICAL"
			"CRITICAL" = "CRITICAL"
			"C" = "CRITICAL"
			"DBG" = "DEBUG"
			"DEBUG" = "DEBUG"
			"D" = "DEBUG"
		}
		return $null -ne $entryTypeMap[$Type] ? $entryTypeMap[$Type] : $Type
	}


    [void] Entry($Type,$Message) {
        
		# Get Type
		$messageType = $this.SelectEntryType($Type)
		

		#LogType Filter
		if ($this.LogType -ieq "DEFAULT" -and $this.LTDefault -contains $messageType)
		{
			$this.WriteLog($messageType,$Message)
		}
		elseif ($this.LogType -ieq "DEBUG" -and $this.LTDebug -contains $messageType)
		{
			$this.WriteLog($messageType,$Message)
		}
		elseif ($this.LogType -ieq "PRODUCTIVE" -and $this.LTProductive -contains $messageType)
		{
			$this.WriteLog($messageType,$Message)
		}
		elseif ($this.LogType -ieq "ERROR" -and $this.LTError -contains $messageType)
		{
			$this.WriteLog($messageType,$Message)
		}		
		elseif ($this.LogType -ieq "CRITICAL" -and $this.LTCritical -contains $messageType)
		{
			$this.WriteLog($messageType,$Message)
		}
		# For custom entry type 
		elseif (-not ($this.LTDebug -contains $messageType)) 
		{
			$this.WriteLog($messageType,$Message)
		}

    }
	
	[void] WriteLog($type,$Message)
	{
		#$this.LogMessage = "["+(Get-Date -Format $this.TimestampFormat)+"] [$type] "+$Message
		$this.logColor = ""
		switch ($type) {
			"ERROR" 	{ $this.logColor = "Red" }
			"INFO" 		{ $this.logColor = "DarkCyan" }
			"WARNING" 	{ $this.logColor = "Yellow" }
			"CRITICAL" 	{ $this.logColor = "DarkRed" }
			"DEBUG"		{ $this.logColor = "DarkGreen" }
			Default 	{ $this.logColor = "Magenta" }
		}


		#Create TimeStamp string
		$TimeStamp = "["+(Get-Date -Format $this.TimestampFormat)+"] "

		#Create TypeStamp string
		$TypeStamp = "[$type] "

		#Build Message
		$MessageOut = "$TimeStamp $TypeStamp $Message"

		#Message color 
		$colors = "Gray",$this.logColor,"Gray"

		#Message -> file
        Out-File $this.LogFileFullPath -Append -InputObject $MessageOut
		
		#Message -> console
        if($this.PrintToConsole) {
			$MessageArray = $TimeStamp,$TypeStamp,$Message
			#Call function for colored output
            $this.WriteColor($MessageArray, $colors)
        }
	}

	### Interfaces for Entry() ###
	[void] Info($Message) { $this.Entry("Info",$Message) }
	[void] Warn($Message) { $this.Entry("Warning",$Message) }
	[void] Error($Message) { $this.Entry("Error",$Message) }
	[void] Crit($Message) { $this.Entry("Critical",$Message) }
	[void] Debug($Message) { $this.Entry("Debug",$Message) }


	# $PSLM.LogCleanup(n) > deletes logs older than 14 n days
	[void] LogCleanup($RetentionDays)
	{

		$cleanedFiles = 0

		$this.Entry("i","Cleanup started...")
		if($RetentionDays -gt 0)
		{
			$RetentionDays = $RetentionDays * -1
		}
		
		$RetentionDate = (Get-Date).AddDays($RetentionDays)
		$this.Entry("d","Log retention date : "+$RetentionDate)

		$logFiles = Get-ChildItem $this.LogFilePath

		foreach ($log in $logFiles)
		{
			$this.Entry("d","Checking: "+$log.FullName)
			$this.Entry("d","Filedate: "+$log.LastWriteTime+" RetDt: "+$RetentionDate)
			if($log.LastWriteTime -lt $RetentionDate)
			{
				try {
					$RmvItemPath = $this.LogFilePath+$log.name
					Remove-Item $RmvItemPath
					$this.Entry("d","File deleted, older than retention day: "+$log.name)
					$cleanedFiles++
				}
				catch {
					$this.Entry("e","LogCleanup deletion failed for "+$log.name+" >> "+$_.Exception.Message)
				}
			} else {
				$this.Entry("d","File "+$log.name+" above retention day")
			}
		}

		$this.Entry("i", "$cleanedFiles delete by LogCleanp")

	}

	#DevMode | Execute DevTest
	[void] DevMode()
	{
		$this.LogType = "DEBUG"
		$this.Entry("DEVMODE","🧪 DevMode enabled")

		# Test Download
		try {
			$this.Entry("DEVMODE","🔎 Testing UpdatePSLM function")
			$this.UpdatePSLM($true) #Force Update
			$this.Entry("DEVMODE","✅ UpdatePSLM test passed")	
		}
		catch {
			$this.Entry("DEVMODE","❌ UpdatePSLM test failed: $_")
		}
		
	}

}


