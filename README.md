# myDevEnv — Windows 개발환경 가이드

Windows 10/11에서 Python, Node.js, Java 개발환경과 Docker 기반 데이터베이스를 구성하는 프로젝트입니다.

## 1. 처음 실행하기

저장소를 내려받은 뒤 프로젝트 폴더에서 `setup.bat`을 실행합니다.

```powershell
git clone https://github.com/lauw312/myDevEnv.git
cd myDevEnv
.\setup.bat
```

필요한 도구를 설치하고 Docker 데이터베이스를 실행합니다. Docker Desktop 최초 설치 후에는 WSL2 설정이나 재부팅이 필요할 수 있습니다.

## 2. 폴더 및 파일 구조

```text
myDevEnv/
├── setup.bat                  # 전체 환경 설정 시작점
├── README.md                  # 프로젝트 사용 설명서
├── compose.yaml               # DB 컨테이너 및 포트 설정
├── .env                       # 실제 환경변수 및 DB 비밀번호 (Git 제외)
├── .env.example               # 환경변수 예시 (Git 관리 대상)
├── .gitignore                 # Git에서 제외할 파일
└── scripts/
    └── bootstrap-windows.ps1  # 개발 도구 설치 및 버전 확인
```

| 파일 | 용도 |
|---|---|
| `setup.bat` | 설치 과정을 시작하고 단계별 스크립트를 실행 |
| `scripts/bootstrap-windows.ps1` | Git, Python, Node.js, Java, VS Code, Docker Desktop 설치 확인 및 처리 |
| `compose.yaml` | PostgreSQL, MySQL, MariaDB 컨테이너 설정 |
| `.env` | DB 사용자, 비밀번호, 데이터베이스 이름 등 실제 설정 |
| `.env.example` | 새 PC에서 `.env`를 생성하기 위한 템플릿 |
| `.gitignore` | 비밀번호 파일 및 불필요한 파일의 업로드 방지 |

## 3. 설치되는 개발 도구

| 도구 | 용도 |
|---|---|
| Git | 소스 코드 버전 관리 |
| Python 3.13 | Python 애플리케이션 개발 |
| Node.js LTS / npm | JavaScript 및 Node.js 개발 |
| Eclipse Temurin JDK 21 | Java 애플리케이션 개발 |
| Visual Studio Code | 코드 편집 및 개발 작업 |
| Docker Desktop | 컨테이너 실행 환경 |
| Docker Compose | 여러 데이터베이스를 한 번에 실행 |

## 4. 데이터베이스 구성

데이터베이스는 Windows에 직접 설치하지 않고 Docker 컨테이너로 실행합니다.

| DB | 컨테이너 이미지 | Windows 접속 주소 | 기본 포트 |
|---|---|---|---:|
| PostgreSQL | `postgres:16` | `localhost:5432` | 5432 |
| MySQL | `mysql:8.4` | `localhost:3306` | 3306 |
| MariaDB | `mariadb:11.4` | `localhost:3307` | 3307 |

MariaDB는 MySQL과 호환되는 부분이 많지만 별도의 데이터베이스 서버이므로, 이 프로젝트에서는 포트 `3307`을 사용해 MySQL과 동시에 실행합니다.

**중요:** 위 주소와 포트는 현재 Compose 설정 기준입니다. 실제 연결 정보는 `compose.yaml`의 포트 매핑을 확인하세요.

## 5. DB 연결 정보 확인하기

### 환경변수 파일

`.env.example`을 복사해 `.env`를 만들 수 있습니다.

```powershell
Copy-Item .env.example .env
```

`.env`가 이미 있다면 덮어쓰지 마세요.

`.env`에서 다음과 같은 설정 항목을 확인합니다. 실제 변수 이름은 프로젝트 파일에 정의된 이름을 따릅니다.

- 데이터베이스 이름
- 사용자 이름
- 비밀번호
- 포트 및 연결 관련 옵션

비밀번호는 README나 소스 코드에 직접 기록하지 말고 환경변수 또는 안전한 비밀정보 관리 방식을 사용합니다.

### 컨테이너 상태 확인

```powershell
docker compose ps
```

실행 로그 확인:

```powershell
docker compose logs --tail=100
```

특정 서비스만 확인하려면:

```powershell
docker compose logs postgres
docker compose logs mysql
docker compose logs mariadb
```

위 서비스 이름은 `compose.yaml`에 정의된 서비스 이름과 일치해야 합니다.

## 6. 애플리케이션에서 DB 연결하기

모든 예시에서 연결 주소는 **애플리케이션이 Windows에서 직접 실행되는 경우**를 기준으로 합니다. 비밀번호와 데이터베이스 이름은 `.env`에서 확인해 넣습니다.

### PostgreSQL — Python

필요한 패키지:

```powershell
python -m pip install "psycopg[binary]"
```

연결 예시:

```python
import os
import psycopg

conn = psycopg.connect(
    host="localhost",
    port=5432,
    dbname=os.environ["PGDATABASE"],
    user=os.environ["PGUSER"],
    password=os.environ["PGPASSWORD"],
)

print("PostgreSQL 연결 성공")
conn.close()
```

