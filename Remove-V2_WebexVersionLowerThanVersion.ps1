#Remove Cisco Webex Productivity Tools and Cisco Webex Meetings App Versions LOWER than the definded one!
#Remove-WebexVersionsLowerThanVersion.ps1
#26.07.2021, by sysadmin0815
#Version: 1.1

#!! ATTENTION !!
#This script removes ALL Cisco Webex Productivity Tools and ALL Cisco Webex Meetings Apps LOWER than the definded Version!
#Think before you use the script, or run it in TEST MODE!!

#TEST MODE; no changes will be done, only logged.
#Enable Test Mode with $true
#Disable Test Mode with $false
$testModeEnabled = $true

#definde Cisco Webex Versions to keep on the system. All versions lower will be removed.
#Change the value to the WebEx version you want to keep.
#!!You can find the latest versions in SCCM console!!
# Webex Productivity Tools:
$WebexProdToKeepName = "Cisco Webex Productivity Tools"                     #do not modify unless the Product name changed. Used for logfile
$webexProdToKeepVer = "40"                                                  #change to the min. version you want to keep
#Enable or disable the Webex Productivity Tools search and removal
#Enable $true; Disable $false
$webexProd = $true

#Webex Meetings App:
$WebexMeetToKeepName = "Cisco Webex Meetings App"                           #do not modify unless the Product name changed. Used for logfile
$webexMeetToKeepVer = "40"                                                  #change to the min. version you want to keep
#Enable or disable the Webex Meetings App search and removal
#Enable $true; Disable $false
$webExMeet = $true

#Required to build the uninstall string for removal
#do not change this value unless required 
$removalProcess = "MsiExec.exe /X"

#check for existing Log folder
$logFileName="WebExRemoval-Script.log"
$folderName = "IT"
$PathLogs="C:\Windows\Logs\"
$Path="C:\Windows\Logs\"+$folderName
$PathToLogFile=$Path+"\"+$logFileName

#Test for LogFolder if not create it
if (!(Test-Path $Path)) {
New-Item -itemType Directory -Path $PathLogs -Name $folderName -ErrorAction SilentlyContinue
}
else {
Write-Host "[INFO] LogFolder already exists."
}
#Test for Logfile if not create it
if (!(Test-Path $PathToLogFile)) {
New-Item -itemType File -Path $Path -Name $logFileName -ErrorAction SilentlyContinue
}
else {
Write-Host "[INFO] LogFile already exists."
}
# START Webex Productivity Tools
#Check installed versions of Webex Productivity Tools
$webexProdVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
        Get-ItemProperty |
        Where-Object { (($_.DisplayName -like "Cisco Webex Productivity*") -or ($_.Displayname -like "Webex Productivity*")) -and ($_.DisplayName -notlike "Webex Teams*") } |
        Select-Object -Property DisplayName, DisplayVersion, UninstallString
        $webexProdVerLog = $webexProdVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion
        $webexProdNameLog = $webexProdVer | Select-Object Displayname -ExpandProperty Displayname
        $webexProdToRemoveLog = $webexProdNameLog + " " + $webexProdVerLog
        $webexProdToKeepLog = $WebexProdToKeepName + " " + $webexProdToKeepVer + " and above."
