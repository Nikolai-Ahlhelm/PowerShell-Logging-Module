### PowerShell Logging Module
#27.10.2022 - v3.0-Dev-3

### USAGE
#Import Module:		Import-Module -Name .\basic_logging.ps1

#Create Log Obj:	$Log = New-Object -TypeName Logger -ArgumentList (LogFileName:"log.txt",PrintToConsole:$TRUE)

#LogEntry:			$Log.Entry("Info", "Test Message") ## $Log.Entry(TYPE, MESSAGE)

#Logging Types: 	Default(all except debug), Debug(all), Productive(error,crit), Error(only errors), Critical(only critical), None(no logs)

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
	[int] 	 $LogRetention		#Days of retention until logs are deleted
	[string] $logColor			#Color used for entries
	[string] $TimestampFormat 	#Format of the timestamp | default values: 

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
		[string] $TimestampFormat,
		[int] $logRetention

    )
	{

		#Generate logFileName - useable variables:
		#%dd% : Day, %MM% : months, %yyyy% : year
		#%hh% : hour, %mm% : minutes, %ss% : seconds
		if($null -ne $logFileName)
		{
			$this.LogFileName = $logFileName
			#Set day
			$this.LogFileName = $this.LogFileName -replace "%dd%",((Get-Date -Format "dd").ToString())
			#Set month
			$this.LogFileName = $this.LogFileName -replace "%MM%",((Get-Date -Format "MM").ToString())
			#Set year
			$this.LogFileName = $this.LogFileName -replace "%yyyy%",((Get-Date -Format "yyyy").ToString())
			#Set hour
			$this.LogFileName = $this.LogFileName -replace "%hh%",((Get-Date -Format "HH").ToString())
			#Set minutes
			$this.LogFileName = $this.LogFileName -replace "%mm%",((Get-Date -Format "mm").ToString())
			#Set seconds
			$this.LogFileName = $this.LogFileName -replace "%ss%",((Get-Date -Format "ss").ToString())

		}

		#Get logFilePath
		if($null -eq $logFilePath)
		{
			$this.LogFilePath = ".\"
		} else {
			$this.LogFilePath = $logFilePath
		}
        
		# Set full log path
		$this.LogFileFullPath = $this.LogFilePath+$this.LogFileName
		Write-Host "Path:"+$this.LogFilePath+"  Name:"+$this.LogFileName


		# Set LogDate
        $this.LogDate = Get-Date -Format "dd/MM/yyyy"

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
		
		#Get timestamp format
		if($null -eq $TimestampFormat) 
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
    }

    [void] SetLogFilePath($FilePath) {
        $this.logFilePath = $FilePath
    }

    [void] SetTimeFormat($Format) {
        $this.TimestampFormat = $Format
    }

    [void] SetConsoleOut($BOOL) {
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

    [void] Entry($Type,$Message) {
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

    }
	
	[void] WriteLog($type,$Message)
	{
		#$this.LogMessage = "["+(Get-Date -Format $this.TimestampFormat)+"] [$type] "+$Message
		$this.logColor = ""
		switch ($type) {
			"ERROR" 	{ $this.logColor = "Red" }
			"INFO" 		{ $this.logColor = "Gray" }
			"WARNING" 	{ $this.logColor = "Yellow" }
			"CRITICAL" 	{ $this.logColor = "DarkRed" }
			"DEBUG"		{ $this.logColor = "DarkGreen" }
			Default 	{ $this.logColor = "Gray" }
		}



		$TimeStamp = "["+(Get-Date -Format $this.TimestampFormat)+"] "
		$TypeStamp = "[$type] "

		$MessageOut = "$TimeStamp $TypeStamp $Message"
		$colors = "Gray",$this.logColor,"Gray"
        Out-File $this.LogFileFullPath -Append -InputObject $MessageOut
		
        if($this.PrintToConsole) {
			$MessageArray = $TimeStamp,$TypeStamp,$Message
            $this.WriteColor($MessageArray, $colors)
        }
	}

	[void] LogCleanup($RetentionDays)
	{

		$this.Entry("d","Cleanup started...")
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
				}
				catch {
					$this.Entry("e","LogCleanup deletion failed for "+$log.name+" >> "+$_.Exception.Message)
				}
			} else {
				$this.Entry("d","File "+$log.name+" above retention day")
			}
		}
	}
}