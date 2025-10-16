@echo off
REM Check if the current privileges are Administrator
net session >nul 2>&1

REM Check the existence of the old PowerShell (powershell.exe) and print version if available (Optional check)
where powershell.exe >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: powershell.exe not found on system PATH.
    pause
    exit /b 1
)
powershell -Command "$PSVersionTable.PSVersion.ToString()"

if %errorLevel% neq 0 (
    REM If not Administrator, prompt for UAC elevation to run the script
    echo Requesting Administrator privileges to run Register_Task.ps1...
    
    REM Use powershell.exe to start the UAC prompt and execute the script
    REM We use Start-Process -Verb RunAs to request elevation.
    REM The command must be meticulously escaped for CMD/Batch.
    powershell -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0Register_Task.ps1\"' -Verb RunAs"
    
) else (
    REM Already running with Administrator privileges, execute the script directly
    echo Running Register_Task.ps1 with Administrator privileges...
    
    REM Execute the script directly using powershell.exe
    powershell -ExecutionPolicy Bypass -File "%~dp0Register_Task.ps1"
)

echo.
pause