#Get unsupported versions of Webex Productivity Tools except the version definded
if (($webExProd -eq $true) -and (($webexProdVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion) -lt $webexProdToKeepVer)) {
    Write-Host
    Write-Host "==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ====" -ForegroundColor Cyan
    Write-Host " Unsupported Webex Product(s) to remove:"
    Write-Host "  ---      $webexProdToRemoveLog >> remove" -ForegroundColor Red
    Write-Host
    Write-Host " Supported Version of Webex Product:"
    Write-Host "  ---     $webexProdToKeepLog >> keep if installed" -ForegroundColor Green
    Write-Host    
    #Build the log file at $pathLogs
    Add-Content $PathToLogFile -Value "****************************************BEGIN****************************************"
    if ($testModeEnabled){
        Add-Content $PathToLogFile -Value "***************************************TESTMODE**************************************"
    }
    Add-Content $PathToLogFile -Value "******************************Webex Productivity Tools*******************************"
    Get-Date | Add-Content $PathToLogFile
    Add-Content $PathToLogFile -Value "These unsupported Webex Productivity Tools Version(s) were removed from your system:"
    $webexProdToRemoveLog | Add-Content $PathToLogFile
    Add-Content $PathToLogFile -Value "Supported Webex Productivity Tools Version(s):"
    $webexProdToKeepLog | Add-Content $PathToLogFile
    Add-Content $PathToLogFile -Value "*****************************************END*****************************************"
    Add-Content $PathToLogFile -Value ""
    #END of log file
    
    #Check if Test Mode is enabled for logging only; if not enabled run the removal at ELSE
    if ($testModeEnabled){
        ForEach ($ver in $webexProdVer) {
            If (($ver.UninstallString) -and (($webexProdVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion) -lt $webexProdToKeepVer) -and ($ver.UninstallString -ne "C:\Program Files (x86)\Webex\Plugins\PluginsUninstaller.exe /ManualUninstall")) {
                $uninst = $ver.UninstallString
                Write-Host "TEST MODE" -ForegroundColor Green
                Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Green
                Write-Host "Uninstall String: $uninst" -ForegroundColor Green
            }
    
            Else {
                $uninst = $ver.UninstallString
                Write-Host "TEST MODE" -ForegroundColor Green
                Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Green
                Write-Host "Uninstall String: $uninst" -ForegroundColor Green
            }
        } 
    }

    else {
        ForEach ($ver in $webexProdVer) {
            If (($ver.UninstallString) -and (($webexProdVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion) -lt $webexProdToKeepVer) -and ($ver.UninstallString -ne "C:\Program Files (x86)\Webex\Plugins\PluginsUninstaller.exe /ManualUninstall")) {
                if ($ver.UninstallString -like "*/I*") {
                    $uninst = $ver.UninstallString
                    $uninstIDsplit = $uninst.Split("/I")
                    $uninstID = $uninstIDsplit[2]
                    Write-Host "PRODUCTION MODE" -ForegroundColor Yellow
                    Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Yellow
                    Write-Host "Uninstall String: $uninst" -ForegroundColor Yellow
                    Start-Process cmd -ArgumentList "/c $removalProcess $uninstID /quiet /norestart" -wait -WindowStyle hidden
                }
                if ($ver.UninstallString -like "*/X*") {
                    $uninst = $ver.UninstallString
                    $uninstIDsplit = $uninst.Split("/X")
                    $uninstID = $uninstIDsplit[2]
                    Write-Host "PRODUCTION MODE" -ForegroundColor Yellow
                    Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Yellow
                    Write-Host "Uninstall String: $uninst" -ForegroundColor Yellow
                    Start-Process cmd -ArgumentList "/c $removalProcess $uninstID /quiet /norestart" -wait -WindowStyle hidden
                }
             
            }
            Else {
                $uninst = $ver.UninstallString
                Write-Host "PRODUCTION MODE" -ForegroundColor Yellow
                Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Yellow
                Write-Host "Uninstall String: $uninst" -ForegroundColor Yellow
                Start-Process cmd -ArgumentList "/c $uninst /S" -wait -WindowStyle hidden
            }
        }
    } 
}
#END Webex Productivity Tools

#START Webex Meetings App
#Check installed versions of Webex Meetings App
$webexMeetVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
        Get-ItemProperty |
        Where-Object { (($_.DisplayName -like "Cisco Webex Meeting*") -or ($_.Displayname -like "Webex Meeting*")) -and (($_.DisplayName -notlike "Webex Teams*")) } |
        Select-Object -Property DisplayName, DisplayVersion, UninstallString
        $webexMeetVerLog = $webexMeetVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion
        $webexMeetNameLog = $webexMeetVer | Select-Object Displayname -ExpandProperty Displayname
        $webexMeetToRemoveLog = $webexMeetNameLog + " " + $webexMeetVerLog
        $webexMeetToKeepLog = $WebexMeetToKeepName + " " + $webexMeetToKeepVer + " and above."
