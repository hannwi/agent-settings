#!/usr/bin/env bash
# =============================================================================
# apply_skills.sh
#
# 설명:
#   이 저장소의 .claude/skills/ 디렉토리에 있는 스킬 폴더를
#   Claude/Codex 전역 디렉토리 또는 특정 로컬 프로젝트 디렉토리에 복사합니다.
#
# 동작 방식:
#   1. 소스 디렉토리(<repo>/.claude/skills/)에서 스킬 폴더를 탐색합니다.
#   2. --agent 옵션으로 대상 에이전트(claude, codex, all)를 선택합니다.
#   3. --project-root 옵션이 있으면 로컬 프로젝트에, 없으면 전역 경로에 적용합니다.
#   4. --skills 옵션으로 특정 스킬만 지정하거나, 생략 시 전체 스킬을 적용합니다.
#   5. 대상 경로에 이미 폴더가 존재하면 덮어쓸지 여부를 사용자에게 확인합니다.
#   6. 대상 디렉토리가 없으면 자동으로 생성합니다.
#
# 사용법:
#   bash scripts/apply_skills.sh [--agent AGENT] [--project-root PATH] [--skills SKILL ...]
#
# 옵션:
#   --agent AGENT       적용 대상 에이전트 (claude|codex|all, 기본값: all)
#   --project-root PATH   로컬 프로젝트의 루트 경로 (지정 시 로컬 적용)
#   --skills SKILL ...    적용할 스킬 이름 목록 (폴더명, 생략 시 전체 적용)
#   -h, --help            도움말 출력
#
# 예시:
#   # 모든 스킬을 claude/codex 전역으로 적용
#   bash scripts/apply_skills.sh
#
#   # 모든 스킬을 Claude 전역으로만 적용
#   bash scripts/apply_skills.sh --agent claude
#
#   # 모든 스킬을 Codex 전역으로만 적용
#   bash scripts/apply_skills.sh --agent codex
#
#   # 특정 스킬만 로컬 Codex 프로젝트에 적용
#   bash scripts/apply_skills.sh --agent codex --project-root ~/projects/my-app --skills jira-cli
#
#   # 모든 스킬을 로컬 프로젝트(claude/codex 둘 다)에 적용
#   bash scripts/apply_skills.sh --project-root ~/projects/my-app
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE_DIR="$SCRIPT_DIR/../.claude/skills"

PROJECT_ROOT=""
SKILL_NAMES=()
AGENT="all"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--agent AGENT] [--project-root PATH] [--skills SKILL ...]

Apply skill directories to Claude/Codex skills directories.

Options:
  --agent AGENT         Target agent: claude, codex, all (default: all)
  --project-root PATH   Root path of the local project (applies locally when set)
  --skills SKILL ...    Skill names to apply (directory name). Applies all if omitted
  -h, --help            Show this help message

Examples:
  # Apply all skills to both global directories (default)
  bash scripts/apply_skills.sh

  # Apply all skills to Claude global directory only
  bash scripts/apply_skills.sh --agent claude

  # Apply all skills to Codex global directory only
  bash scripts/apply_skills.sh --agent codex

  # Apply all skills to both agent directories in a local project
  bash scripts/apply_skills.sh --project-root ~/projects/my-app

  # Apply specific skills to a local Codex project
  bash scripts/apply_skills.sh --agent codex --project-root ~/projects/my-app --skills jira-cli
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            if [[ $# -lt 2 ]]; then
                echo "Error: --agent requires a value (claude|codex|all)." >&2
                exit 1
            fi
            AGENT="$2"
            case "$AGENT" in
                claude|codex|all) ;;
                *)
                    echo "Error: invalid --agent value '$AGENT'. Use claude, codex, or all." >&2
                    exit 1
                    ;;
            esac
            shift 2
            ;;
        --project-root)
            if [[ $# -lt 2 ]]; then
                echo "Error: --project-root requires a path value." >&2
                exit 1
            fi
            PROJECT_ROOT="$2"
            shift 2
            ;;
        --skills)
            shift
            while [[ $# -gt 0 && "$1" != --* ]]; do
                SKILL_NAMES+=("$1")
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

# Resolve target agents
TARGET_AGENTS=()
case "$AGENT" in
    all)
        TARGET_AGENTS=("claude" "codex")
        ;;
    claude|codex)
        TARGET_AGENTS=("$AGENT")
        ;;
esac

# Resolve destination base
if [[ -n "$PROJECT_ROOT" ]]; then
    # Expand ~ if present
    PROJECT_ROOT="${PROJECT_ROOT/#\~/$HOME}"
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        echo "Error: project root does not exist: $PROJECT_ROOT" >&2
        exit 1
    fi
fi

# Resolve sources
if [[ ! -d "$SKILLS_SOURCE_DIR" ]]; then
    echo "Error: source skill directory does not exist: $SKILLS_SOURCE_DIR" >&2
    exit 1
fi

SOURCES=()
if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
    for d in "$SKILLS_SOURCE_DIR"/*/; do
        [[ -d "$d" ]] && SOURCES+=("${d%/}")
    done
else
    for name in "${SKILL_NAMES[@]}"; do
        path="$SKILLS_SOURCE_DIR/$name"
        if [[ ! -d "$path" ]]; then
            echo "Error: skill directory not found: $path" >&2
            exit 1
        fi
        SOURCES+=("$path")
    done
fi

if [[ ${#SOURCES[@]} -eq 0 ]]; then
    echo "No skill directories found in source directory." >&2
    exit 1
fi

resolve_dest_dir() {
    local agent="$1"
    local base_dir=""

    case "$agent" in
        claude)
            base_dir=".claude"
            ;;
        codex)
            base_dir=".codex"
            ;;
        *)
            echo "Error: unsupported agent '$agent'" >&2
            exit 1
            ;;
    esac

    if [[ -n "$PROJECT_ROOT" ]]; then
        echo "$PROJECT_ROOT/$base_dir/skills"
    else
        echo "$HOME/$base_dir/skills"
    fi
}

# Apply skills per agent
for agent in "${TARGET_AGENTS[@]}"; do
    DEST_DIR="$(resolve_dest_dir "$agent")"

    if [[ -n "$PROJECT_ROOT" ]]; then
        echo "Applying ${#SOURCES[@]} skill(s) to ${agent} local project: $DEST_DIR"
    else
        echo "Applying ${#SOURCES[@]} skill(s) to ${agent} global: $DEST_DIR"
    fi
    echo

    mkdir -p "$DEST_DIR"

    for src in "${SOURCES[@]}"; do
        name="$(basename "$src")"
        dest="$DEST_DIR/$name"

        if [[ -d "$dest" ]]; then
            while true; do
                read -rp "[$agent] Skill '$name' already exists. Overwrite? [y/N] " answer || answer=""
                case "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" in
                    y|yes)
                        rm -rf "$dest"
                        cp -r "$src" "$dest"
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
            cp -r "$src" "$dest"
            echo "  Applied: $name -> $dest"
        fi
    done
    echo
done

echo "Done."
