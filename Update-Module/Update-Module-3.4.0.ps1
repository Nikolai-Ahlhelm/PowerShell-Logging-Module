### PSLM Update-Module ###

function Get-Latest 
{
	return Invoke-RestMethod -Uri "https://api.github.com/repos/nikolai-ahlhelm/powershell-logging-module/releases/latest"	
}    

function Download-UpdateZIP($latest)
{

    $downloadUrl = ""
    foreach ($asset in $latest.assets) {
        if ($asset.name -like "*.zip*") {
            $downloadUrl = $asset.browser_download_url
            break
        }
    }
    if ($downloadUrl -eq "") {
        Write-Error "⚠️ No suitable download URL found in the latest release."
        return
    } else {
        Write-Host "🔍 Found download URL: $downloadUrl"
        Write-Host "🔄️ Downloading update..."
        Remove-Item -Path "$env:TEMP\PSLM_Update.zip" -ErrorAction SilentlyContinue #Remove old update file if it exists
        Invoke-RestMethod -Uri $downloadUrl -OutFile "$env:TEMP\PSLM_Update.zip"
        Write-Host "✅ Update downloaded to $env:TEMP\PSLM_Update.zip"
    }
}

function Unzip-Update
{
    try {
        Write-Host "📦 Extracting update..."
        $zipFilePath = "$env:TEMP\PSLM_Update.zip"
        $destinationPath = "$env:TEMP\PSLM_Update"
        Remove-Item -Path $destinationPath -Recurse -Force -ErrorAction SilentlyContinue #Remove old update folder if it exists
        Expand-Archive -Path $zipFilePath -DestinationPath $destinationPath
        Write-Host "📦 Update unzipped to $destinationPath"   
    }
    catch {
        Write-Error "⚠️ Failed to unzip the update. Please check the zip file."
    }

}

function Copy-Update
{
    try {
        Write-Host "📂 Copying update files..."
        $sourcePath = "$env:TEMP\PSLM_Update\*"
        $destinationPath = $PSScriptRoot
        Remove-Item -Path $destinationPath -Recurse -Force -ErrorAction SilentlyContinue #Remove old module folder if it exists
        Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse
        Write-Host "📂 Update files copied to $destinationPath"
    }
    catch {
        Write-Error "⚠️ Failed to copy the update files. Please check the source and destination paths."
        Write-Error $_.Exception.Message
        Write-Error $_.Exception.StackTrace
        Write-Error "⚠️ Destiantion path: $destinationPath"
        Write-Error "⚠️ Source path: $sourcePath"
    }
}

function Verify-Update # check version from psd file and compare it with the latest version
{
    try {
        $psdFile = Get-ChildItem -Path $PSScriptRoot -Filter *.psd1 | Select-Object -First 1
        if (-not $psdFile) {
            Write-Error "⚠️ Could not find module manifest (*.psd1) in $PSScriptRoot."
            return $false
        }
        $manifest = Import-PowerShellDataFile -Path $psdFile.FullName
        $currentVersion = $manifest.ModuleVersion
        $latest = Get-Latest
        $latestVersion = $latest.tag_name.TrimStart("v")
        if ($currentVersion -eq $latestVersion) {
            Write-Host "🎉 Update successful! Module is now at the latest version."
            return $true
        } else {
            Write-Error "⚠️ Update failed! Current version ($currentVersion) does not match latest version ($latestVersion)."
            return $false
        }
    }
    catch {
        Write-Error "⚠️ Error checking module version: $_"
        return $false
    }
}

function Remove-UpdateFiles
{
    try {
        Remove-Item -Path "$env:TEMP\PSLM_Update.zip" -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:TEMP\PSLM_Update" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "🗑️ Temporary files cleaned up."
    }
    catch {
        Write-Error "⚠️ Failed to clean up temporary files."
    }
}

function Create-PostUpdateMarker
{
    $markerFilePath = "$PSScriptRoot\.PSLM_Update_Completed"
    try {
        New-Item -Path $markerFilePath -ItemType File -Force | Out-Null
        Write-Host "🚩 Post-update marker created at $markerFilePath"
    }
    catch {
        Write-Error "⚠️ Failed to create post-update marker."
    }
}



function Update-PSLM
{
    $latest = Get-Latest
    if ($latest -eq $null) {
        Write-Error "⚠️ Failed to retrieve the latest release information."
        return
    }
    
    Write-Host "✨ Latest version: $($latest.tag_name)"
    
    Download-UpdateZIP -latest $latest
    Unzip-Update
    Copy-Update
    
    if (Verify-Update) {
        Remove-UpdateFiles
        Create-PostUpdateMarker
        Write-Host " `n✅ Update completed successfully!"
        Write-Host "🔄️ Please restart your PowerShell session to apply the changes."
        Write-Host "🔗 For more information, visit:  https://github.com/Nikolai-Ahlhelm/PowerShell-Logging-Module"
        # Pause 20 seconds to allow user to read the message
        Write-Host "⌛ This window will close automatically in 20 seconds..."
        Start-Sleep -Seconds 20

    } else {
        Write-Error "===========⚠️ Update verification failed! ============"
        Write-Error "⚠️ Update verification failed. Please check the logs for more details."
        Write-Error "⚠️ The module may not have been updated successfully."
        Write-Error "⚠️ Please try running the update again or check for issues in the update process."
        Write-Error "====================================================="
        # Pause until user presses a key
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }


}

Update-PSLM