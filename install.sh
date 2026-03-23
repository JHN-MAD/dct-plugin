#!/bin/bash
set -euo pipefail

# SuperClaude Lite - Team Installer
# 팀 공통 Claude Code 설정을 ~/.claude/에 설치합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Flags
DRY_RUN=false
FORCE=false

usage() {
    echo "Usage: $0 [--dry-run] [--force] [--help]"
    echo ""
    echo "Options:"
    echo "  --dry-run   미리보기만 (실제 변경 없음)"
    echo "  --force     기존 파일 덮어쓰기"
    echo "  --help      이 도움말 표시"
}

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        --force) FORCE=true; shift ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SuperClaude Lite - Team Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if $DRY_RUN; then
    echo -e "${YELLOW}[DRY RUN] 실제 변경 없이 미리보기만 합니다${NC}"
    echo ""
fi

# Step 1: Check prerequisites
echo -e "${BLUE}[1/5]${NC} 사전 확인..."
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}  ⚠ Claude Code CLI가 설치되지 않았습니다${NC}"
    echo "  설치: npm install -g @anthropic-ai/claude-code"
fi

# Step 2: Create ~/.claude if needed
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${BLUE}[2/5]${NC} ~/.claude/ 디렉토리 생성..."
    if ! $DRY_RUN; then
        mkdir -p "$CLAUDE_DIR"
    fi
else
    echo -e "${BLUE}[2/5]${NC} ~/.claude/ 디렉토리 확인 ✓"
fi

# Step 3: Backup existing files
NEEDS_BACKUP=false
for file in CLAUDE.md COMMANDS.md PERSONAS.md SYSTEM.md; do
    if [ -f "$CLAUDE_DIR/$file" ]; then
        NEEDS_BACKUP=true
        break
    fi
done

if $NEEDS_BACKUP; then
    echo -e "${BLUE}[3/5]${NC} 기존 설정 백업 → $BACKUP_DIR"
    if ! $DRY_RUN; then
        mkdir -p "$BACKUP_DIR"
        for file in CLAUDE.md COMMANDS.md PERSONAS.md SYSTEM.md; do
            if [ -f "$CLAUDE_DIR/$file" ]; then
                cp "$CLAUDE_DIR/$file" "$BACKUP_DIR/"
                echo -e "  ${GREEN}✓${NC} $file → backup/"
            fi
        done
        # Backup commands if exists
        if [ -d "$CLAUDE_DIR/commands/sc" ]; then
            mkdir -p "$BACKUP_DIR/commands"
            cp -r "$CLAUDE_DIR/commands/sc" "$BACKUP_DIR/commands/"
            echo -e "  ${GREEN}✓${NC} commands/sc/ → backup/"
        fi
    fi
else
    echo -e "${BLUE}[3/5]${NC} 백업 불필요 (기존 설정 없음)"
fi

# Step 4: Install core files
echo -e "${BLUE}[4/5]${NC} 설정 파일 설치..."

install_file() {
    local src="$1"
    local dest="$2"
    local label="$3"

    if [ -f "$dest" ] && ! $FORCE; then
        echo -e "  ${YELLOW}⊘${NC} $label (이미 존재 — --force로 덮어쓰기)"
        return
    fi

    if $DRY_RUN; then
        echo -e "  ${GREEN}→${NC} $label (설치 예정)"
    else
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        echo -e "  ${GREEN}✓${NC} $label"
    fi
}

# Core files
for file in CLAUDE.md COMMANDS.md PERSONAS.md SYSTEM.md; do
    install_file "$SCRIPT_DIR/core/$file" "$CLAUDE_DIR/$file" "$file"
done

# Commands
for cmd in "$SCRIPT_DIR/commands/sc/"*.md; do
    filename=$(basename "$cmd")
    install_file "$cmd" "$CLAUDE_DIR/commands/sc/$filename" "commands/sc/$filename"
done

# Step 5: Install skills
echo -e "${BLUE}[5/5]${NC} 스킬 설치..."

for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    dest_dir="$CLAUDE_DIR/skills/$skill_name"

    if [ -d "$dest_dir" ] || [ -L "$dest_dir" ]; then
        if $FORCE; then
            if ! $DRY_RUN; then
                rm -rf "$dest_dir"
                cp -r "$skill_dir" "$dest_dir"
            fi
            echo -e "  ${GREEN}✓${NC} $skill_name (덮어쓰기)"
        else
            echo -e "  ${YELLOW}⊘${NC} $skill_name (이미 존재)"
        fi
    else
        if $DRY_RUN; then
            echo -e "  ${GREEN}→${NC} $skill_name (설치 예정)"
        else
            mkdir -p "$CLAUDE_DIR/skills"
            cp -r "$skill_dir" "$dest_dir"
            echo -e "  ${GREEN}✓${NC} $skill_name"
        fi
    fi
done

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if $DRY_RUN; then
    echo -e "${YELLOW}  DRY RUN 완료 — 실제 설치하려면 --dry-run 없이 실행${NC}"
else
    echo -e "${GREEN}  설치 완료!${NC}"
    echo ""
    echo "  다음 단계:"
    echo "  1. Claude Code를 재시작하세요"
    echo "  2. /sc:analyze 또는 /sc:implement 커맨드를 시도해보세요"
    if $NEEDS_BACKUP; then
        echo ""
        echo -e "  ${YELLOW}백업 위치: $BACKUP_DIR${NC}"
        echo "  복원하려면: ./uninstall.sh $BACKUP_DIR"
    fi
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
