# Changelog

## 0.4.0 (2026-04-16)

### Added
- **`/dct-job` 에 `/review` Phase 추가 (Phase C)** — 구현(Phase B) 직후 Claude Code 내장 `/review` 커맨드를 호출해 품질/보안/로직 정적 리뷰 수행. High/Critical 지적사항은 Phase 안에서 수정 루프 (최대 2회)
- Phase 구조 재편: A(플랜) → B(구현) → **C(/review)** → D(검증) → E(마무리)
- 중단 지점에 `/review` High/Critical 설계 판단 항목 추가

### Changed
- **권장 파이프라인 문서화**: `/dct-plan` → `/ultrawork` | `/autopilot` → `/review` → `/dct-complete`
- `/dct-plan` 종료 메시지를 4단계 파이프라인 다이어그램으로 갱신
- `/dct-job` "수동 분리 버전" 섹션을 4단계 파이프라인으로 갱신
- README 빠른 시작에 완전 자동화(`/dct-job`) vs 수동 4단계 두 가지 경로 명시

### Notes
- `/review` 는 **Claude Code 네이티브 빌트인 커맨드** (DCT 플러그인의 `/dct-sc-review` 아님). 둘은 별도로 존재하며 빌트인 사용을 권장
- 기존 `/dct-sc-review` 는 DCT 커스텀 리뷰 흐름용으로 유지

## 0.3.0 (2026-04-14)

### Added
- **`/dct` 온보딩에 GCP CLI 섹션 (Step 7)** — Cloud Storage 중심 설정 가이드
  - `gcloud auth login` + `gcloud auth application-default login` 2단계 인증
  - 다중 프로젝트 대응 (named configuration 가이드 포함)
  - `gcloud storage` 우선 사용 권장 (구 `gsutil` 대비 2~5배 빠름)
  - 비용 주의사항 (egress, 재귀 조회, BigQuery 스캔량)
- **`rules/gcp.md` 신규 규칙** — GCP/gcloud/Cloud Storage 작업 시 권장 패턴 + 금지사항
  - IAM 권한 변경 금지, 서비스 계정 JSON 키 사용 지양, 토큰 출력 명령 금지
  - Cloud Storage `gcloud storage` 우선, Cross-region egress 비용 경고
- `core/CLAUDE.md` 규칙 인덱스에 `gcp.md` 등록

### Changed
- `/dct` 온보딩 단계 재번호 매김: Slack MCP 7→8, RTK 8→9, 최종점검 9→10
- 환경 진단(Step 0) 에 GCP auth/project 체크 추가
- README 규칙 목록 9개로 확장

## 0.2.1 (2026-04-14)

### Fixed
- **`/dct-plan` 실제 plan mode 진입**: Claude Code frontmatter 에 `mode: plan` 필드는 존재하지 않음 (공식 지원 필드 아님). 본문에 **"첫 액션으로 `EnterPlanMode` 툴 호출 필수"** 지시 추가로 실제 plan mode 진입 보장
- `/dct-plan` frontmatter 에 `effort: max` 추가 (Opus 4.6 전용 최대 추론 예산)
- `/dct-job` Phase A 에도 동일한 `EnterPlanMode` 첫 액션 지시 추가

## 0.2.0 (2026-04-14)

### Added
- **`jira-adf-table` 스킬** — markdown 표를 Jira ADF 로 변환하면서 컬럼 너비를 가중 글자수 비례로 자동 계산. 한글/CJK/이모지 2배 가중. mcp-atlassian + curl fallback 경로 모두 지원
- **`/dct-plan` 에 ultrathink 지시문** — 카드 범위 판단/단계 분해/영향 파일 예측을 최대 추론 예산으로 수행
- README 헤더 배너 이미지 추가

### Changed
- **`/dct-job` Phase A → planmode**: 내장 plan mode (`EnterPlanMode`/`ExitPlanMode`) 로 증거 기반 분석 후 명시적 승인. 승인 전 mutation 금지
- **`/dct-job` Phase B → ultrawork**: 독립 작업을 ultrawork 스킬로 병렬 executor 위임, 티어 매핑(haiku/sonnet/opus), 장시간 작업 background 실행
- `/dct-plan`, `/dct-complete` 에 `jira-adf-table` 스킬 트리거 추가 (표가 포함될 때만)

## 0.1.0 (초기 릴리스)

- `/dct` 온보딩 커맨드 (Atlassian MCP, SSH, gh CLI, CLAUDE.md/rules 배포)
- `/dct-plan`, `/dct-complete`, `/dct-job` Jira 워크플로우
- `/dct-slack`, `/dct-slack-bot`, `/dct-refresh-slack` Slack 전송 + AWS Secrets 연동
- `/dct-rtk` RTK 토큰 절감 설정
- `/dct-sc-*` 개발 워크플로우 커맨드 (analyze/implement/test/debug/optimize/review)
- 팀 기본 규칙 8종 (`rules/*.md`)
