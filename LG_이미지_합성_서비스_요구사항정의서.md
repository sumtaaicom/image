# LG전자 이미지 합성 서비스 요구사항 정의서

## 1. 프로젝트 개요

### 1.1 프로젝트명
LG전자 제품 이미지 AI 합성 서비스

### 1.2 프로젝트 목적
LG전자 제품 페이지(TV, 스피커바 등)에서 대표 이미지를 자동 추출하고, 사용자의 자연어 명령에 따라 AI 기반으로 이미지를 합성하여 마케팅/홍보 콘텐츠 제작을 지원한다.

### 1.3 프로젝트 범위
- 제품 페이지 URL 입력 및 이미지 자동 추출
- 채팅 인터페이스를 통한 합성 명령 처리
- AI 이미지 합성 및 결과물 출력
- 인증: 1차 개발 후 추가 논의

---

## 2. 기능 요구사항

### 2.1 이미지 추출 기능
| ID | 요구사항 | 우선순위 |
|----|---------|---------|
| FR-001 | 제품 URL 2개 이상 입력 가능 (TV, 스피커바 등) | 필수 |
| FR-002 | + 버튼 클릭 시 각 URL에서 대표 이미지 자동 추출 | 필수 |
| FR-003 | 추출된 이미지 미리보기 표시 | 필수 |
| FR-004 | LG 스펙 페이지 스크래핑 대응 | 필수 |

### 2.2 채팅 인터페이스 기능
| ID | 요구사항 | 우선순위 |
|----|---------|---------|
| FR-005 | n8n Chat Widget 기반 채팅 UI | 필수 |
| FR-006 | 자연어 합성 명령 (예: "TV 위에 스피커바 배치") | 필수 |
| FR-007 | AI 모델 선택 드롭다운 | 필수 |
| FR-008 | 대화 히스토리 유지 | 권장 |

### 2.3 이미지 합성 기능 (멀티 API 지원)
| ID | 요구사항 | 우선순위 |
|----|---------|---------|
| FR-009 | Google Gemini Image API (기본값) | 필수 |
| FR-010 | Replicate Flux 모델 (선택) | 필수 |
| FR-011 | OpenAI DALL-E / GPT-Image (선택) | 권장 |
| FR-012 | Stability AI SDXL (선택) | 권장 |
| FR-013 | 결과 이미지 다운로드 | 필수 |

---

## 3. 기술 아키텍처 (확정)

### 3.1 시스템 구성도
```
[n8n Chat Widget]         [n8n 워크플로우]           [외부 API]
     |                         |                       |
 URL 입력 ──────────────> Webhook Trigger              |
     |                         |                       |
     |                    HTTP Request ──────────> LG 스펙 페이지
     |                         |                       |
     |                    HTML Node (이미지 추출)      |
     |                         |                       |
 채팅 명령 ──────────────> AI Agent                    |
 + API 선택                    |                       |
     |                    Switch Node (API 분기)       |
     |                         ├─────────────────> Gemini
     |                         ├─────────────────> Replicate
     |                         ├─────────────────> OpenAI
     |                         └─────────────────> Stability AI
     |                         |                       |
 결과 표시 <────────────── Respond to Webhook          |
```

### 3.2 기술 스택 (확정)
| 구성 요소 | 기술 선택 | 비고 |
|----------|----------|------|
| 워크플로우 엔진 | n8n (셀프호스팅) | Docker 기반 배포 |
| 프론트엔드 | n8n Chat Widget | 공식 위젯 CDN 사용 |
| 웹 스크래핑 | HTTP Request + HTML Node | LG 스펙 페이지 대응 |
| 동적 스크래핑 | Jina AI Reader API | JS 렌더링 페이지 대응 |
| 이미지 합성 (기본) | Google Gemini Image API | 기본 선택값 |
| 이미지 합성 (선택) | Replicate, OpenAI, Stability AI | Switch 노드로 분기 |

### 3.3 n8n 셀프호스팅 환경
- Docker / Docker Compose 기반
- PostgreSQL (데이터 저장)
- 환경변수로 API 키 관리
- 리버스 프록시 (Nginx/Traefik) + HTTPS

---

## 4. 비기능 요구사항

### 4.1 성능 요구사항
| ID | 요구사항 | 기준값 |
|----|---------|-------|
| NFR-001 | 이미지 추출 응답 시간 | 10초 이내 |
| NFR-002 | 이미지 합성 응답 시간 | 30초 이내 |
| NFR-003 | 동시 사용자 처리 | 10명 이상 |

