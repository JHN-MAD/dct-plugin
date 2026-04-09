---
name: dct-onboarding
description: 데이터 컨설팅 팀(DCT) Claude Code 신규 셋업 가이드. MCP(Atlassian/GitHub) 설정, SSH 키 생성, 팀 CLAUDE.md/rules 배포를 단계별로 안내한다.
---

# DCT 온보딩 스킬

`/dct` 커맨드의 백엔드. 신규 팀원이 AI Native 개발 환경에 빠르게 적응하도록 돕는다.

## 체크리스트

### A. Atlassian (Jira + Confluence) MCP
- [ ] `uvx` 설치 확인 (없으면 `brew install uv` 또는 `pip install uv`)
- [ ] API 토큰 발급 (https://id.atlassian.com/manage-profile/security/api-tokens)
- [ ] `settings-example.json` → `~/.claude/settings.json` 복사
- [ ] `JIRA_USERNAME`, `JIRA_API_TOKEN`, `CONFLUENCE_*` 값 채움
- [ ] Claude Code 재시작 후 `mcp-atlassian` 도구 노출 확인

### B. GitHub MCP
- [ ] Docker 설치 확인 (`docker --version`)
- [ ] GitHub PAT 발급 (https://github.com/settings/tokens) — 최소 `repo`, `workflow` 권한
- [ ] `settings-example.json` 의 `github.env.GITHUB_PERSONAL_ACCESS_TOKEN` 입력
- [ ] `ghcr.io/github/github-mcp-server` 이미지 pull 확인
- [ ] MCP 연결 검증

### C. GitHub SSH 키 (코드 푸시용)
- [ ] `ssh-keygen -t ed25519 -C "dct-$(whoami)" -f ~/.ssh/id_ed25519_dct`
- [ ] `pbcopy < ~/.ssh/id_ed25519_dct.pub` 후 GitHub 계정에 등록
- [ ] `~/.ssh/config` 에 `Host github.com-dct` 항목 추가
- [ ] `ssh -T git@github.com-dct` 로 연결 테스트

### D. 팀 기본 설정 배포
- [ ] 기존 `~/.claude/CLAUDE.md` 백업 (`.bak-<timestamp>`)
- [ ] `core/CLAUDE.md` → `~/.claude/CLAUDE.md` 복사
- [ ] `rules/*.md` 8개 → `~/.claude/rules/` 복사
  - 기본: 없는 파일만 복사 (기존 보호)
  - `--force` 요청 시 전체 덮어쓰기 (백업 후)

### E. 최종 검증
- [ ] `~/.claude/CLAUDE.md` 존재 및 내용 확인
- [ ] `~/.claude/rules/` 아래 8개 파일 확인
- [ ] `mcp-atlassian`, `github` MCP 연결 상태 확인
- [ ] `/dct-job DCTC-TEST feat "온보딩 테스트"` 로 스모크 테스트 안내

## 보안 원칙
- API 토큰/PAT는 **절대 대화·로그·커밋에 노출 금지**
- 값 입력은 사용자가 직접 파일에 쓰도록 유도 (AI가 받아 쓰지 않음)
- 백업 경로는 사용자에게 명확히 알려 복원 경로 확보

## 실패 시 대응
- MCP 연결 실패 → `~/.claude/settings.json` JSON 문법/경로 재확인
- Docker MCP 실패 → Docker Desktop 실행 여부 및 이미지 pull 상태 확인
- SSH 실패 → `~/.ssh/config` 권한(600) 확인
