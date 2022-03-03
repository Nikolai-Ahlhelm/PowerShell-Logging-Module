### Basic Powershell Logging
#03.03.2022 - v1

###Variables###
$LogFilePath = "log.txt"

###Function###
$date = Get-Date -Format "dd/MM/yyyy"

function LogEntry {

    param (
        $Message,
        $Type
    )

    if ($Type -eq "ERROR" -or $Type -eq "Error" -or $Type -eq "error" -or $Type -eq "err") {
        $ErrorMessage = "["+$date+" / "+(get-date).ToString('T')+"] [ERROR] "+$Message
        Write-Output $ErrorMessage
        Out-File $LogFilePath -Append -InputObject $ErrorMessage
    }
    elseif ($Type -eq "INFO" -or $Type -eq "Info" -or $Type -eq "info" -or $Type -eq "inf") {
        $InfoMessage = "["+$date+" / "+(get-date).ToString('T')+"] [INFO] "+$Message
        Write-Output $InfoMessage
        Out-File $LogFilePath -Append -InputObject $InfoMessage
    }
    elseif ($Type -eq "WARN" -or $Type -eq "Warn" -or $Type -eq "warn" -or $Type -eq "warning") {
        $WarnMessage = "["+$date+" / "+(get-date).ToString('T')+"] [WARNING] "+$Message
        Write-Output $WarnMessage
        Out-File $LogFilePath -Append -InputObject $WarnMessage
    }
    elseif ($Type -eq "CRIT" -or $Type -eq "Crit" -or $Type -eq "crit" -or $Type -eq "critical") {
        $CritMessage = "["+$date+" / "+(get-date).ToString('T')+"] [CRITICAL] "+$Message
        Write-Output $CritMessage
        Out-File $LogFilePath -Append -InputObject $CritMessage
    }
    else {
        $TypeMessage = "["+$date+" / "+(get-date).ToString('T')+"] [$Type] "+$Message
        Write-Output $TypeMessage
        Out-File $LogFilePath -Append -InputObject $TypeMessage
    }

}