### 4.2 보안 요구사항 (1차)
| ID | 요구사항 | 상태 |
|----|---------|------|
| NFR-004 | API 키 환경변수 관리 | 1차 구현 |
| NFR-005 | HTTPS 통신 | 1차 구현 |
| NFR-006 | 입력 URL 유효성 검증 | 1차 구현 |
| NFR-007 | 사용자 인증 (SSO 등) | 2차 논의 후 구현 |

---

## 5. 개발 산출물

### 5.1 n8n 워크플로우
1. **이미지 추출 워크플로우**
   - Webhook Trigger (URL 입력 수신)
   - HTTP Request (LG 스펙 페이지 fetch)
   - HTML Node (대표 이미지 URL 추출)
   - Respond to Webhook (이미지 URL 반환)

2. **이미지 합성 워크플로우**
   - Webhook Trigger (합성 명령 + API 선택 수신)
   - AI Agent (자연어 명령 해석)
   - Switch Node (선택된 API로 분기)
     - Gemini 분기
     - Replicate 분기
     - OpenAI 분기
     - Stability AI 분기
   - Respond to Webhook (합성 이미지 반환)

### 5.2 프론트엔드 (n8n Chat Widget)
- n8n 공식 Chat Widget CDN 임베드
- 커스텀 스타일링 (LG 브랜드 컬러)
- API 선택 드롭다운 추가 (Widget 확장)

### 5.3 배포 구성
- docker-compose.yml (n8n + PostgreSQL)
- .env 파일 (API 키 관리)
- Nginx 설정 (리버스 프록시)

---

## 6. 개발 단계

### Phase 1: 핵심 서비스 (인증 없이)
| 단계 | 작업 내용 | 예상 소요 |
|-----|----------|----------|
| 1 | n8n 셀프호스팅 환경 구축 | 1일 |
| 2 | LG 스펙 페이지 스크래핑 테스트 | 2일 |
| 3 | 멀티 API 이미지 합성 워크플로우 | 4일 |
| 4 | n8n Chat Widget 연동 | 2일 |
| 5 | 통합 테스트 | 2일 |
| **소계** | | **약 11일 (2주)** |

### Phase 2: 인증 추가 (논의 후)
| 옵션 | 방식 | 복잡도 |
|-----|------|-------|
| A | Basic Auth (간단) | 낮음 |
| B | n8n User Management | 중간 |
| C | LG SSO 연동 (OAuth) | 높음 |
| D | API Gateway 인증 | 중간 |

---

## 7. 필요 API 키 목록

| API | 용도 | 필수 여부 |
|-----|------|----------|
| Google Gemini API | 이미지 합성 (기본) | 필수 |
| Replicate API | 이미지 합성 (선택) | 권장 |
| OpenAI API | 이미지 합성 (선택) | 선택 |
| Stability AI API | 이미지 합성 (선택) | 선택 |
| Jina AI API | 동적 페이지 스크래핑 | 권장 |

---

## 8. 기술 선택 근거 (n8n 사용 이유)

### 8.1 n8n vs 전통적 개발 프레임워크 비교

| 항목 | n8n | Next.js / Spring |
|-----|-----|------------------|
| **개발 속도** | 매우 빠름 (드래그앤드롭) | 코딩 필요, 상대적으로 느림 |
| **개발자 스킬** | 로우코드, 비개발자도 가능 | 프로그래밍 지식 필수 |
| **API 연동** | 400+ 내장 노드 (바로 사용) | 직접 구현 필요 |
| **유지보수** | 시각적 워크플로우, 쉬움 | 코드 이해 필요 |
| **프로토타입** | 몇 시간 내 완성 | 며칠~주 소요 |
| **수정/변경** | 노드 연결만 수정 | 코드 수정 + 배포 |

### 8.2 이 프로젝트에 n8n이 적합한 이유

1. **워크플로우가 단순함**
   - URL 입력 → 스크래핑 → AI API 호출 → 결과 반환
   - 복잡한 비즈니스 로직 없음

2. **외부 API 연동이 핵심**
   - Gemini API, Replicate API, 웹 스크래핑
   - n8n에 이미 노드가 있거나 HTTP Request로 쉽게 처리

