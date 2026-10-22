@echo off
setlocal
rem Re-sign a release APK with the device platform key, output xxx-platform.apk (original kept).
rem Usage 1: double-click, uses the newest APK in unpackage\release\apk
rem Usage 2: drag an APK file onto this file

set "RELEASE_DIR=%~dp0..\unpackage\release\apk"
set "APK=%~1"

if "%APK%"=="" (
	for /f "delims=" %%f in ('dir /b /o-d /a-d "%RELEASE_DIR%\*.apk" 2^>nul ^| findstr /v /i /e /l "-platform.apk"') do (
		if not defined APK set "APK=%RELEASE_DIR%\%%f"
	)
)

if "%APK%"=="" (
	echo [ERROR] No APK found in: %RELEASE_DIR%
	echo Build a release package first, or drag an APK onto this file.
	pause
	exit /b 1
)
if not exist "%APK%" (
	echo [ERROR] File not found: %APK%
	pause
	exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0platform-sign.ps1" -Apk "%APK%"
if errorlevel 1 (
	echo.
	echo [FAILED] See the messages above.
) else (
	echo.
	echo [OK] Upload / install the xxx-platform.apk shown above.
)
pause