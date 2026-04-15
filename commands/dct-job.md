---
name: dct-job
description: Jira DCTC 카드 기반 작업을 완전 자동화 — 플랜→구현→검증→PR까지 논스톱 실행
argument-hint: <DCTC-번호> <feat|fix|refactor|chore|docs|test> "<작업 설명 또는 파일경로>"
---

# /dct-job — 완전 자동화 파이프라인

Jira 카드 작업을 **처음부터 끝까지 자동으로** 수행하는 커맨드. 플랜과 마무리를 수동으로 나누고 싶다면 `/dct-plan` + `/dct-complete` 조합을 사용하라.

## 사용법

```
/dct-job <DCTC-번호> <작업종류> <작업명령|파일경로>
```

**예시**
- `/dct-job DCTC-1808 feat "프론트 사이드바 애니메이션 개선"`
- `/dct-job DCTC-1234 fix ./docs/job.md`
- `/dct-job DCTC-1500 refactor "auth 미들웨어 정리"`

## 인자

| 인자 | 설명 | 예시 |
|------|------|------|
| 스토리번호 | Jira 카드 번호 | `DCTC-1808` |
| 작업종류 | 커밋/브랜치 타입 | `feat`, `fix`, `refactor`, `chore`, `docs`, `test` |
| 작업명령 | 작업 설명 문자열 또는 명세 파일 경로 | `"사이드바 개선"` 또는 `./docs/job.md` |

## 실행 파이프라인

### Phase A — 플랜 & 진입 (🧠 **planmode** 사용)
이 단계는 **반드시 Claude Code 의 내장 plan mode 를 활성화한 상태**에서 진행한다. plan mode 동안은 파일 수정/커맨드 실행이 금지되고 읽기·분석만 허용되므로, 카드 조회 → 범위 분석 → 단계 설계 → 영향 파일 예측을 **증거 기반으로 깊이 있게** 수행한 뒤 `ExitPlanMode` 로 사용자 승인을 받는다.

> **🚨 첫 액션 필수**: Phase A 의 **맨 처음 단계는 반드시 `EnterPlanMode` 툴 호출**이다. Claude Code frontmatter 에는 plan mode 자동진입 필드가 없으므로 Claude 가 명시적으로 호출해야 한다. 이전에 어떤 mutation 도 발생하지 않아야 함.

1. **`EnterPlanMode` 툴 호출 (mutation 전 필수)**
2. `mcp__mcp-atlassian__jira_get_issue` — 카드 조회 (읽기만)
3. 범위 분석 → `writing-plans` 스킬로 단계 설계
4. 병렬 가능성 분석 (Phase B 에서 ultrawork 로 분할할 작업 후보 식별)
5. 예상 영향 파일 목록화 (Grep/Glob 으로 사전 조사)
6. `ExitPlanMode` 로 플랜 미리보기 제시 → **사용자 명시적 승인**
7. 승인된 플랜을 Jira 카드 **description 필드**에 기록 (`jira_update_issue` → `fields.description`)
   - 표가 포함되면 `jira-adf-table` 스킬로 ADF 변환 후 업로드
8. `dev` 에서 `feature/DCTC-<번호>` 체크아웃 (있으면 switch)

### Phase B — 구현 (🚀 **ultrawork** 사용)
Phase A 에서 식별한 병렬 가능 작업을 **ultrawork 스킬로 위임**해 여러 executor 에이전트를 동시 실행한다. 순차 의존성이 있는 작업만 차례로 진행.

1. `executing-plans` 스킬로 단계 목록 확정
2. **독립 작업은 `ultrawork` 로 병렬 실행** — `Task(subagent_type="oh-my-claudecode:executor", model=<tier>, prompt=...)` 를 한 메시지에 복수 호출
   - 작업 티어 매핑:
     - 단순 수정 (타입 export, 오타, 한 줄 변경) → `haiku`
     - 표준 구현 (엔드포인트, 컴포넌트, 리팩터) → `sonnet`
     - 복잡한 설계/분석/대규모 리팩터 → `opus`
   - 빌드/테스트/설치 등 30초+ 작업은 `run_in_background=true`
3. **의존성 있는 작업**은 선행 결과 확정 후 순차 실행
4. 각 병렬 배치 완료 시 체크포인트 — 빌드/타입체크 논블로킹 검증
5. 모든 배치 완료 후 Phase C 로 이행

### Phase C — 검증
1. `verification-before-completion` 스킬 수행
2. 테스트/빌드/린트 실행
3. 실패 시 수정 루프 (최대 3회, 이후 사용자 개입 요청)

### Phase D — 마무리 (내부적으로 /dct-complete 로직 수행)
1. 작업 결과 요약 생성
2. Jira 카드에 완료 댓글 등록
3. 사용자에게 PR 생성 여부 확인 (y/N)
4. y 인 경우 베이스 브랜치 결정 후 `gh pr create --base <base>` 실행:
   - `dev` 존재 확인 → 있으면 `dev` 자동 선택
   - 없으면 사용자에게 어느 브랜치로 PR할지 문의 (🚨 **`main` 으로 자동 선택 금지**)
5. Jira 카드에 PR 링크 댓글 추가

## 중단 지점
다음 시점에서 사용자 확인을 받음:
- 플랜 승인 (Phase A.6 — `ExitPlanMode` 시점)
- 구현 실패 3회 초과 (Phase C)
- PR 생성 여부 (Phase D.3)

## 참조 규칙
- `~/.claude/rules/team-workflow.md` — 브랜치 네이밍, Jira/Confluence 작업 경계
- `~/.claude/rules/korean-dev.md` — 응답/커밋 한국어, 코드는 영어
- `~/.claude/rules/doc-updates.md` — 작업 완료 직전 관련 문서 동기화
- `~/.claude/rules/agents.md` — 멀티파일은 executor 서브에이전트 위임

## 보안
- `~/.claude/settings.json` 전체를 `Read` 로 출력 금지 (시크릿 세션 로그 유출 방지). 검증은 `jq` 또는 `grep` 으로만

## 수동 분리 버전
완전 자동화가 아니라 **단계별로 다른 도구를 섞어 쓰고 싶다면**:

1. `/dct-plan DCTC-1808 "설명"` — 플랜 & 진입
2. (자유) — `/sc:implement`, `/autopilot`, 직접 코딩 등 무엇이든
3. `/dct-complete DCTC-1808` — 마무리 & PR