3. **빠른 MVP 제작**
   - LG전자 내부 서비스라 빠른 검증이 중요
   - n8n으로 1~2주 만에 프로토타입 가능

4. **비개발자도 수정 가능**
   - 마케팅팀에서 직접 프롬프트 수정 가능
   - 개발자 의존도 감소

### 8.3 n8n의 단점 및 대응 방안

| 단점 | 설명 | 이 프로젝트 대응 |
|-----|------|------------------|
| UI 제한 | 복잡한 프론트엔드 불가 | Chat Widget으로 해결 |
| 성능 한계 | 대규모 트래픽 처리 어려움 | 내부 서비스라 문제 없음 |
| 커스터마이징 | 복잡한 로직은 코드 노드 필요 | 워크플로우가 단순함 |
| 디버깅 | 복잡한 워크플로우 디버깅 어려움 | 워크플로우가 단순함 |
| 버전 관리 | Git 연동이 자연스럽지 않음 | JSON export로 대응 |

### 8.4 향후 마이그레이션 고려

서비스가 성장하여 아래 조건에 해당하면 Next.js/Spring 마이그레이션 검토:
- 수백 명 이상 동시 사용자
- 복잡한 대시보드/어드민 UI 필요
- 복잡한 비즈니스 로직 (결제, 권한 관리 등)
- 기존 시스템과 깊은 통합 필요

---

## 9. 부록

### 9.1 용어 정의
| 용어 | 설명 |
|-----|------|
| n8n | 오픈소스 워크플로우 자동화 도구 |
| Webhook | HTTP 요청을 통해 워크플로우를 트리거하는 엔드포인트 |
| 스크래핑 | 웹페이지에서 데이터를 추출하는 기술 |
| Switch Node | 조건에 따라 워크플로우를 분기하는 n8n 노드 |

### 9.2 참고 자료
- n8n 공식 문서: https://docs.n8n.io
- n8n Chat Widget: https://www.npmjs.com/package/@n8n/chat
- Google Gemini API: https://ai.google.dev
- Replicate API: https://replicate.com/docs

---

## 10. 구현 현황 (Phase 1)

### 10.1 완료된 작업

#### 인프라 구성
| 항목 | 상태 | 파일/위치 |
|-----|------|----------|
| Docker 환경 구성 (n8n + PostgreSQL) | ✅ 완료 | `docker-compose.yml` |
| 환경변수 설정 | ✅ 완료 | `.env`, `.env.example` |
| Nginx 리버스 프록시 (프로덕션) | ✅ 완료 | `nginx/nginx.conf`, `docker-compose.prod.yml` |

#### n8n 워크플로우
| 워크플로우 | 상태 | 파일 | 엔드포인트 |
|-----------|------|------|-----------|
| 이미지 추출 워크플로우 | ✅ 완료 | `workflows/image-extraction-workflow.json` | `POST /webhook/extract-images` |
| 이미지 합성 워크플로우 | ✅ 완료 | `workflows/image-synthesis-workflow.json` | `POST /webhook/synthesize-image` |

#### 프론트엔드 (LG ImageStudio)
| 기능 | 상태 | 설명 |
|-----|------|------|
| 기본 레이아웃 | ✅ 완료 | 2패널 구조 (URL 입력 + 채팅) |
| 다크/라이트 모드 | ✅ 완료 | SpaceX 스타일 다크모드 + 라이트모드 토글 |
| 다국어 지원 | ✅ 완료 | 한국어/영어 전환 |
| LG 브랜드 컬러 적용 | ✅ 완료 | 포인트 컬러 #A50034 |
| URL 입력 (1~2개) | ✅ 완료 | + 버튼으로 URL 추가, 초기화 버튼 |
| 이미지 추출 | ✅ 완료 | Jina AI 스크래핑 연동 |
| 이미지 선택 UI | ✅ 완료 | 체크 배지 + 테두리 하이라이트 |
| 프리셋 옵션 | ✅ 완료 | 배치/배경/앵글 선택 |
| API 모델 선택 | ✅ 완료 | Gemini/Replicate/OpenAI/Stability |
| 채팅 인터페이스 | ✅ 완료 | 메시지 전송/수신, 로딩 표시 |
| 결과 이미지 표시 | ✅ 완료 | 이미지 + 다운로드 버튼 |

### 10.2 UI/UX 상세 구현

