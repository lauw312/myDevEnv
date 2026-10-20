# myDevEnv

Windows 10/11 개발환경 자동 구축 프로젝트입니다. 실행 파일 하나로 개발 도구 설치와 Docker 데이터베이스 실행을 간편하게 진행합니다.

## 실행 방법

1. GitHub 저장소를 내려받거나 복제합니다.
2. `setup.bat`을 실행합니다.
3. 설치가 완료될 때까지 기다립니다.

```powershell
git clone https://github.com/lauw312/myDevEnv.git
cd myDevEnv
.\setup.bat
```

## 포함된 도구

- Git
- Python 3.13
- Node.js LTS 및 npm
- Eclipse Temurin JDK 21
- Visual Studio Code
- Docker Desktop
- PostgreSQL 16
- MySQL 8.4
- MariaDB 11.4

## 주요 파일

| 파일 | 설명 |
|---|---|
| `setup.bat` | 개발환경 설정 실행 파일 |
| `scripts/bootstrap-windows.ps1` | 개발 도구 설치 및 확인 |
| `compose.yaml` | 데이터베이스 컨테이너 설정 |
| `.env.example` | 환경변수 예시 |
| `.gitignore` | Git 제외 파일 설정 |

## 데이터베이스 포트

| 데이터베이스 | 포트 |
|---|---:|
| PostgreSQL | `5432` |
| MySQL | `3306` |
| MariaDB | `3307` |

## 주의 사항

- 인터넷 연결이 필요합니다.
- Docker Desktop 최초 설치 후 WSL2 설정이나 재부팅이 필요할 수 있습니다.
- 기존 `.env` 파일은 덮어쓰지 마세요.
- `.env`에는 비밀번호 등 민감한 정보가 포함될 수 있으므로 GitHub에 업로드하지 마세요.

## Docker 명령어

```powershell
# 데이터베이스 실행
docker compose up -d

# 실행 상태 확인
docker compose ps

# 로그 확인
docker compose logs

# 컨테이너 중지
docker compose down
```
