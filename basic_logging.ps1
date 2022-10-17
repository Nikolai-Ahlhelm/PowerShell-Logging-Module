### Basic Powershell Logging
#17.10.2022 - v2.3

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
	[string] $LTDefault
	[string] $LTDebug
	[string] $LTProductive
	[string] $LTError
	[string] $LTCritical

	#Constructor
    Logger(
        [string] $logFilePath,
		[string] $logType
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
		
        if($null -eq $logType)
		{
			$logType = "DEFAULT"
        }		
		
		#LogTypeGroups
		$this.LTDefault 	= "ERROR","INFO","WARNING","CRITICAL"
		$this.LTDebug 		= "ERROR","INFO","WARNING","CRITICAL","DEBUG"
		$this.LTProductive 	= "ERROR","INFO","CRITICAL"
		$this.LTError 		= "ERROR"
		$this.LTCritical 	= "CRITICAL"
		#Get logtype 
		$this.LogType = EvalLogType($logType)
		
        
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

	[string] EvalLogType($INPUT) {
		if ($Type -ieq "DEFAULT" -or $Type -ieq "DEF") {
            $type = "DEFAULT"
        }
		elseif ($Type -ieq "DEBUG" -or $Type -ieq "DBG") {
            $type = "DEBUG"
        }
		elseif ($Type -ieq "PRODUCTIVE" -or $Type -ieq "PROD") {
            $type = "PRODUCTIVE"
        }
		elseif ($Type -ieq "ERROR" -or $Type -ieq "ERR") {
            $type = "ERROR"
        }
		elseif ($Type -ieq "CRITICAL" -or $Type -ieq "CRIT") {
            $type = "CRITICAL"
        }
		elseif ($Type -ieq "NONE") {
            $type = "NONE"
        }
		else
		{
			$type = "DEFAULT"
		}
		return $type
	}

    [string] Entry($Type,$Message) {
        if ($Type -ieq "ERROR" -or $Type -ieq "err" -or $Type -ieq "e") {
            $type = "ERROR"
        }
        elseif ($Type -ieq "INFO" -or $Type -ieq "inf" -or $Type -ieq "i") {
            $type = "INFO"
        }
        elseif ($Type -ieq "WARN" -or $Type -ieq "warning" -or $Type -ieq "w") {
            $type = "WARNING"
        }
        elseif ($Type -ieq "CRIT" -or $Type -ieq "critical" -or $Type -ieq "c") {
            $type = "CRITICAL"
        }
		elseif ($Type -ieq "DBG" -or $Type -ieq "debug" -or $Type -ieq "d") {
            $type = "DEBUG"
        }
        else {
            $type = $Type
        }


		$messageType = $type
		
		#LogType Filter
		if ($this.LogType -ieq "DEFAULT" -and $LTDefault -contains $messageType)
		{
			$this.WriteLog($type,$Message)
		}
		elseif ($this.LogType -ieq "DEBUG" -and $LTDebug -contains $messageType)
		{
			$this.WriteLog($type,$Message)
		}
		elseif ($this.LogType -ieq "PRODUCTIVE" -and $LTProductive -contains $messageType)
		{
			$this.WriteLog($type,$Message)
		}
		elseif ($this.LogType -ieq "ERROR" -and $LTError -contains $messageType)
		{
			$this.WriteLog($type,$Message)
		}		
		elseif ($this.LogType -ieq "CRITICAL" -and $LTCritical -contains $messageType)
		{
			$this.WriteLog($type,$Message)
		}
		else
		{
			#Nothing happens : Type = None
			return ""
		}
		
		<#
		$this.LogMessage = "["+(Get-Date -Format $this.format)+"] [$type] "+$Message

		Write-Output $this.LogMessage
        Out-File $this.logFilePath -Append -InputObject $this.LogMessage
		
        if($this.PrintToConsole) {
            return $this.LogMessage
        } 
        else {
            return ""
        }#>

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