#Get unsupported versions of Webex Productivity Tools except the version definded
if (($webExMeet -eq $true) -and ((($webexMeetVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion) -lt $webexMeetToKeepVer))) {
    Write-Host
    Write-Host "==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ====" -ForegroundColor Cyan
    Write-Host " Unsupported Webex Product(s) to remove:"
    Write-Host "  ---     $webexMeetToRemoveLog >> remove" -ForegroundColor Red
    Write-Host
    Write-Host " Supported Version of Webex Product:"
    Write-Host "  ---     $webexMeetToKeepLog >> keep if installed" -ForegroundColor Green
    Write-Host
    #Build the log file at $pathLogs
    Add-Content $PathToLogFile -Value "****************************************BEGIN****************************************"
    if ($testModeEnabled){
        Add-Content $PathToLogFile -Value "***************************************TESTMODE**************************************"
    }
    Add-Content $PathToLogFile -Value "***********************************Webex Meetings************************************"
    Get-Date | Add-Content $PathToLogFile
    Add-Content $PathToLogFile -Value "These unsupported Webex Meetings Version(s) were removed from your system:"
    $webexMeetToRemoveLog | Add-Content $PathToLogFile
    Add-Content $PathToLogFile -Value "Supported Webex Meetings Version(s):"
    $webexMeetToKeepLog | Add-Content $PathToLogFile
    Add-Content $PathToLogFile -Value "*****************************************END*****************************************"
    Add-Content $PathToLogFile -Value ""
    Add-Content $PathToLogFile -Value ""
    #END of log file
    
    #Check if Test Mode is enabled for logging only; if not enabled run the removal at ELSE
    if ($testModeEnabled){
        ForEach ($ver in $webexMeetVer) {
            If (($ver.UninstallString) -and (($webexMeetVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion) -lt $webexMeetToKeepVer) -and ($ver.UninstallString -ne "C:\Program Files (x86)\Webex\Plugins\PluginsUninstaller.exe /ManualUninstall")) {
                $uninst = $ver.UninstallString
                Write-Host "TEST MODE" -ForegroundColor Green
                Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Green
                Write-Host "Uninstall String: $uninst" -ForegroundColor Green
            }
            Else {
                $uninst = $ver.UninstallString
                Write-Host "TEST MODE" -ForegroundColor Green
                Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Green
                Write-Host "Uninstall String: $uninst" -ForegroundColor Green
            }
        } 
    }
    else {
        ForEach ($ver in $webexMeetVer) {
            If (($ver.UninstallString) -and (($webexMeetVer | Select-Object DisplayVersion -ExpandProperty DisplayVersion) -lt $webexMeetToKeepVer) -and ($ver.UninstallString -ne "C:\Program Files (x86)\Webex\Plugins\PluginsUninstaller.exe /ManualUninstall")) {
                if ($ver.UninstallString -like "*/I*") {
                    $uninst = $ver.UninstallString
                    $uninstIDsplit = $uninst.Split("/I")
                    $uninstID = $uninstIDsplit[2]
                    Write-Host "PRODUCTION MODE" -ForegroundColor Yellow
                    Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Yellow
                    Write-Host "Uninstall String: $uninst" -ForegroundColor Yellow
                    Start-Process cmd -ArgumentList "/c $removalProcess $uninstID /quiet /norestart" -wait -WindowStyle hidden
                }
                if ($ver.UninstallString -like "*/X*") {
                    $uninst = $ver.UninstallString
                    $uninstIDsplit = $uninst.Split("/X")
                    $uninstID = $uninstIDsplit[2]
                    Write-Host "PRODUCTION MODE" -ForegroundColor Yellow
                    Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Yellow
                    Write-Host "Uninstall String: $uninst" -ForegroundColor Yellow
                    Start-Process cmd -ArgumentList "/c $removalProcess $uninstID /quiet /norestart" -wait -WindowStyle hidden
                }
            }
            Else {
                $uninst = $ver.UninstallString
                Write-Host "PRODUCTION MODE" -ForegroundColor Yellow
                Write-Host "Removing $($ver.DisplayName) $($ver.DisplayVersion )" -ForegroundColor Yellow
                Write-Host "Uninstall String: $uninst" -ForegroundColor Yellow
                Start-Process cmd -ArgumentList "/c $uninst /S" -wait -WindowStyle hidden
                }
        }
    }
}
#END Webex Meetings App
#END OF SCRIPT
