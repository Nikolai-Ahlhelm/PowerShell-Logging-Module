### Basic Powershell Logging
#18.10.2022 - v2.3.1

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
    [bool] 	 $PrintToConsole	#Should entries be printed out to console
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
        [bool] $PrintToConsole
    )
	{
        $this.logFilePath = $logFilePath
        $this.LogDate = Get-Date -Format "dd/MM/yyyy"
		$this.format = "dd/MM/yyyy-hh:mm:ss:ffff"
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
		
		#LogTypeGroups
		$this.LTDefault 	= "ERROR","INFO","WARNING","CRITICAL"
		$this.LTDebug 		= "ERROR","INFO","WARNING","CRITICAL","DEBUG"
		$this.LTProductive  = "ERROR","INFO","CRITICAL"
		$this.LTError 		= "ERROR"
		$this.LTCritical 	= "CRITICAL"
		
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
			#return $this.WriteLog("CRITICAL:LOGGING","`$LogType "+$this.LogType+" not found, check LogType attribute of constructor")
			return ""
		}

    }
	
	[string] WriteLog($type,$Message)
	{
		$this.LogMessage = "["+(Get-Date -Format $this.format)+"] [$type] "+$Message

		Write-Output $this.LogMessage
        Out-File $this.logFilePath -Append -InputObject $this.LogMessage
		
        if($this.PrintToConsole) {
            return $this.LogMessage
        } 
        else {
            return ""
        }
	}

}