### Basic Powershell Logging
#03.03.2022 - v2


class Logger
{
    [string] $LogFilePath 
    [string] $LogDate
    [string] $LogMessage
    [string] $LogType

    Logger(
        [string] $logFilePath
    ){
        $this.logFilePath = $logFilePath
        $this.LogDate = Get-Date -Format "dd/MM/yyyy"
    }

    [void] SetLogFilePath($FilePath) {
        $this.logFilePath = $FilePath
    }

    [void] LogEntry($Type,$Message) {
        if ($Type -eq "ERROR" -or $Type -eq "Error" -or $Type -eq "error" -or $Type -eq "err") {
            $ErrorMessage = "["+$this.LogDate+" / "+(get-date).ToString('T')+"] [ERROR] "+$Message
            Write-Output $ErrorMessage
            Out-File $this.logFilePath -Append -InputObject $ErrorMessage
        }
        elseif ($Type -eq "INFO" -or $Type -eq "Info" -or $Type -eq "info" -or $Type -eq "inf") {
            $InfoMessage = "["+$this.LogDate+" / "+(get-date).ToString('T')+"] [INFO] "+$Message
            Write-Output $InfoMessage
            Out-File $this.logFilePath -Append -InputObject $InfoMessage
        }
        elseif ($Type -eq "WARN" -or $Type -eq "Warn" -or $Type -eq "warn" -or $Type -eq "warning") {
            $WarnMessage = "["+$this.LogDate+" / "+(get-date).ToString('T')+"] [WARNING] "+$Message
            Write-Output $WarnMessage
            Out-File $this.logFilePath -Append -InputObject $WarnMessage
        }
        elseif ($Type -eq "CRIT" -or $Type -eq "Crit" -or $Type -eq "crit" -or $Type -eq "critical") {
            $CritMessage = "["+$this.LogDate+" / "+(get-date).ToString('T')+"] [CRITICAL] "+$Message
            Write-Output $CritMessage
            Out-File $this.logFilePath -Append -InputObject $CritMessage
        }
        else {
            $TypeMessage = "["+$this.LogDate+" / "+(get-date).ToString('T')+"] [$Type] "+$Message
            Write-Output $TypeMessage
            Out-File $this.logFilePath -Append -InputObject $TypeMessage
        }
    }

}