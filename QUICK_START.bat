@echo off
title Video Downloader Pro - Quick Start
color 0A

echo.
echo  ██╗   ██╗██╗██████╗ ███████╗ ██████╗ 
echo  ██║   ██║██║██╔══██╗██╔════╝██╔═══██╗
echo  ██║   ██║██║██║  ██║█████╗  ██║   ██║
echo  ╚██╗ ██╔╝██║██║  ██║██╔══╝  ██║   ██║
echo   ╚████╔╝ ██║██████╔╝███████╗╚██████╔╝
echo    ╚═══╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝ 
echo.
echo        DOWNLOADER PRO - QUICK START
echo        =============================
echo.

cd /d "%~dp0"


set PYTHON_PATH="C:\Program Files\Python313\python.exe"
if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Virtual environment not found!
    echo.
    echo Please run setup first:
    echo   1. %PYTHON_PATH% -m venv .venv
    echo   2. .venv\Scripts\pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

echo [INFO] Starting all servers...
echo.

".venv\Scripts\python.exe" start_servers.py
