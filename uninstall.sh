#!/bin/bash
set -euo pipefail

# SuperClaude Lite - Uninstaller
# 설치된 설정을 제거하고 백업에서 복원합니다.

CLAUDE_DIR="$HOME/.claude"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SuperClaude Lite - Uninstaller${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Find latest backup
BACKUP_DIR="${1:-}"
if [ -z "$BACKUP_DIR" ]; then
    BACKUP_DIR=$(ls -dt "$CLAUDE_DIR"/backup-* 2>/dev/null | head -1)
fi

# Remove installed files
echo -e "${BLUE}[1/3]${NC} SuperClaude Lite 파일 제거..."

CORE_FILES=(CLAUDE.md COMMANDS.md PERSONAS.md SYSTEM.md)
COMMANDS=(analyze implement test improve troubleshoot git explain build)
SKILLS=(test-driven-development systematic-debugging requesting-code-review receiving-code-review verification-before-completion writing-plans executing-plans webapp-testing)

for file in "${CORE_FILES[@]}"; do
    if [ -f "$CLAUDE_DIR/$file" ]; then
        rm "$CLAUDE_DIR/$file"
        echo -e "  ${GREEN}✓${NC} $file 제거"
    fi
done

for cmd in "${COMMANDS[@]}"; do
    if [ -f "$CLAUDE_DIR/commands/sc/$cmd.md" ]; then
        rm "$CLAUDE_DIR/commands/sc/$cmd.md"
        echo -e "  ${GREEN}✓${NC} commands/sc/$cmd.md 제거"
    fi
done

for skill in "${SKILLS[@]}"; do
    if [ -d "$CLAUDE_DIR/skills/$skill" ]; then
        rm -rf "$CLAUDE_DIR/skills/$skill"
        echo -e "  ${GREEN}✓${NC} skills/$skill 제거"
    fi
done

# Restore from backup
echo -e "${BLUE}[2/3]${NC} 백업 복원..."
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    for file in "$BACKUP_DIR"/*.md; do
        if [ -f "$file" ]; then
            cp "$file" "$CLAUDE_DIR/"
            echo -e "  ${GREEN}✓${NC} $(basename "$file") 복원"
        fi
    done
    if [ -d "$BACKUP_DIR/commands/sc" ]; then
        cp -r "$BACKUP_DIR/commands/sc/"* "$CLAUDE_DIR/commands/sc/" 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} commands/sc/ 복원"
    fi
else
    echo -e "  ${YELLOW}백업 없음 — 파일만 제거됨${NC}"
fi

# Cleanup
echo -e "${BLUE}[3/3]${NC} 정리..."

echo ""
echo -e "${GREEN}  제거 완료! Claude Code를 재시작하세요.${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
