#!/usr/bin/env bash
#
# refresh-slack-token.sh — AWS Secrets Manager 에서 madup 팀 Slack 봇 토큰을
# 가져와 ~/.claude.json 의 mcpServers.slack.env.SLACK_BOT_TOKEN 을 갱신한다.
#
# 사용 시점:
#   1. /dct 6단계 (최초 Slack MCP 설정)
#   2. 봇 토큰 로테이션 후 (invalid_auth 에러 발생 시)
#   3. `/dct-refresh-slack` 커맨드 내부에서 호출
#
# 전제 조건:
#   - aws CLI 설정 완료 (prod 계정 접근 가능)
#   - jq 설치
#   - IAM 권한: secretsmanager:GetSecretValue on prod/gen-ai/slack
#
# Claude Code 재시작 후 `claude mcp list` 로 slack: ✓ Connected 확인.

set -euo pipefail

SECRET_ID="prod/gen-ai/slack"
REGION="ap-northeast-2"
SLACK_TEAM_ID="T5D95TP5Z"
TARGET="$HOME/.claude.json"

echo "🔍 AWS Secrets Manager 에서 Slack 봇 토큰 조회 중..."
TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$REGION" \
  --query SecretString --output text 2>/dev/null | jq -r .SLACK_TOKEN)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ SLACK_TOKEN fetch 실패"
  echo "   확인 사항:"
  echo "   1) aws sts get-caller-identity — prod 계정 인증 상태"
  echo "   2) IAM 권한: secretsmanager:GetSecretValue on $SECRET_ID"
  echo "   3) secret 구조에 SLACK_TOKEN 키 존재 여부"
  exit 1
fi

echo "✅ 토큰 조회 성공 (prefix: ${TOKEN:0:5}..., length: ${#TOKEN})"

# ~/.claude.json 이 없으면 중단 (빈 객체로 초기화하면 기존 설정 전부 소실 위험)
if [ ! -f "$TARGET" ]; then
  echo "❌ $TARGET 파일이 없습니다."
  echo "   Claude Code 를 먼저 한 번 실행해 초기 설정을 생성한 뒤 다시 시도하세요."
  exit 1
fi

# 백업
TS=$(date +%Y%m%d-%H%M%S)
BACKUP="$TARGET.bak-$TS"
cp "$TARGET" "$BACKUP"
echo "💾 백업: $BACKUP"

# jq 로 mcpServers.slack 만 병합 (다른 키는 절대 건드리지 않음)
jq --arg token "$TOKEN" --arg team "$SLACK_TEAM_ID" '
  if .mcpServers then . else . + {mcpServers: {}} end
  | .mcpServers.slack = {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-slack"],
      env: {
        SLACK_BOT_TOKEN: $token,
        SLACK_TEAM_ID: $team
      }
    }
' "$TARGET" > "$TARGET.tmp"
mv "$TARGET.tmp" "$TARGET"

# 검증
echo "--- mcpServers 키 ---"
jq '.mcpServers | keys' "$TARGET"

echo ""
echo "✅ Slack MCP 토큰 갱신 완료"
echo "   Claude Code 를 재시작하면 slack MCP 가 연결됩니다."
echo "   검증: claude mcp list  ← slack: ✓ Connected 확인"
