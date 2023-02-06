### Basic Powershell Logging
#27.10.2022 - v3.0

### USAGE
#Import Module:		Import-Module -Name .\basic_logging.ps1

#Create Log Obj:	$Log = New-Object -TypeName Logger -ArgumentList (LogFileName:"log.txt",PrintToConsole:$TRUE)

#LogEntry:			$Log.Entry("Info", "Test Message") ## $Log.Entry(TYPE, MESSAGE)

#Logging Types: 	Default(all except debug), Debug(all), Productive(error,crit), Error(only errors), Critical(only critical), None(no logs)

class Logger
{
    [string] $LogFilePath 	#Path to log file 
    [string] $LogDate		#Date used for log entries
    [string] $LogMessage	#Message for log entries
    [string] $LogType		#Logging type (Productive, Debug, etc.)
    [string] $format		#Timestamp format
	[string] $ModulePath
    [bool] 	 $PrintToConsole#Should entries be printed out to console
	[int] 	 $LogRetention	#Days of retention until logs are deleted
	[string] $logColor

	#LogTypeGroups
	$LTDefault
	$LTDebug
	$LTProductive
	$LTError
	$LTCritical

	#Constructor
    Logger(
        [string] $logFilePath,
		[string] $logType,
        [bool] $PrintToConsole,
		[int] $logRetention
		#[string] $format
    )
	{
        $this.logFilePath = $logFilePath
        $this.LogDate = Get-Date -Format "dd/MM/yyyy"
		$this.format = "dd/MM/yyyy-HH:mm:ss:ffff"
		### Eval. Log Type Fnc
        if($null -eq $PrintToConsole)
		{
			$this.PrintToConsole = $TRUE
        } else {
            $this.PrintToConsole = $PrintToConsole
        }
		
		#Get logtype
        if($null -eq $logType)
		{
			$this.LogType = "DEFAULT"
        }else{
			$this.LogType = $this.EvalLogType($logType)
		}	
		
		#Get log retention
        if($null -eq $logRetention)
		{
			$this.LogRetention = -30
        }else{
			$this.LogRetention = $logRetention
		}	
		
		#LogTypeGroups
		$this.LTDefault 	= "ERROR","INFO","WARNING","CRITICAL"
		$this.LTDebug 		= "ERROR","INFO","WARNING","CRITICAL","DEBUG"
		$this.LTProductive  = "ERROR","INFO","CRITICAL"
		$this.LTError 		= "ERROR"
		$this.LTCritical 	= "CRITICAL"

		#Get Log format
		<#if ($format -ne $NULL) {
			$this.format = $format
		}
		else {
			$this.format = "dd/MM/yyyy-HH:mm:ss:ffff"
		}#>
		
		
    }

    [void] SetLogFilePath($FilePath) {
        $this.logFilePath = $FilePath
    }

    [void] SetTimeFormat($Format) {
        $this.format = $Format
    }

    [void] SetConsoleOut($BOOL) {
        $this.PrintToConsole = $BOOL
    }


	[void] WriteColor([string[]]$Text, [string[]]$ForegroundColor) {

		foreach($textPart in $Text){
			$index = $Text.IndexOf($textPart)
			#Write-Host "index is:",$index

			$lastIndex = $Text.length - 1 

			if ($index -ne $lastIndex) {
				Write-Host $textPart -ForegroundColor $ForegroundColor[$index] -NoNewLine
				#Write-Host "First lines"
			}
			else {
				Write-Host $textPart -ForegroundColor $ForegroundColor[$index]
				#Write-Host "Last line"
			}

		}

		#Write-Host "Test" -ForegroundColor [COLOR] -BackgroundColor [COLOR] -NoNewLine
	}


	[string] EvalLogType($Type) {
		if ($Type -ieq "DEFAULT" -or $Type -ieq "DEF") {
            return "DEFAULT"
        }
		elseif ($Type -ieq "DEBUG" -or $Type -ieq "DBG") {
            return "DEBUG"
        }
		elseif ($Type -ieq "PRODUCTIVE" -or $Type -ieq "PROD") {
            return "PRODUCTIVE"
        }
		elseif ($Type -ieq "ERROR" -or $Type -ieq "ERR") {
            return "ERROR"
        }
		elseif ($Type -ieq "CRITICAL" -or $Type -ieq "CRIT") {
            return "CRITICAL"
        }
		elseif ($Type -ieq "NONE") {
            return "NONE"
        }
		else
		{
			return "DEFAULT"
		}
	}

    [string] Entry($Type,$Message) {
        if ($Type -ieq "ERROR" -or $Type -ieq "err" -or $Type -ieq "e") {
            $messageType = "ERROR"
        }
        elseif ($Type -ieq "INFO" -or $Type -ieq "inf" -or $Type -ieq "i") {
            $messageType = "INFO"
        }
        elseif ($Type -ieq "WARN" -or $Type -ieq "warning" -or $Type -ieq "w") {
            $messageType = "WARNING"
        }
        elseif ($Type -ieq "CRIT" -or $Type -ieq "critical" -or $Type -ieq "c") {
            $messageType = "CRITICAL"
        }
		elseif ($Type -ieq "DBG" -or $Type -ieq "debug" -or $Type -ieq "d") {
            $messageType = "DEBUG"
        }
        else {
            $messageType = $Type
        }
		

		#LogType Filter
		if ($this.LogType -ieq "DEFAULT" -and $this.LTDefault -contains $messageType)
		{
			return $this.WriteLog($messageType,$Message)
		}
		elseif ($this.LogType -ieq "DEBUG" -and $this.LTDebug -contains $messageType)
		{
			return $this.WriteLog($messageType,$Message)
		}
		elseif ($this.LogType -ieq "PRODUCTIVE" -and $this.LTProductive -contains $messageType)
		{
			return $this.WriteLog($messageType,$Message)
		}
		elseif ($this.LogType -ieq "ERROR" -and $this.LTError -contains $messageType)
		{
			return $this.WriteLog($messageType,$Message)
		}		
		elseif ($this.LogType -ieq "CRITICAL" -and $this.LTCritical -contains $messageType)
		{
			return $this.WriteLog($messageType,$Message)
		}
		else
		{
			#No match with LogType found, 
			return ""
		}

    }
	
	[string] WriteLog($type,$Message)
	{
		#$this.LogMessage = "["+(Get-Date -Format $this.format)+"] [$type] "+$Message
		$this.logColor = ""
		switch ($type) {
			"ERROR" 	{ $this.logColor = "Red" }
			"INFO" 		{ $this.logColor = "Gray" }
			"WARNING" 	{ $this.logColor = "Yellow" }
			"CRITICAL" 	{ $this.logColor = "DarkRed" }
			Default 	{ $this.logColor = "Gray" }
		}



		$TimeStamp = "["+(Get-Date -Format $this.format)+"] "
		$TypeStamp = "[$type] "

		$Message = $TimeStamp,$TypeStamp,$Message

		#Write-Host $this.LogMessage -BackgroundColor "Red"
		$colors = "Gray",$this.logColor,"Gray"
		$this.WriteColor($Message, $colors)
        Out-File $this.logFilePath -Append -InputObject $this.LogMessage
		
        if($this.PrintToConsole) {
            return $this.LogMessage
        } 
        else {
            return ""
        }
	}

	[void] LogCleanup($LogFolder)
	{
		Write-Output "CLEANING..."
		if($this.LogRetention -gt 0)
		{
			$this.LogRetention = $this.LogRetention * -1
		}
		
		$RetentionDate = (Get-Date).AddDays($this.LogRetention)
		$RetentionDate = $RetentionDate.ToString("yyyyMMddHHmmss")
		$this.Entry("d","Log retention date = "+$RetentionDate)

		$logFiles = Get-ChildItem $LogFolder

		foreach ($log in $logFiles)
		{
			$fileDate = $log.name -replace "_"
			$fileDate = $fileDate -replace ".log"
			$this.Entry("d","Checking: "+$log.FullName+" fileDate: "+$fileDate)
			$this.Entry("d","FD: "+$fileDate+" RetDt: "+$RetentionDate)
			if($fileDate -lt $RetentionDate)
			{
				try {
					$RmvItemPath = $LogFolder+$log.name
					Remove-Item $RmvItemPath
					$this.Entry("d","Deleting: "+$log.name)
				}
				catch {
					$this.Entry("e","[LogCleanup] Deletion failed >>"+$_.Exception.Message)
				}
			}
		}
	}
}