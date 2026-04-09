---
name: dct-refresh-slack
description: AWS Secrets Manager 에서 Slack 봇 토큰을 다시 fetch 해 ~/.claude.json 의 slack MCP 설정을 갱신. 토큰 로테이션 또는 invalid_auth 에러 시 사용.
---

# /dct-refresh-slack — Slack 봇 토큰 갱신

`prod/gen-ai/slack` secret 에서 `SLACK_TOKEN` 을 다시 가져와 `~/.claude.json` 의 `mcpServers.slack.env.SLACK_BOT_TOKEN` 을 업데이트한다.

## 언제 사용하나

- Slack MCP 가 `invalid_auth` 또는 `token_expired` 에러를 반환할 때
- 팀에서 봇 토큰을 로테이션한 직후
- `/dct-slack` 전송이 갑자기 실패할 때

## 실행 방식

플러그인의 `scripts/refresh-slack-token.sh` 를 Bash 로 실행한다:

```bash
bash ~/.claude/plugins/cache/dct-marketplace/dct-claude-plugin/0.1.0/scripts/refresh-slack-token.sh
```

스크립트가 수행하는 작업:
1. `aws secretsmanager get-secret-value --secret-id prod/gen-ai/slack` 호출
2. `SLACK_TOKEN` 추출
3. `~/.claude.json` 백업 (`.bak-<timestamp>`)
4. `jq` 로 `mcpServers.slack` 블록만 갱신 (다른 키 전부 보존)
5. 검증 출력

## 전제 조건

- `aws` CLI 설정 완료 (`aws sts get-caller-identity` 로 prod 계정 인증 확인)
- `jq` 설치
- IAM 권한: `secretsmanager:GetSecretValue` on `prod/gen-ai/slack`

권한이 없으면 팀 권한 담당자에게 요청.

## 완료 후

Claude Code 를 **재시작** 한 뒤:
```bash
claude mcp list
```
→ `slack: ✓ Connected` 확인

## 실패 대응

- **`Unable to locate credentials`** → `aws configure` 로 인증 재설정
- **`AccessDeniedException`** → IAM 권한 요청
- **`ResourceNotFoundException`** → secret 이름 확인 (기본: `prod/gen-ai/slack`)
- **`~/.claude.json` 손상** → `cp ~/.claude.json.bak-<timestamp> ~/.claude.json` 으로 백업에서 복원

## 관련
- `/dct` 6단계 — 최초 Slack MCP 설정 (이 스크립트를 내부적으로 호출)
- `/dct-slack` — Slack 메시지 전송
- `scripts/refresh-slack-token.sh` — 실제 로직
