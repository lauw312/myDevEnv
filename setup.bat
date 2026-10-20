```bat
@echo off
setlocal
chcp 65001 >nul
title myDevEnv - Windows Development Setup

cd /d "%~dp0"

echo.
echo ==========================================
echo       myDevEnv Development Setup
echo ==========================================
echo.

:: 1. Git 확인 및 설치
where git >nul 2>&1
if errorlevel 1 (
    echo [1/4] Git 설치 중...
    where winget >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] winget을 찾을 수 없습니다.
        echo Windows 앱 설치 관리자를 설치한 후 다시 실행하세요.
        pause
        exit /b 1
    )
    winget install --id Git.Git --exact --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo [ERROR] Git 설치 실패. 터미널을 다시 열고 재실행하세요.
        pause
        exit /b 1
    )
    echo Git 설치가 완료되었습니다. 새 터미널에서 다시 실행해야 할 수 있습니다.
    pause
    exit /b 0
)

:: 2. 개발 도구 설치
echo [2/4] 개발 도구 설치 및 확인...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\bootstrap-windows.ps1"
if errorlevel 1 (
    echo [ERROR] 개발 도구 설치 단계에서 오류가 발생했습니다.
    pause
    exit /b 1
)

:: 3. 환경변수 파일 준비
echo.
echo [3/4] 환경변수 파일 확인...
if not exist "%~dp0.env" (
    if exist "%~dp0.env.example" (
        copy "%~dp0.env.example" "%~dp0.env" >nul
        echo .env 파일을 생성했습니다. 필요하면 값을 수정하세요.
    ) else (
        echo [WARNING] .env.example 파일이 없습니다.
    )
) else (
    echo 기존 .env 파일을 유지합니다.
)

:: 4. Docker 데이터베이스 실행
echo.
echo [4/4] Docker 데이터베이스 실행...
where docker >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Docker 명령어를 찾을 수 없습니다.
    echo Docker Desktop 설치 후 터미널을 다시 열어 재실행하세요.
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo Docker Desktop이 실행 중이 아닙니다.
    echo Docker Desktop을 실행하고 엔진이 준비되면 setup.bat을 다시 실행하세요.
    pause
    exit /b 1
)

docker compose up -d
if errorlevel 1 (
    echo [ERROR] 데이터베이스 실행 실패. Docker 로그를 확인하세요.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo       개발환경 설정 완료
echo ==========================================
docker compose ps
echo.
pause
exit /b 0
```