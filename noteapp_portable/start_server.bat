@echo off
REM NoteApp LAN Chat Server Launcher
REM This script starts the Node.js server in the background

title "NoteApp Server"
color 0A

echo.
echo ======================================
echo   NoteApp - LAN Chat Server Launcher
echo ======================================
echo.

cd /d "%~dp0"

REM Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ERROR: Node.js is not installed or not in PATH
    echo.
    echo Please install Node.js from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo Checking Node.js version...
node --version
echo.

REM Check if server directory exists
if not exist "server\index.js" (
    color 0C
    echo.
    echo ERROR: Server files not found!
    echo Expected: server\index.js
    echo.
    pause
    exit /b 1
)

echo Starting LAN Chat Server...
echo.
echo Server will be available at:
echo   Local: 127.0.0.1:4000
echo.

cd server
node index.js

REM If the server exits
color 0C
echo.
echo Server stopped.
pause
