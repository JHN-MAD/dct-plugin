# Changelog

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