#### 디자인 시스템
```
색상 (다크모드)
- 배경: #1a1a1a
- 서피스: #242424
- 텍스트 기본: #ffffff
- 텍스트 보조: rgba(255,255,255,0.7)
- 액센트 (LG 컬러): #A50034
- 액센트 호버: #c4003f

색상 (라이트모드)
- 배경: #ffffff
- 서피스: #f5f5f5
- 텍스트 기본: #000000
- 텍스트 보조: rgba(0,0,0,0.6)
- 액센트: #A50034

폰트
- 기본: Pretendard (한국어/영어 통합)
- 폰트 두께: 400 (Regular)

아이콘
- Phosphor Icons (ph-light 웨이트)
```

#### 주요 UI 컴포넌트
| 컴포넌트 | 스타일 |
|---------|--------|
| Primary 버튼 | LG 컬러 배경 (#A50034), 흰색 텍스트 |
| Secondary 버튼 | 투명 배경, 테두리 |
| 초기화 버튼 | 아이콘 + 텍스트, 테두리 |
| 선택된 이미지 | 3px 테두리 + 체크 배지 |
| 선택된 프리셋 | LG 컬러 배경 |
| 입력 필드 | 투명 배경, 테두리 |

### 10.3 파일 구조
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
│   └── index.html              # LG ImageStudio UI (단일 파일)
├── nginx/
│   └── nginx.conf              # 리버스 프록시 설정
└── README.md                   # 사용 가이드
```

### 10.4 API 엔드포인트

#### 이미지 추출 API
```
POST http://localhost:5678/webhook/extract-images
Content-Type: application/json

Request:
{
  "urls": ["https://www.lge.co.kr/tvs/...", "https://www.lge.co.kr/home-audio/..."]
}

Response:
{
  "images": ["url1", "url2", ...],
  "count": 10,
  "extractedAt": "2025-12-03T..."
}
```

#### 이미지 합성 API
```
POST http://localhost:5678/webhook/synthesize-image
Content-Type: application/json

Request:
{
  "prompt": "TV 아래에 사운드바를 배치해주세요",
  "images": ["url1", "url2"],
  "apiProvider": "gemini",
  "sessionId": "uuid"
}

Response:
{
  "success": true,
  "apiProvider": "gemini",
  "imageUrl": "...",        // URL 기반 이미지
  "imageBase64": "...",     // Base64 인코딩 이미지
  "generatedAt": "2025-12-03T..."
}
```

### 10.5 실행 방법

#### 개발 환경
```bash
# 1. 환경 설정
cp .env.example .env
# .env 파일에 API 키 입력

# 2. Docker 실행
docker-compose up -d

# 3. n8n 워크플로우 import
# http://localhost:5678 접속 후 workflows/ 폴더의 JSON 파일 import
# 각 워크플로우 "Active" 토글 ON

# 4. 프론트엔드 실행
# frontend/index.html 파일을 브라우저에서 열기
```

#### 프로덕션 환경
```bash
docker-compose -f docker-compose.prod.yml up -d
# http://localhost 로 접속
```

### 10.6 남은 작업 (TODO)

#### 필수
| 항목 | 설명 | 우선순위 |
|-----|------|---------|
| n8n 워크플로우 활성화 테스트 | 합성 API 연결 확인 | 높음 |
| Gemini API 이미지 생성 테스트 | 실제 이미지 합성 확인 | 높음 |
| 에러 핸들링 개선 | 사용자 친화적 에러 메시지 | 중간 |

#### 권장 (Phase 2)
| 항목 | 설명 | 우선순위 |
|-----|------|---------|
| 사용자 인증 | SSO/OAuth 연동 | 중간 |
| 대화 히스토리 저장 | PostgreSQL 연동 | 낮음 |
| 이미지 갤러리 | 생성된 이미지 저장/조회 | 낮음 |
| 사용량 모니터링 | API 호출 통계 | 낮음 |

### 10.7 알려진 이슈

| 이슈 | 상태 | 해결 방법 |
|-----|------|----------|
| file:// 프로토콜 CORS 오류 | 확인됨 | 프로덕션 모드(Nginx) 사용 또는 로컬 웹서버 |
| n8n 워크플로우 비활성화 시 빈 응답 | 확인됨 | n8n에서 워크플로우 Active 토글 ON |

---

**문서 버전**: v1.2
**작성일**: 2025-12-03
**최종 수정일**: 2025-12-03
**작성자**: -
**승인자**: -

