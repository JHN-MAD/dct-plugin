---
name: dct-complete
description: Jira DCTC 작업 마무리 — 작업 결과 요약, Jira 완료 댓글 등록, PR 생성(사용자 확인)
argument-hint: <DCTC-번호>
---

# /dct-complete — 작업 마무리

Jira 카드 작업을 **마무리**하는 커맨드. 작업 결과를 요약해 Jira에 댓글로 남기고, 사용자 확인 후 PR을 생성한다.

## 사용법

```
/dct-complete <DCTC-번호>
```

**예시**
- `/dct-complete DCTC-1808`
- `/dct-complete DCTC-1234`

## 실행 순서

### 1. 현재 상태 수집
- `git status` — 미커밋 변경사항 확인
- `git log <base-branch>..HEAD --oneline` — 이 브랜치에서 추가된 커밋
- `git diff <base-branch>...HEAD --stat` — 변경된 파일 목록과 규모
- 부모 브랜치 자동 감지:
  ```bash
  git ls-remote --heads origin dev | grep -q dev && BASE=dev || \
    BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  ```
  - `dev` 존재 → `dev` 사용
  - 없으면 원격 기본 브랜치 감지 → **main 이면 사용자에게 어디로 PR할지 문의** (절대 자동 main 금지)

### 2. 미커밋 변경사항 처리
- 미커밋 변경이 있으면 사용자에게 알림:
  - 커밋 후 진행할지
  - 그대로 진행할지 (PR은 커밋된 것만 포함됨)
- Jira 카드 조회 (`jira_get_issue`) — 카드 요약 및 description 에 기록된 플랜 참조

### 3. 작업 결과 요약
- 커밋 로그, 변경 파일, 규모를 바탕으로 요약 초안 작성
- 사용자에게 요약 미리보기 제시 → 승인/수정

### 4. Jira 완료 댓글 등록
- `mcp__mcp-atlassian__jira_add_comment` 로 등록
- 댓글 포맷:
  ```
  ✅ 작업 완료 요약

  ## 변경사항
  - ...

  ## 수정 파일
  - path/to/file.ts
  - ...

  ## 검증
  - 테스트: ...
  - 빌드: ...

  ## 후속 작업
  - (있으면 기재)
  ```

### 5. PR 생성 여부 확인
사용자에게 물어봄:
```
PR을 생성할까요? (y/N)
```

**y 인 경우**:
- 브랜치가 아직 원격에 없으면 `git push -u origin feature/DCTC-<번호>` (원격 없으면 `fork` 또는 `origin` 사용)
- **베이스 브랜치 결정 (team-workflow 규칙):**
  - `git ls-remote --heads origin dev` 로 `dev` 존재 여부 확인
  - **존재** → `--base dev` 사용
  - **없음** → 사용자에게 "dev 브랜치가 없습니다. 어느 브랜치로 PR을 올릴까요?" 문의
  - **절대 `main` 으로 자동 선택하지 말 것** (🚨 main 직접 PR 금지)
- `gh pr create --base <결정된 브랜치>` 실행:
  - **제목**: `[DCTC-<번호>] <작업 요약 한 줄>`
  - **본문**: Jira 카드 링크 + 변경 요약 + 테스트 플랜 체크리스트
  - **리뷰어**: 사용자에게 확인 후 지정 (기본값 없음 — 프롬프트로 요청)
- 생성된 PR URL 을 Jira 카드에 추가 댓글로 등록 (`🔗 PR: <url>`)

**N 인 경우**:
- PR 생성 건너뜀, Jira 댓글만 남기고 종료

### 6. 종료 메시지
```
✅ DCTC-<번호> 마무리 완료
- Jira 댓글: <comment link>
- PR: <pr url> (또는 "생성 안 함")
```

## 규칙 준수
- **한국어** 응답/Jira 댓글
- **Jira 문서 가시성**: 완료 요약 댓글을 작성하기 전에 **제3자가 읽었을 때 즉시 파악할 수 있는 구조인지** 먼저 고민한다. 표, 번호 리스트, 헤더 계층, 코드 블록 등으로 **스캔 가능하게** 구성. 장문의 산문체 금지.
- **커밋 메시지**: 영어 prefix(`feat:`, `fix:`, 등) + 한국어 본문 (korean-dev 규칙)
- **PR 제목**: `[DCTC-N] ...` 포맷으로 Jira 카드와 연결
- **PR 베이스**: `dev` 기본, 없으면 사용자 문의. **`main` 직접 PR 금지** (team-workflow 규칙)
- **doc-updates 규칙**: 코드 변경과 관련된 문서(`.claude/agents/*`, 프로젝트 CLAUDE.md 등) 업데이트 여부 체크
- **보안**: `~/.claude/settings.json` 전체를 `Read` 로 출력 금지 (시크릿 세션 로그 유출 방지). 검증은 `jq` 또는 `grep` 으로만
