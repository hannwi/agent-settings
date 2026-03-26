#!/usr/bin/env bash
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
            case "${answer,,}" in
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
