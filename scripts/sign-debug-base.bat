@echo off
rem Re-sign unpackage\debug\android_debug.apk with the device platform key (in place).
rem Usage: build the custom debug base in HBuilderX, then double-click this file.

set "APK=%~dp0..\unpackage\debug\android_debug.apk"
if not exist "%APK%" (
	echo [ERROR] APK not found: %APK%
	echo Build the custom debug base in HBuilderX first.
	pause
	exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0platform-sign.ps1" -Apk "%APK%" -InPlace
if errorlevel 1 (
	echo.
	echo [FAILED] See the messages above.
) else (
	echo.
	echo [OK] If the device has an old-signature build, run: adb uninstall ming.adscreen
	echo      Old package uni.app.UNIDDCA69C is no longer used: adb uninstall uni.app.UNIDDCA69C
)
pause