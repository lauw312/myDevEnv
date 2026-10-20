
$ErrorActionPreference = "Stop"

# Windows 개발환경 자동 설치 스크립트
# 기존에 설치된 도구는 건너뛰고 누락된 도구만 설치합니다.

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget을 찾을 수 없습니다. Windows 앱 설치 관리자(App Installer)를 확인하세요."
}

$script:Failures = [System.Collections.Generic.List[string]]::new()

function Install-Package {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter(Mandatory)]
        [string]$Command
    )

    Write-Host "`n===== $Name =====" -ForegroundColor Cyan

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Host "$Name : 이미 설치되어 있습니다." -ForegroundColor Green
        return
    }

    Write-Host "$Name 설치를 시작합니다." -ForegroundColor Yellow

    try {
        & winget install --id $Id --exact `
            --accept-package-agreements `
            --accept-source-agreements `
            --disable-interactivity

        if ($LASTEXITCODE -ne 0) {
            throw "winget 종료 코드: $LASTEXITCODE"
        }

        Write-Host "$Name 설치 명령이 완료되었습니다." -ForegroundColor Green
    }
    catch {
        $script:Failures.Add("$Name : $($_.Exception.Message)")
        Write-Warning "$Name 설치에 실패했습니다."
    }
}

Install-Package -Name "Git" `
    -Id "Git.Git" -Command "git"

Install-Package -Name "Python 3.13" `
    -Id "Python.Python.3.13" -Command "python"

Install-Package -Name "Node.js LTS" `
    -Id "OpenJS.NodeJS.LTS" -Command "node"

Install-Package -Name "Java JDK 21" `
    -Id "EclipseAdoptium.Temurin.21.JDK" -Command "java"

Install-Package -Name "Visual Studio Code" `
    -Id "Microsoft.VisualStudioCode" -Command "code"

Install-Package -Name "Docker Desktop" `
    -Id "Docker.DockerDesktop" -Command "docker"

Write-Host "`n===== 개발 도구 버전 확인 =====" -ForegroundColor Cyan

$checks = @(
    @{ Name = "Git";       File = "git.exe";    Args = @("--version") },
    @{ Name = "Python";    File = "python.exe"; Args = @("--version") },
    @{ Name = "Node.js";   File = "node.exe";   Args = @("--version") },
    @{ Name = "npm";       File = "npm.cmd";    Args = @("--version") },
    @{ Name = "Java";      File = "java.exe";   Args = @("-version") },
    @{ Name = "VS Code";   File = "code.cmd";   Args = @("--version") },
    @{ Name = "Docker";    File = "docker.exe"; Args = @("--version") }
)

foreach ($check in $checks) {
    $command = Get-Command $check.File -ErrorAction SilentlyContinue

    if (-not $command) {
        Write-Warning "$($check.Name): 명령어를 찾을 수 없습니다. 새 PowerShell 창에서 다시 확인하세요."
        continue
    }

    try {
        & $command.Source @($check.Args)
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "$($check.Name): 버전 확인 명령이 실패했습니다."
        }
    }
    catch {
        Write-Warning "$($check.Name): 확인 실패 - $($_.Exception.Message)"
    }
}

Write-Host "`n===== 설치 작업 요약 =====" -ForegroundColor Cyan

if ($script:Failures.Count -gt 0) {
    $script:Failures | ForEach-Object {
        Write-Host $_ -ForegroundColor Red
    }
    Write-Warning "일부 설치가 실패했습니다. 위 오류를 확인하세요."
}
else {
    Write-Host "설치 명령 처리가 완료되었습니다." -ForegroundColor Green
}

Write-Host "Docker 엔진과 데이터베이스 상태는 별도로 검증해야 합니다."
Write-Host "설치 직후 명령어가 인식되지 않으면 PowerShell을 다시 열어 확인하세요."
