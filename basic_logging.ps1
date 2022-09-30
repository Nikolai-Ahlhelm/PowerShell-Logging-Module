### Basic Powershell Logging
#28.04.2022 - v2.2

### USAGE
#Import Module:		Import-Module -Name .\basic_logging.ps1

#Create Logger Obj:		$Log = New-Object -TypeName Logger -ArgumentList "log.txt"

#LogEntry:			$Log.Entry("Info", "Test Message") ## $Log.Entry(TYPE, MESSAGE)


class Logger
{
    [string] $LogFilePath 
    [string] $LogDate
    [string] $LogMessage
    [string] $LogType
    [string] $format
    [bool] $PrintToConsole

    Logger(
        [string] $logFilePath,
        [bool] $PrintToConsole
    ){
        $this.logFilePath = $logFilePath
        $this.LogDate = Get-Date -Format "dd/MM/yyyy"
		#Get-Date -Format "dd-MM-yyyy-hh:mm:ss:ffff"
		$this.format = "dd/MM/yyyy-hh:mm:ss:ffff"
        if($null -eq $PrintToConsole){
            $this.PrintToConsole = $TRUE
        } else {
            $this.PrintToConsole = $PrintToConsole
        }
        
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
        else {
            $type = $Type
        }

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