---
name: dct-plan
description: Jira DCTC 카드 기반 작업 진입 — 플랜 작성, Jira 업로드, feature 브랜치 체크아웃까지 수행 (구현은 유저 자유)
argument-hint: <DCTC-번호> ["<작업 설명>" | <파일경로>]
effort: max
---

# /dct-plan — 플랜 작성 & 진입

Jira 카드 기반 작업을 **시작**하는 커맨드. 플랜 작성과 브랜치 진입까지만 수행하고, 이후 구현은 사용자가 자유롭게 진행한다(다른 플러그인/도구 조합 가능).

> **🧠 Reasoning Effort: MAX + ultrathink** — frontmatter `effort: max` (Opus 4.6 전용) + 본문 `ultrathink` 키워드로 최대 추론 예산을 사용한다. 카드 범위 판단, 단계 분해, 영향 파일 예측, 검증 전략 설계 전 과정에서 깊이 있게 사고한 뒤 산출물을 작성한다.

## 🚨 필수 선행 액션 — Plan Mode 진입

이 커맨드의 **맨 첫 번째 액션은 반드시 `EnterPlanMode` 툴 호출**이다. Claude Code 공식 frontmatter 에는 plan mode 자동진입 필드가 없으므로, 본문 지시에 따라 Claude 가 명시적으로 호출해야 한다.

- **plan mode 진입 이유**: 승인되지 않은 상태로 Jira description 변경, 브랜치 체크아웃 등 mutation 을 일으키면 안 됨
- **plan mode 이탈**: 플랜이 사용자 승인을 받은 직후 `ExitPlanMode` 로 벗어나 Jira 업로드 + 브랜치 작업 수행
- **plan mode 중 허용**: 카드 조회, 파일 Read, Grep/Glob 탐색 등 **읽기 전용 작업만**

## 사용법

```
/dct-plan <DCTC-번호> [설명|파일경로]
```

**예시**
- `/dct-plan DCTC-1808 "프론트 사이드바 애니메이션 개선"`
- `/dct-plan DCTC-1234 ./docs/job.md`
- `/dct-plan DCTC-1500` (설명 생략 시 Jira 카드 내용만 사용)

## 실행 순서

`dct-jira-workflow` 스킬의 Phase 1~3 만 수행:

### 1. 카드 조회
- `mcp__mcp-atlassian__jira_get_issue` 로 카드 요약/설명/현재 상태 조회
- 작업명령이 파일 경로면 `Read` 로 내용 추가 로드

### 2. 범위 분석
- 카드 내용 + 작업명령을 읽고 범위 판단
- 범위가 넓으면 `writing-plans` 스킬로 세부 단계 작성
- 병렬 가능한 독립 작업이 3개 이상이면 사용자에게 제안

### 3. 플랜 작성
- 목표, 단계(step-by-step), 예상 영향 파일, 검증 방법 포함
- 사용자에게 **플랜 미리보기** 제시 → 승인 받기

### 4. Jira 업로드
- 승인된 플랜을 Jira 카드의 **description(설명) 필드**에 기록 (기존 설명이 있으면 병합 또는 사용자 확인 후 갱신)
- **플랜에 표가 포함되면** `jira-adf-table` 스킬로 ADF 변환 (컬럼 너비가 내용 길이에 비례하도록 colwidth 자동 계산). 표가 없으면 markdown 그대로 전달
- 도구: `mcp__mcp-atlassian__jira_update_issue` (`fields.description` 업데이트)
- description 포맷 (Markdown):
  ```
  📋 작업 플랜 (by Claude Code)

  ## 목표
  ...

  ## 단계
  1. ...
  2. ...

  ## 예상 영향 파일
  - ...

  ## 검증
  - ...
  ```

### 5. 브랜치 진입
- 부모 브랜치 결정 (`dev` 우선, 없으면 기본 브랜치)
- `git fetch origin` 으로 최신화
- `feature/DCTC-<번호>` 브랜치:
  - **존재하면** → `git switch feature/DCTC-<번호>` (그대로 체크아웃)
  - **없으면** → `git switch -c feature/DCTC-<번호> dev`
- 메모리 엔트리 이름에 스토리 번호 포함 (예: `DCTC-1808-plan`)

### 6. 종료 메시지
- 플랜이 반영된 Jira 카드 링크 (description 갱신됨)
- 현재 브랜치 확인
- 다음 액션 안내:
  ```
  ✅ 플랜 업로드 완료 & feature/DCTC-1808 진입

  이제 자유롭게 구현하세요. 다음 도구들을 사용할 수 있습니다:
  - /sc:implement, /autopilot, /ultrawork 등 다른 플러그인
  - 직접 코딩
  - 또는 /dct-job 으로 완전 자동화

  작업이 끝나면 /dct-complete DCTC-1808 로 마무리하세요.
  ```

## 규칙 준수
- **브랜치 네이밍**: `feature/DCTC-<번호>` 고정 (team-workflow 규칙)
- **Jira 문서 가시성**: 플랜을 description 에 작성하기 전에 **제3자가 읽었을 때 바로 이해할 수 있는 구조인지** 먼저 고민한다. 표, 번호 리스트, 헤더 계층, 코드 블록 등을 활용해 **스캔 가능한 문서**를 작성할 것. 장문의 산문체 금지.
- **구현은 수행하지 않음**: 이 커맨드는 플랜과 진입까지만
- **보안**: `~/.claude/settings.json` 을 `Read` 로 전체 출력하지 말 것 (시크릿 세션 로그 유출 방지). 검증은 `jq` 키 확인만
