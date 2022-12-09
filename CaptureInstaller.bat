:: curl, tar, and VT100 sequences are only available in Windows 10 and later
@echo off
setlocal enabledelayedexpansion
cls

REM Constants
set "NET_download_link=https://download.visualstudio.microsoft.com/download/pr/c6a74d6b-576c-4ab0-bf55-d46d45610730/f70d2252c9f452c2eb679b8041846466/windowsdesktop-runtime-5.0.1-win-x64.exe"
set "CAPTURE_download_link=https://github.com/denverquane/amonguscapture/releases/latest/download/AmongUsCapture.zip"
set "NET_hash=ac1be00ce52296148a84ddbcd92c7a78b1c6e09cf65d23fb2859ef050c3ad87eacf70745deb1cea0c64832486eb0b3470219dcb80ed034419bf6673487f2bac6"
set "net_name=windowsdesktop-runtime-5.0.1-win-x64.exe"
set "zip_name=AmongUsCapture.zip"
set "capture_name=AmongUsCapture.exe"
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"

echo          ----- Automute.us CaptureInstaller -----
echo [    ] Checking for Microsoft Desktop Runtime 5 Dependency

REM The version never went past 5.0.17 so we only have to search for "5.0"
(dotnet --list-runtimes | find "Microsoft.WindowsDesktop.App 5.0" >nul) && goto :checkForCapture

:installDesktopRuntime
curl -kL# "%NET_download_link%" -o "%net_name%"
echo %ESC%[3;1H%ESC%[2K
for /f "delims=" %%A in ('certutil -hashfile "%net_name%" sha512 ^| find /v "hash"') do (
	if not "%%A"=="%NET_hash%" goto :installDesktopRuntime
)
curl -kLs "https://raw.githubusercontent.com/automuteus/capture-install/main/resetvars.vbs" -o "%TEMP%\resetvars.vbs"
start "" "%TEMP%\%net_name%" /passive /install /norestart

:detectIfDoneInstall
(dotnet --list-runtimes | find "Microsoft.WindowsDesktop.App 5.0" >nul) || (
	timeout /t 2 >nul
	cscript /nologo "%TEMP%\resetvars.vbs"
	
	REM Despite the name, this is actually a completely unrelated script that
	REM simply resets the default system variables to the values that they had
	REM when the command prompt was first started.
	call "%TEMP%\CaptureInstaller.bat"
	(tasklist | find "windowsdesktop-runtime-5." >nul) || (
		echo %ESC%[2;2H%ESC%[31mFAIL%ESC%[0m
		exit /b
	)
	goto :detectIfDoneInstall
)

taskkill /f /im "%net_name%" 2>nul
del "%TEMP%\%net_name%" "%TEMP%\resetvars.vbs" "%TEMP%\CaptureInstaller.bat"

:checkForCapture
echo %ESC%[2;2H%ESC%[32mPASS%ESC%[0m
if exist "%capture_name%" goto :launchCapture
if exist "%zip_name%" goto :unZip

:installCapture
echo [    ] Downloading AutoMuteUs Capture
curl -kLO# "%CAPTURE_download_link%"
echo %ESC%[4;1H%ESC%[2K
if not exist "%zip_name%" (
	echo %ESC%[2;2H%ESC%[31mFAIL%ESC%[0m
	exit /b
)

:unZip
echo %ESC%[3;2H%ESC%[32mPASS%ESC%[0m
echo [    ] Extracting AutoMuteUs Capture
tar -xf "%zip_name%"
if not exist "%capture_name%" (
	echo %ESC%[4;1H%ESC%[31mFAIL%ESC%[0m
	exit /b
)
echo %ESC%[4;2H%ESC%[32mPASS%ESC%[0m
del "%zip_name%

:launchCapture
start "" "%capture_name%"
