@Echo off
@powershell -window hidden -command ""
Mode 80,3 & color 0A

Set NETdownloadLink=https://download.visualstudio.microsoft.com/download/pr/f3bb58e7-45e1-46ef-9b90-877a450e345e/b18e3d2c429422e9c1238c9b66ded855/dotnet-runtime-5.0.9-win-x64.exe

Set CAPTUREdownloadlink=https://github.com/automuteus/amonguscapture/releases/latest/download/AmongUsCapture.zip
Set NET5HASH=fb2312b7ddf859de13d04138396901d9
Set zipName=AmongUsCapture.zip
Set captureName=AmongUsCapture.exe


REM Color stuff -----
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
) 
REM -----------

cmd /c "dotnet --list-runtimes" > "%TEMP%\desktopRuntimes.txt"
find "Microsoft.NETCore.App 5.0.9" %TEMP%\desktopRuntimes.txt && (
  del "%TEMP%\desktopRuntimes.txt"
  REM .Net Runtime Already installed
  goto checkForCapture
  
) || (
  del "%TEMP%\desktopRuntimes.txt"
  REM .Runtime Not installed
  goto checkSumNetRuntime
)

REM ―――――― Check Sums
:checkSumNetRuntime
set "RECEIVED=" & for /F "skip=1 delims=" %%H in ('
    2^> nul CertUtil -hashfile "%TEMP%\windowsdesktop-runtime-5.0.9-win-x64.exe" md5
') do if not defined RECEIVED set "RECEIVED=%%H"
if "%NET5HASH%"=="%RECEIVED%" (
    REM Correct hash
    goto launchNetRuntime
) else (  
    REM Wrong Hash
    goto installNetRuntime
)
REM ――――――――――――――――――

:installNetRuntime
cls
@Echo off
cls
@powershell -window normal -command ""
call :colorEcho 0A "        ---Downloading .NET 5 Desktop Runtime Installer (dependency)---"
echo.
echo.
curl -# "%NETdownloadLink%" -o "%TEMP%\windowsdesktop-runtime-5.0.9-win-x64.exe"
@powershell -window hidden -command ""
goto checkSumNetRuntime

:launchNetRuntime
@powershell -window hidden -command ""

@REM curl -LJs "https://raw.githubusercontent.com/automuteus/capture-install/main/resetvars.vbs" -o "%TEMP%\resetvars.vbs"
@REM curl isnt working for some reason, so instead I am using a powershell command that does the same thing
powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/automuteus/capture-install/main/resetvars.vbs -Outfile '%TEMP%\resetvars.vbs'"

start "" "%TEMP%\windowsdesktop-runtime-5.0.9-win-x64.exe" /passive /install /norestart
goto detectIfdoneInstall

:detectIfdoneInstall
cmd /c "dotnet --list-runtimes" > "%TEMP%\desktopRuntimes.txt"
find "Microsoft.NETCore.App 5.0.9" %TEMP%\desktopRuntimes.txt && (
  REM .NET 5 is done installing
  echo TEST
  del "%TEMP%\desktopRuntimes.txt"
  taskkill /im "windowsdesktop-runtime-5.0.9-win-x64.exe" /f
  del "%TEMP%\windowsdesktop-runtime-5.0.9-win-x64.exe"
  del "%TEMP%\resetvars.vbs"
  goto checkForCapture
) || (
  REM Repeat install check
  del "%TEMP%\desktopRuntimes.txt"
  Timeout 2
  %TEMP%\resetvars.vbs
  call "%TEMP%\CaptureInstaller.bat"
  tasklist.exe | findstr "windowsdesktop-runtime-5." > nul
  if errorlevel 1 (
    goto EOF
  )
  goto detectIfdoneInstall
)

:checkForCapture
echo HI
if EXIST "%captureName%" ( goto launchCapture )
if EXIST "%zipName%" ( goto unZip )
if not EXIST "%captureName%" ( goto installCapture )

:installCapture
cls
@Echo off
cls
@powershell -window normal -command ""
call :colorEcho 0A "                      ---Downloading AutoMuteUs Capture---"
echo.
echo.
curl -LJ# "%CAPTUREdownloadLink%" -o "%~dp0%zipName%"
goto :unZip

:unZip
cls
@Echo off
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
@Echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
REM --------


:EOF
