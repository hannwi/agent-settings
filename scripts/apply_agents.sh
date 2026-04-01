#!/usr/bin/env bash
# =============================================================================
# apply_agents.sh
#
# 설명:
#   이 저장소의 .claude/agents/ 디렉토리에 있는 Claude 에이전트 설정 파일(.md)을
#   전역(~/.claude/agents/) 또는 특정 로컬 프로젝트(.claude/agents/)에 복사합니다.
#
# 동작 방식:
#   1. 소스 디렉토리(<repo>/.claude/agents/)에서 에이전트 파일(.md)을 탐색합니다.
#   2. --agents 옵션으로 특정 에이전트만 지정하거나, 생략 시 전체 에이전트를 적용합니다.
#   3. 대상 경로에 이미 파일이 존재하면 덮어쓸지 여부를 사용자에게 확인합니다.
#   4. 대상 디렉토리가 없으면 자동으로 생성합니다.
#
# 사용법:
#   bash scripts/apply_agents.sh [--local] [--project-root PATH] [--agents AGENT ...]
#
# 옵션:
#   --local               전역 디렉토리 대신 로컬 프로젝트에 적용
#   --project-root PATH   로컬 프로젝트의 루트 경로 (--local 사용 시 필수)
#   --agents AGENT ...    적용할 에이전트 이름 목록 (.md 확장자 제외, 생략 시 전체 적용)
#   -h, --help            도움말 출력
#
# 예시:
#   # 모든 에이전트를 전역으로 적용
#   bash scripts/apply_agents.sh
#
#   # 특정 에이전트만 전역으로 적용
#   bash scripts/apply_agents.sh --agents plan-agent code-agent
#
#   # 모든 에이전트를 로컬 프로젝트에 적용
#   bash scripts/apply_agents.sh --local --project-root ~/projects/my-app
#
#   # 특정 에이전트를 로컬 프로젝트에 적용
#   bash scripts/apply_agents.sh --local --project-root ~/projects/my-app --agents plan-agent
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SOURCE_DIR="$SCRIPT_DIR/../.claude/agents"
GLOBAL_AGENTS_DIR="$HOME/.claude/agents"

LOCAL=false
PROJECT_ROOT=""
AGENT_NAMES=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [--local] [--project-root PATH] [--agents AGENT ...]

Apply agent config files to a Claude agents directory.

Options:
  --local               Apply to a local project instead of ~/.claude/
  --project-root PATH   Root path of the local project (required with --local)
  --agents AGENT ...    Agent names to apply (without .md). Applies all if omitted
  -h, --help            Show this help message

Examples:
  # Apply all agents globally (default)
  bash scripts/apply_agents.sh

  # Apply specific agents globally
  bash scripts/apply_agents.sh --agents plan-agent code-agent

  # Apply all agents to a local project
  bash scripts/apply_agents.sh --local --project-root ~/projects/my-app

  # Apply a specific agent to a local project
  bash scripts/apply_agents.sh --local --project-root ~/projects/my-app --agents plan-agent
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --local)
            LOCAL=true
            shift
            ;;
        --project-root)
            PROJECT_ROOT="$2"
            shift 2
            ;;
        --agents)
            shift
            while [[ $# -gt 0 && "$1" != --* ]]; do
                AGENT_NAMES+=("$1")
                shift
            done
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# Resolve destination
if $LOCAL; then
    if [[ -z "$PROJECT_ROOT" ]]; then
        echo "Error: --project-root is required when using --local." >&2
        exit 1
    fi
    # Expand ~ if present
    PROJECT_ROOT="${PROJECT_ROOT/#\~/$HOME}"
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        echo "Error: project root does not exist: $PROJECT_ROOT" >&2
        exit 1
    fi
    DEST_DIR="$PROJECT_ROOT/.claude/agents"
else
    DEST_DIR="$GLOBAL_AGENTS_DIR"
fi

# Resolve sources
SOURCES=()
if [[ ${#AGENT_NAMES[@]} -eq 0 ]]; then
    for f in "$AGENTS_SOURCE_DIR"/*.md; do
        [[ -f "$f" ]] && SOURCES+=("$f")
    done
else
    for name in "${AGENT_NAMES[@]}"; do
        path="$AGENTS_SOURCE_DIR/$name.md"
        if [[ ! -f "$path" ]]; then
            echo "Error: agent file not found: $path" >&2
            exit 1
        fi
        SOURCES+=("$path")
    done
fi

if [[ ${#SOURCES[@]} -eq 0 ]]; then
    echo "No agent files found in source directory." >&2
    exit 1
fi

if $LOCAL; then
    echo "Applying ${#SOURCES[@]} agent(s) to local project: $DEST_DIR"
else
    echo "Applying ${#SOURCES[@]} agent(s) to global: $DEST_DIR"
fi
echo

mkdir -p "$DEST_DIR"

# Apply agents
for src in "${SOURCES[@]}"; do
    filename="$(basename "$src")"
    name="${filename%.md}"
    dest="$DEST_DIR/$filename"

    if [[ -f "$dest" ]]; then
        while true; do
            read -rp "Agent '$name' already exists. Overwrite? [y/N] " answer || answer=""
            case "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" in
                y|yes)
                    cp "$src" "$dest"
                    echo "  Applied: $name -> $dest"
                    break
                    ;;
                ""|n|no)
                    echo "  Skipped: $name"
                    break
                    ;;
                *)
                    echo "Please answer y or n."
                    ;;
            esac
        done
    else
        cp "$src" "$dest"
        echo "  Applied: $name -> $dest"
    fi
done

echo
echo "Done."
