@Echo Off
powershell -window hidden -command ""
Mode 80,3 & color 0A

Set NETdownloadLink=https://download.visualstudio.microsoft.com/download/pr/c6a74d6b-576c-4ab0-bf55-d46d45610730/f70d2252c9f452c2eb679b8041846466/windowsdesktop-runtime-5.0.1-win-x64.exe
Set CAPTUREdownloadlink=https://github.com/automuteus/amonguscapture/releases/latest/download/AmongUsCapture.zip
Set NET5HASH=a7f9fc194371e125de609c709b52b1ac
Set zipName=AmongUsCapture.zip
Set captureName=AmongUsCapture.exe


REM Color stuff -----
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
) 
REM -----------

cmd /c "dotnet --list-runtimes" > "%TEMP%\desktopRuntimes.txt"
find "Microsoft.WindowsDesktop.App 5.0" %TEMP%\desktopRuntimes.txt && (
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
    2^> nul CertUtil -hashfile "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe" md5
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
@powershell -window normal -command ""
call :colorEcho 0A "        ---Downloading .NET 5 Desktop Runtime Installer (dependency)---"
echo.
echo.
curl -k# "%NETdownloadLink%" -o "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe"
@powershell -window hidden -command ""
goto checkSumNetRuntime

:launchNetRuntime
powershell -window hidden -command ""

curl -kLs "https://raw.githubusercontent.com/automuteus/capture-install/main/resetvars.vbs" -o "%TEMP%\resetvars.vbs"
start "" "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe" /passive /install /norestart
goto detectIfdoneInstall

:detectIfdoneInstall
cmd /c "dotnet --list-runtimes" > "%TEMP%\desktopRuntimes.txt"
find "Microsoft.WindowsDesktop.App 5.0.1" %TEMP%\desktopRuntimes.txt && (
  REM .NET 5 is done installing
  del "%TEMP%\desktopRuntimes.txt"
  taskkill /im "windowsdesktop-runtime-5.0.1-win-x64.exe" /f
  del "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe"
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
curl -kLJ# "%CAPTUREdownloadLink%" -o "%~dp0%zipName%"
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
