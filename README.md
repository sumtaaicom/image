# LG전자 이미지 AI 합성 서비스

n8n 기반 제품 이미지 자동 추출 및 AI 합성 서비스

## 빠른 시작

### 1. 사전 요구사항

- Docker & Docker Compose 설치
- API 키 발급 (아래 참조)

### 2. 환경 설정

```bash
# 프로젝트 폴더로 이동
cd lg-image-service

# 환경 파일 생성
cp .env.example .env

# .env 파일 편집하여 API 키 입력
nano .env  # 또는 선호하는 에디터 사용
```

### 3. 서비스 시작

**개발 모드 (로컬 테스트용)**
```bash
docker-compose up -d
```
- n8n 관리자: http://localhost:5678
- 프론트엔드: `frontend/index.html`을 브라우저에서 직접 열기

**프로덕션 모드 (Nginx 포함)**
```bash
docker-compose -f docker-compose.prod.yml up -d
```
- 서비스: http://localhost

### 4. n8n 워크플로우 가져오기

1. http://localhost:5678 접속
2. 최초 접속 시 계정 생성
3. 좌측 메뉴 > Workflows > Import
4. `workflows/` 폴더의 JSON 파일들을 순서대로 가져오기:
   - `image-extraction-workflow.json`
   - `image-synthesis-workflow.json`
5. 각 워크플로우 우측 상단 "Active" 토글 ON

---

## 필요한 API 키

| API | 용도 | 발급 방법 |
|-----|------|----------|
| **Google Gemini** (필수) | 이미지 합성 | [ai.google.dev](https://ai.google.dev) > Get API Key |
| **Jina AI** (권장) | 웹 스크래핑 | [jina.ai](https://jina.ai) > 회원가입 후 API Key |
| Replicate (선택) | 이미지 합성 | [replicate.com](https://replicate.com) |
| OpenAI (선택) | DALL-E 3 | [platform.openai.com](https://platform.openai.com) |
| Stability AI (선택) | SDXL | [platform.stability.ai](https://platform.stability.ai) |

---

## 프로젝트 구조

```
lg-image-service/
├── docker-compose.yml          # 개발용 Docker 설정
├── docker-compose.prod.yml     # 프로덕션용 (Nginx 포함)
├── .env.example                # 환경변수 템플릿
├── .env                        # 실제 환경변수 (git 제외)
├── workflows/
│   ├── image-extraction-workflow.json   # 이미지 추출 워크플로우
│   └── image-synthesis-workflow.json    # 이미지 합성 워크플로우
├── frontend/
│   └── index.html              # 채팅 UI
└── nginx/
    └── nginx.conf              # 리버스 프록시 설정
```

---

## 워크플로우 설명

### 1. 이미지 추출 워크플로우

```
URL 입력 → Jina AI 스크래핑 → 이미지 URL 추출 → 결과 반환
```

- 엔드포인트: `POST /webhook/extract-images`
- 입력: `{ "urls": ["https://lg.com/..."] }`
- 출력: `{ "images": ["url1", "url2", ...] }`

### 2. 이미지 합성 워크플로우

```
합성 명령 → API 분기 → Gemini/Replicate/OpenAI/Stability → 결과 반환
```

- 엔드포인트: `POST /webhook/synthesize-image`
- 입력:
  ```json
  {
    "prompt": "TV 위에 사운드바 배치",
    "images": ["url1", "url2"],
    "apiProvider": "gemini"
  }
  ```
- 출력: `{ "success": true, "imageUrl": "...", "imageBase64": "..." }`

---

## 문제 해결

### n8n 접속 안 됨
```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs n8n
```

### 워크플로우 실행 오류
1. n8n 관리자 페이지에서 워크플로우가 "Active" 상태인지 확인
2. 환경변수(API 키)가 올바르게 설정되었는지 확인
3. Executions 탭에서 상세 오류 메시지 확인

### CORS 오류
프론트엔드를 `file://` 프로토콜로 열면 CORS 오류 발생 가능
- 해결: 프로덕션 모드(Nginx)로 실행하거나 로컬 웹서버 사용

---

## 서비스 관리

```bash
# 시작
docker-compose up -d

# 중지
docker-compose down

# 로그 확인
docker-compose logs -f

# 재시작
docker-compose restart

# 완전 삭제 (데이터 포함)
docker-compose down -v
```

---

## 보안 체크리스트

- [ ] `.env` 파일이 `.gitignore`에 포함되어 있는지 확인
- [ ] 프로덕션에서 HTTPS 설정
- [ ] 강력한 PostgreSQL 비밀번호 사용
- [ ] 필요시 IP 화이트리스트 설정
- [ ] Phase 2에서 사용자 인증 추가

---

## 다음 단계 (Phase 2)

- [ ] 사용자 인증 (SSO/OAuth)
- [ ] 대화 히스토리 저장
- [ ] 이미지 갤러리
- [ ] 사용량 모니터링
