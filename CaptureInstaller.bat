@Echo Off
powershell -window hidden -command ""
Mode 80,3 & color 0A

Set CAPTUREdownloadlink=https://github.com/automuteus/amonguscapture/releases/latest/download/AmongUsCapture.zip
Set zipName=AmongUsCapture.zip
Set captureName=AmongUsCapture.exe


REM Color stuff -----
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
) 
REM -----------

:checkForCapture
if EXIST "%captureName%" ( goto launchCapture )
if EXIST "%zipName%" ( goto unZip )
if not EXIST "%captureName%" ( goto installCapture )

:installCapture
cls
echo off
cls
@powershell -window normal -command ""
call :colorEcho 0A "                      ---Downloading AutoMuteUs Capture---"
echo.
echo.
curl -LJ# "%CAPTUREdownloadLink%" -o "%~dp0%zipName%"
goto :unZip

:unZip
cls
echo off
cls
@powershell -window normal -command ""
call :colorEcho 0A "                          ---Inflating the Zip---"
echo.
Powershell -Command "Expand-Archive -ErrorAction Stop -Force '.\%zipName%' '.\'"
if errorlevel 1 (
  goto installCapture
)
DEL ".\%zipName%"
goto launchCapture

:launchCapture
start "%~dp0" "%captureName%"
del "%~f0"
goto EOF

REM Color Stuff ----
:colorEcho
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
REM --------

:EOF
