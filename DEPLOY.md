# Railway 배포 가이드

이 문서는 LG 이미지 AI 합성 서비스를 Railway에 배포하는 방법을 설명합니다.

## 아키텍처

```
Railway 프로젝트
├── n8n 서비스 (Dockerfile.n8n)
│   └── 워크플로우 엔진 + 웹훅 API
│
├── 프론트엔드 서비스 (Dockerfile.frontend)
│   └── Nginx + 정적 파일
│
└── PostgreSQL (Railway 애드온)
    └── n8n 데이터 저장
```

## 배포 단계

### 1. Railway 프로젝트 생성

1. [Railway](https://railway.app) 로그인
2. **New Project** 클릭
3. **Deploy from GitHub repo** 선택
4. 이 저장소 연결

### 2. PostgreSQL 추가

1. 프로젝트에서 **+ New** 클릭
2. **Database** → **Add PostgreSQL** 선택
3. 자동으로 DB가 생성됨

### 3. n8n 서비스 배포

1. **+ New** → **GitHub Repo** 선택 (같은 저장소)
2. **Settings** 탭에서:
   - **Root Directory**: `/` (루트)
   - **Dockerfile Path**: `Dockerfile.n8n`
3. **Variables** 탭에서 환경변수 설정:

```env
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}/

# PostgreSQL 연결 (Railway 변수 참조)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=${{Postgres.PGHOST}}
DB_POSTGRESDB_PORT=${{Postgres.PGPORT}}
DB_POSTGRESDB_DATABASE=${{Postgres.PGDATABASE}}
DB_POSTGRESDB_USER=${{Postgres.PGUSER}}
DB_POSTGRESDB_PASSWORD=${{Postgres.PGPASSWORD}}

# API 키
GEMINI_API_KEY=<your-key>
JINA_API_KEY=<your-key>
```

4. **Networking** 탭에서:
   - **Generate Domain** 클릭
   - 생성된 도메인 메모 (예: `lg-n8n.railway.app`)

### 4. 프론트엔드 서비스 배포

1. **+ New** → **GitHub Repo** 선택 (같은 저장소)
2. **Settings** 탭에서:
   - **Root Directory**: `/` (루트)
   - **Dockerfile Path**: `Dockerfile.frontend`
3. **Variables** 탭에서:

```env
# n8n 서비스의 Railway 도메인으로 설정
N8N_WEBHOOK_URL=https://<n8n-domain>.railway.app/webhook/
```

4. **Networking** 탭에서:
   - **Generate Domain** 클릭
   - 이 도메인이 직원들에게 공유할 URL

### 5. 워크플로우 설정

1. n8n 도메인 접속 (예: `https://lg-n8n.railway.app`)
2. 워크플로우 import:
   - **Settings** → **Import from file**
   - `workflows/image-extraction-workflow.json` import
   - `workflows/image-synthesis-workflow.json` import
3. 각 워크플로우 **Activate** 토글 켜기

### 6. 테스트

1. 프론트엔드 도메인 접속
2. LG 제품 URL 입력하여 이미지 추출 테스트
3. 이미지 선택 후 AI 합성 테스트

## 직원 접속 방법

프론트엔드 URL만 공유하면 됩니다:
```
https://<frontend-domain>.railway.app
```

브라우저에서 바로 사용 가능하며, 별도 설치 불필요.

## 비용

**Railway Hobby Plan: $5/월** (모든 서비스 포함)

- n8n + PostgreSQL + 프론트엔드 모두 포함
- 월 $5 크레딧 제공 (일반적인 사용량 충분)
- 512MB RAM / 서비스
- 무료 SSL 인증서

## 문제 해결

### 웹훅이 작동하지 않음
- n8n 서비스의 `WEBHOOK_URL` 환경변수 확인
- 워크플로우가 활성화되어 있는지 확인

### 이미지 추출 실패
- `JINA_API_KEY`가 설정되어 있는지 확인
- n8n 로그에서 오류 확인

### 502 Bad Gateway
- n8n 서비스가 정상 실행 중인지 확인
- PostgreSQL 연결 환경변수 확인

## 로컬 개발

로컬에서 계속 개발하려면:
```bash
docker-compose up -d
```

프론트엔드는 자동으로 localhost 감지하여 로컬 n8n으로 연결됩니다.
