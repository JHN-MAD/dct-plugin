---
name: dct
description: 데이터 컨설팅 팀(DCT) Claude Code 온보딩 — MCP 셋업, SSH 키 생성, 팀 CLAUDE.md/rules 배포 가이드
---

# /dct — DCT 온보딩

데컨팀 신규 팀원이 Claude Code를 처음 셋업할 때 실행. MCP 연결과 팀 기본 설정을 단계별로 안내한다.

## 실행 단계

`dct-onboarding` 스킬을 참조하여 아래 순서로 진행:

### 1. Atlassian MCP 설정
- 리포 루트의 `settings-example.json` 을 `~/.claude/settings.json` 으로 복사 (기존 파일 있으면 백업)
- 사용자에게 아래 값 입력 요청:
  - `JIRA_USERNAME`, `JIRA_API_TOKEN`
  - `CONFLUENCE_USERNAME`, `CONFLUENCE_API_TOKEN`
- 토큰 발급처 안내: https://id.atlassian.com/manage-profile/security/api-tokens

### 2. GitHub SSH 키 생성 및 등록
- SSH 키 생성 (이름에 `dct` 포함):
  ```bash
  ssh-keygen -t ed25519 -C "dct-$(whoami)" -f ~/.ssh/id_ed25519_dct
  ```
- 공개키를 GitHub 계정에 등록하도록 안내 (`~/.ssh/id_ed25519_dct.pub`)
- `~/.ssh/config` 에 항목 추가 가이드:
  ```
  Host github.com-dct
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_dct
  ```

### 3. GitHub MCP 서버 설정
- `github-mcp-server` 는 Docker + PAT(Personal Access Token) 기반
- PAT 발급: https://github.com/settings/tokens (repo, workflow 권한)
- `settings-example.json` 의 `github` 섹션에 PAT 입력

### 4. 팀 기본 CLAUDE.md / rules 배포
사용자 동의 후:
1. 기존 `~/.claude/CLAUDE.md` 가 있으면 `~/.claude/CLAUDE.md.bak-<timestamp>` 로 백업
2. 플러그인의 `core/CLAUDE.md` 를 `~/.claude/CLAUDE.md` 로 복사
3. 플러그인의 `rules/*.md` 8개 파일을 `~/.claude/rules/` 로 복사 (기존 파일은 건너뛰거나 `--force` 시 덮어쓰기)

### 5. 최종 점검
- `mcp-atlassian` 연결 확인 (예: `mcp__mcp-atlassian__jira_get_user_profile`)
- `github` MCP 연결 확인
- `~/.claude/CLAUDE.md` 와 `~/.claude/rules/` 존재 확인
- 다음 커맨드 안내: `/dct-job DCTC-1234 feat "작업 설명"`

## 주의사항
- API 토큰은 절대 커밋/로그/채팅에 노출 금지
- `~/.claude/CLAUDE.md` 백업은 사용자가 복원할 수 있도록 경로를 안내
- 덮어쓰기는 반드시 사용자 확인 후 진행
