@echo off
:: Silver's Advanced Hacker Toolkit
color 5
title Silver's Hacker Toolkit

:hacker_menu
cls
echo =====================================================
echo          # Silver's Hacker-Style Tools #
echo =====================================================
echo.
echo [1]  Disk Usage Info
echo [2]  Simple Port Scanner
echo [3]  Lock This Screen
echo [4]  Live Network Monitor
echo [5]  Advanced Port Scanner
echo [6]  Show Active Connections
echo [7]  Show Firewall Rules
echo [8]  Anomaly Process/Service Scan
echo [9]  Extract Wi-Fi Passwords
echo [10]  USB Device Tracker
echo [11]  Exit
echo.
set /p tool=Choose a tool [1-11]: 

if "%tool%"=="1" goto disk_usage
if "%tool%"=="2" goto port_scanner
if "%tool%"=="3" goto lock_screen
if "%tool%"=="4" goto net_monitor
if "%tool%"=="5" goto adv_port
if "%tool%"=="6" goto net_conn
if "%tool%"=="7" goto fw_rules
if "%tool%"=="8" goto anomaly_scan
if "%tool%"=="9" goto wifi_keys
if "%tool%"=="10" goto usb_tracker
if "%tool%"=="11" exit
goto hacker_menu

:disk_usage
cls
echo Fetching disk usage...
PowerShell -Command "Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name,@{Name='Used(GB)';Expression={[math]::Round($_.Used/1GB,2)}},@{Name='Free(GB)';Expression={[math]::Round($_.Free/1GB,2)}} | Format-Table"
pause
goto hacker_menu

:port_scanner
cls
set /p target=Enter IP or domain to scan ports (1-100): 
PowerShell -Command "1..100 | ForEach-Object {
    $port = $_
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $client.Connect('$target', $port)
        if ($client.Connected) {
            Write-Host 'Port' $port 'is OPEN'
            $client.Close()
        }
    } catch {}
}"
pause
goto hacker_menu

:lock_screen
cls
echo Locking your screen in 2 seconds...
timeout /t 2 >nul
rundll32.exe user32.dll,LockWorkStation
goto hacker_menu

:net_monitor
cls
echo Press Ctrl + C to stop live monitoring...
timeout /t 2 >nul
PowerShell -Command "while ($true) {
    Get-NetAdapterStatistics | Sort-Object Name | Select-Object Name,ReceivedBytes,SentBytes | Format-Table -AutoSize;
    Start-Sleep 3;
    Clear-Host
}"
goto hacker_menu

:adv_port
cls
set /p target=Enter target IP/domain: 
PowerShell -Command "
1..1024 | ForEach-Object {
    $port = $_
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect('$target', $port, $null, $null)
        $wait = $iar.AsyncWaitHandle.WaitOne(100, $false)
        if ($wait -and $client.Connected) {
            Write-Host 'Port' $port 'is OPEN'
            $client.Close()
        }
    } catch {}
}"
pause
goto hacker_menu

:net_conn
cls
echo Active network connections and their owning processes:
echo.
netstat -ano | findstr /i "established"
echo.
PowerShell -Command "Get-Process | Where-Object { $_.Id -in (Get-NetTCPConnection).OwningProcess } | Select-Object Name,Id | Sort-Object Name | Format-Table"
pause
goto hacker_menu

:fw_rules
cls
PowerShell -Command "Get-NetFirewallRule | Select DisplayName,Direction,Enabled,Action | Format-Table -AutoSize"
pause
goto hacker_menu

:anomaly_scan
cls
echo Suspicious unsigned running processes:
PowerShell -Command "Get-Process | Where-Object { $_.Path -and !(Get-AuthenticodeSignature $_.Path).Status -eq 'Valid' } | Select Name,Path"
echo.
echo Suspicious auto-run services:
PowerShell -Command "Get-Service | Where-Object {$_.StartType -eq 'Auto' -and $_.Status -ne 'Running'} | Select Name,Status,StartType"
pause
goto hacker_menu

:wifi_keys
cls
echo Extracting saved Wi-Fi profiles and keys...
for /f "tokens=4 delims= " %%i in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    echo Profile: %%i
    netsh wlan show profile name="%%i" key=clear | findstr "SSID Key Content"
    echo -------------------------
)
pause
goto hacker_menu

:usb_tracker
cls
echo Connected USB Devices:
PowerShell -Command "Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -like 'USB*' } | Format-Table Class, FriendlyName, InstanceId"
echo.
echo Recently Plugged USBs (if history exists):
PowerShell -Command "Get-WinEvent -LogName Microsoft-Windows-DriverFrameworks-UserMode/Operational | Where-Object { $_.Id -eq 2003 } | Select-Object TimeCreated, Message -First 10 | Format-List"
pause
goto hacker_menu
