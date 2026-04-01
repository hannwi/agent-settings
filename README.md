# agent-settings

All settings to work with AI agents:
- global settings
- agent configs
- mcp settings
- agent skills
- instructions, prompts
- etc.

## Global Settings for Claude Code
- `.claude/settings.json`
    - Global setting file for Claude Code Premium Seat users.
    - Copy the content of this file into `~/.claude/settings.json`.

## Agent Settings

List of agent settigns in `.claude/agents/`:

1. **plan-agent** — Analyzes the codebase and writes a structured implementation plan to `.claude/plan.md`.
2. **code-agent** — Reads `.claude/plan.md` and implements the plan step by step.
3. **test-runner-agent** — Runs the test suite and reports results after code-agent finishes.

## Scripts

### Applying Agent Settings to ~/.claude/settings.json

Use `scripts/apply_agents.sh` to copy agent configurations from this repository to your Claude agents directory.

#### Usage

```
bash scripts/apply_agents.sh [--local] [--project-root PATH] [--agents AGENT ...]
```

| Option | Description |
|---|---|
| `--local` | Apply to a local project instead of the global `~/.claude/` directory |
| `--project-root PATH` | Root path of the local project (required with `--local`) |
| `--agents AGENT ...` | Agent names to apply (filename without `.md`). Applies all if omitted |

If an agent with the same name already exists at the destination, the script will prompt you before overwriting.

#### Examples

```bash
# Apply all agents to the global ~/.claude/agents/ directory (default)
bash scripts/apply_agents.sh

# Apply specific agents globally
bash scripts/apply_agents.sh --agents plan-agent code-agent

# Apply all agents to a local project
bash scripts/apply_agents.sh --local --project-root ~/projects/my-app

# Apply a specific agent to a local project
bash scripts/apply_agents.sh --local --project-root ~/projects/my-app --agents plan-agent
```
