#!/usr/bin/env bash
# =============================================================================
# apply_skills.sh
#
# 설명:
#   이 저장소의 .claude/skills/ 디렉토리에 있는 Claude 스킬 폴더를
#   전역(~/.claude/skills/) 또는 특정 로컬 프로젝트(.claude/skills/)에 복사합니다.
#
# 동작 방식:
#   1. 소스 디렉토리(<repo>/.claude/skills/)에서 스킬 폴더를 탐색합니다.
#   2. --skills 옵션으로 특정 스킬만 지정하거나, 생략 시 전체 스킬을 적용합니다.
#   3. 대상 경로에 이미 폴더가 존재하면 덮어쓸지 여부를 사용자에게 확인합니다.
#   4. 대상 디렉토리가 없으면 자동으로 생성합니다.
#
# 사용법:
#   bash scripts/apply_skills.sh [--local] [--project-root PATH] [--skills SKILL ...]
#
# 옵션:
#   --local               전역 디렉토리 대신 로컬 프로젝트에 적용
#   --project-root PATH   로컬 프로젝트의 루트 경로 (--local 사용 시 필수)
#   --skills SKILL ...    적용할 스킬 이름 목록 (폴더명, 생략 시 전체 적용)
#   -h, --help            도움말 출력
#
# 예시:
#   # 모든 스킬을 전역으로 적용
#   bash scripts/apply_skills.sh
#
#   # 특정 스킬만 전역으로 적용
#   bash scripts/apply_skills.sh --skills jira-cli wiki-cli
#
#   # 모든 스킬을 로컬 프로젝트에 적용
#   bash scripts/apply_skills.sh --local --project-root ~/projects/my-app
#
#   # 특정 스킬을 로컬 프로젝트에 적용
#   bash scripts/apply_skills.sh --local --project-root ~/projects/my-app --skills jira-cli
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE_DIR="$SCRIPT_DIR/../.claude/skills"
GLOBAL_SKILLS_DIR="$HOME/.claude/skills"

LOCAL=false
PROJECT_ROOT=""
SKILL_NAMES=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [--local] [--project-root PATH] [--skills SKILL ...]

Apply skill directories to a Claude skills directory.

Options:
  --local               Apply to a local project instead of ~/.claude/
  --project-root PATH   Root path of the local project (required with --local)
  --skills SKILL ...    Skill names to apply (directory name). Applies all if omitted
  -h, --help            Show this help message

Examples:
  # Apply all skills globally (default)
  bash scripts/apply_skills.sh

  # Apply specific skills globally
  bash scripts/apply_skills.sh --skills jira-cli wiki-cli

  # Apply all skills to a local project
  bash scripts/apply_skills.sh --local --project-root ~/projects/my-app

  # Apply a specific skill to a local project
  bash scripts/apply_skills.sh --local --project-root ~/projects/my-app --skills jira-cli
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
    DEST_DIR="$PROJECT_ROOT/.claude/skills"
else
    DEST_DIR="$GLOBAL_SKILLS_DIR"
fi

# Resolve sources
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

if $LOCAL; then
    echo "Applying ${#SOURCES[@]} skill(s) to local project: $DEST_DIR"
else
    echo "Applying ${#SOURCES[@]} skill(s) to global: $DEST_DIR"
fi
echo

mkdir -p "$DEST_DIR"

# Apply skills
for src in "${SOURCES[@]}"; do
    name="$(basename "$src")"
    dest="$DEST_DIR/$name"

    if [[ -d "$dest" ]]; then
        while true; do
            read -rp "Skill '$name' already exists. Overwrite? [y/N] " answer || answer=""
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
echo "Done."
