# 팀 워크플로우 규칙 (GitHub / Jira / Confluence)

## GitHub
- 신규 작업 시 Jira 카드 기준으로 브랜치 생성
  - 네이밍: `feature/DCTC-{카드번호}` (예: `feature/DCTC-1808`)
  - 작업 종류(feat / fix 등) 구분하여 커밋 메시지에 반영

### PR 베이스 브랜치 규칙 (🚨 중요)
- **`main` 브랜치로 직접 PR 생성 금지** — 실수 방지용 기본 가드
- PR 기본 베이스는 **`dev`** 브랜치
- `dev` 브랜치가 리포에 없으면 → **사용자에게 어느 브랜치로 PR할지 문의** 후 진행 (절대 임의로 `main` 선택하지 말 것)
- `gh pr create` 사용 시 반드시 `--base dev` 를 명시하거나, 베이스 결정 후 명시적으로 지정

## Jira (Atlassian MCP)
- 사용자가 "완료", "끝" 등의 멘트로 작업 종료 + 정리를 요청하면, 해당 Jira 카드에 전체 작업 내용을 댓글로 정리
- 제3자가 봐도 이해할 수 있게 **간결하고 명확하게** 작성
- 사용 도구: `mcp__mcp-atlassian__jira_add_comment`
- 허용 작업: **읽기 / 수정(댓글도포함)**

## Confluence (Atlassian MCP)
- **Data Consulting Team** 스페이스에서만 작업
- 허용 작업: **읽기 / 수정 / 생성** (삭제 금지)
- 편집 가능 문서 범위: **DCT CP**, **Matrix** 문서로 제한
- 그 외 스페이스/문서는 접근 금지
