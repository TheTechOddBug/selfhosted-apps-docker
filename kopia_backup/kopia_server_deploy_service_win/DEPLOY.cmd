@echo off

:: checking if the script is run as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo - Success: Administrative permissions confirmed.
) else (
    echo - RUN AS ADMINISTRATOR
    pause
    exit /B
)

echo - checking for existing Kopia service
sc query Kopia >nul 2>&1
if %errorLevel% == 0 (
    echo - Kopia service already exists, stopping before file copy
    sc stop Kopia >nul 2>&1
    timeout /t 2 >nul
)

echo - checking if C:\Kopia folder exists, creating it if not
if not exist "C:\Kopia\" (
  mkdir C:\Kopia
)

if exist "C:\Kopia\kopia_server_start.cmd" (
  echo - C:\Kopia\kopia_server_start.cmd exists, renaming it with random suffix
  ren "C:\Kopia\kopia_server_start.cmd" "kopia_backup_scipt_%random%.cmd"
)

echo - copying files to C:\Kopia
robocopy "%~dp0\" "C:\Kopia" "kopia.exe" /NDL /NJH /NJS
robocopy "%~dp0\" "C:\Kopia" "kopia_server_start.cmd" /NDL /NJH /NJS
robocopy "%~dp0\" "C:\Kopia" "shawl.exe" /NDL /NJH /NJS
echo.

echo - adding C:\Kopia to PATH
:: checking if PATH does not contain kopia already
for /f "tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path') do set "MACHINE_PATH=%%B"
echo %MACHINE_PATH% | find /I "C:\Kopia" >nul
if errorlevel 1 (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%MACHINE_PATH%;C:\Kopia" /f
)

echo - creting Kopia service
sc query Kopia >nul 2>&1
if %errorLevel% == 0 (
    echo - Kopia service already exists, removing before recreating
    sc delete Kopia >nul 2>&1
    timeout /t 2 >nul
)
C:\Kopia\shawl.exe add --log-dir C:\kopia\Kopia_service_logs --name Kopia -- C:\Kopia\kopia_server_start.cmd

echo - setting Kopia service to start automaticly at boot
sc config Kopia start=auto

echo - start Kopia service
sc start Kopia >nul 2>&1
timeout /t 2 >nul
sc query Kopia | find "RUNNING" >nul
if errorlevel 1 (
    echo - WARNING: Kopia service did not start. Check C:\Kopia\Kopia_service_logs for details.
) else (
    echo - Kopia service started successfully.
)

echo - copying link to Desktop
robocopy "%~dp0\" "%USERPROFILE%\Desktop" "Kopia.url" /NDL /NJH /NJS

echo.
echo --------------------------------------------------------------
echo.
echo DEPLOYMENT DONE
echo KOPIA SERVER CAN NOW BE FIND AT WEB PAGE: localhost:51515
echo A LINK SHOULD BE ON YOUR DESKTOP
echo.
pause
