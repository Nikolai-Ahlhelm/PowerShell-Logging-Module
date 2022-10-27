function LogCleanup($LogFolder)
{
    Write-Output "CLEANING..."
    if($this.LogRetention -gt 0)
    {
        $this.LogRetention = $this.LogRetention * -1
    }
    #$this.Entry("d","Log retention = "+$this.LogRetention)
    

    $RetentionDate = (Get-Date).AddDays($this.LogRetention)
    Write-Output "Log retention date = "$RetentionDate

    $logFiles = Get-ChildItem $LogFolder

    foreach ($log in $logFiles)
    {
        $fileDate = $log.name -replace "_"
        $fileDate = $fileDate -replace ".log"
        Write-Output "Checking: "$log" fileDate: "$fileDate
        if($fileDate -lt $RetentionDate)
        {
            Remove-Item $log
            Write-Output "Deleting: "$log
        }
    }
}
LogCleanup("logs")