`PGDATABASE`, `PGUSER`, `PGPASSWORD`는 예시 환경변수 이름입니다. `.env`에 해당 이름이 실제로 정의되어 있지 않으면 프로젝트의 변수 이름에 맞추거나 실행 환경에 별도로 설정해야 합니다. Python은 `.env` 파일을 자동으로 읽지 않습니다.

### MySQL — Python

필요한 패키지:

```powershell
python -m pip install mysql-connector-python
```

연결 예시:

```python
import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    port=3306,
    user="YOUR_DB_USER",
    password="YOUR_DB_PASSWORD",
    database="YOUR_DB_NAME",
)

print("MySQL 연결 성공")
conn.close()
```

`YOUR_DB_USER`, `YOUR_DB_PASSWORD`, `YOUR_DB_NAME`은 실제 `.env` 설정으로 교체합니다.

### MariaDB — Python

필요한 패키지:

```powershell
python -m pip install mariadb
```

연결 예시:

```python
import mariadb

conn = mariadb.connect(
    host="localhost",
    port=3307,
    user="YOUR_DB_USER",
    password="YOUR_DB_PASSWORD",
    database="YOUR_DB_NAME",
)

print("MariaDB 연결 성공")
conn.close()
```

MariaDB Connector/Python 설치에는 환경에 따라 추가 빌드 의존성이 필요할 수 있습니다. 연결 정보는 `compose.yaml` 및 `.env`를 기준으로 확인합니다.

### Node.js

Node.js 프로젝트에서는 DB 종류에 맞는 드라이버를 설치합니다.

```powershell
# PostgreSQL
npm install pg

# MySQL 또는 MariaDB
npm install mysql2
```

드라이버 설치만으로 연결이 완료되는 것은 아닙니다. `.env`의 실제 변수 이름에 맞게 접속 설정을 작성하고, Node.js에서 환경변수를 읽도록 구성해야 합니다.

### Java

Java 애플리케이션에서는 JDBC 드라이버를 사용합니다.

| DB | JDBC 드라이버 |
|---|---|
| PostgreSQL | PostgreSQL JDBC Driver |
| MySQL | MySQL Connector/J |
| MariaDB | MariaDB Connector/J |

일반적인 JDBC URL 형식:

```text
jdbc:postgresql://localhost:5432/데이터베이스명
jdbc:mysql://localhost:3306/데이터베이스명
jdbc:mariadb://localhost:3307/데이터베이스명
```

실제 데이터베이스 이름과 인증 정보는 환경 설정에서 가져옵니다.

## 7. Docker 자주 쓰는 명령어

```powershell
# 컨테이너 실행
docker compose up -d

# 상태 확인
docker compose ps

# 로그 확인
docker compose logs

# 특정 DB 로그 확인
docker compose logs -f postgres

# 컨테이너 중지 및 Compose 네트워크 정리
docker compose down
```

일반적인 `docker compose down`은 컨테이너를 제거하지만, 볼륨을 별도로 제거하지는 않습니다. DB 데이터 보존 여부는 `compose.yaml`의 볼륨 설정을 확인하세요.

**주의:** `docker compose down -v`는 관련 볼륨을 삭제할 수 있으므로 DB 데이터가 필요하다면 사용하지 마세요.

## 8. 문제 해결

### Docker 서버 연결 실패

```powershell
docker info
```

Docker Desktop 실행 상태와 WSL2 설정을 확인합니다.

### DB 접속 거부

1. `docker compose ps`로 컨테이너가 실행 중인지 확인합니다.
2. `docker compose logs postgres` 또는 해당 DB의 로그를 확인합니다.
3. `.env`의 사용자 이름, 비밀번호, DB 이름을 확인합니다.
4. `compose.yaml`의 포트 매핑을 확인합니다.
5. 애플리케이션에서 접속할 때는 `localhost`와 Windows 호스트 포트를 사용합니다.

### 다른 컨테이너에서 DB에 접속할 경우

애플리케이션도 Docker Compose 네트워크 안에 있다면 `localhost` 대신 Compose 서비스 이름과 컨테이너 내부 포트를 사용합니다. 예를 들어 PostgreSQL은 일반적으로 `postgres:5432` 형태입니다. 정확한 서비스 이름은 `compose.yaml`에서 확인합니다.

## 9. 보안 및 Git 관리

- `.env`에는 비밀번호 등 민감한 값이 포함될 수 있으므로 GitHub에 업로드하지 않습니다.
- `.env.example`에는 실제 비밀번호 대신 예시 값이나 빈 값을 사용합니다.
- 비밀번호가 Git에 올라갔다면 파일에서 지우는 것만으로 충분하지 않을 수 있습니다. 노출된 비밀번호를 변경하세요.
- DB 포트를 외부 네트워크에 공개할 때는 방화벽과 인증 설정을 확인하세요.

## 10. 변경사항 저장 및 업로드

```powershell
git status
git add README.md
git commit -m "Document database connections and project structure"
git push
```

---

**기억할 핵심:** `setup.bat`은 설정 시작점, `bootstrap-windows.ps1`은 개발 도구 설치 담당, `compose.yaml`은 DB 컨테이너 담당, `.env`는 실제 접속 설정 담당입니다. 문제가 생기면 먼저 이 네 파일과 `docker compose ps`를 확인하세요.
