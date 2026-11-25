@echo off
title Rebuilding NovaVault Windows Release .exe
cd /d "D:\passwrdmanger\novavault_flutter"
echo ==============================================
echo   Rebuilding NovaVault Windows Native .exe
echo ==============================================
call D:\dev\flutter\bin\flutter.bat build windows --release
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] NovaVault.exe rebuilt successfully!
    echo Location: D:\passwrdmanger\novavault_flutter\build\windows\x64\runner\Release\novavault_flutter.exe
    pause
) else (
    echo.
    echo [ERROR] Build failed. Please check errors above.
    pause
)
