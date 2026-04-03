---
name: jira-cli
description: Query, create, update, and manage Jira issues from the terminal. Use this skill whenever the user wants to work with Jira — viewing or searching tickets, creating or updating issues, managing comments, attachments, worklogs, sprints, epics, boards, or transitioning issue workflows. Trigger even if the user just pastes an issue key like PROJ-123 or asks about issue status, assignment, sprint planning, or JQL searches.
---

# Jira CLI

Use the `jira` CLI tool to interact with Jira issues, projects, and boards.

> **Prerequisites:** Installation and authentication setup required before use.
> See [https://git.linecorp.com/sang-mook-kang/jira-wiki-cli](https://git.linecorp.com/sang-mook-kang/jira-wiki-cli) for instructions.

## Common Commands

### View & Search
```bash
jira <issue-key>                           # View issue details
jira <issue-key> --json                    # Get JSON output
jira <issue-key> --attachments             # Include attachment list
jira search "JQL query"                    # Search with JQL
jira comments <issue-key>                  # View comments
jira transitions <issue-key>               # View available transitions
jira changelogs <issue-key>                # View change history
jira worklogs <issue-key>                  # View worklogs
jira watchers <issue-key>                  # View watchers
jira subtasks <issue-key>                  # View subtasks
jira links <issue-key>                     # View issue links
jira remote-links <issue-key>              # View remote links
```

### Create & Update
```bash
jira create --project <key> --type <type> --summary "Title"
jira create --project PROJ --type Task --summary "Title" --description "Details"
jira update <issue-key> --summary "New title"
jira update <issue-key> --assignee <accountId> --priority High
jira delete <issue-key> --force
jira clone <issue-key>
```

### Workflow
```bash
jira transition <issue-key> <transitionId>  # Change status
jira comment <issue-key> "Comment text"     # Add comment (stdin supported)
jira worklog-add <issue-key> "2h"           # Log work
```

### Attachments
```bash
jira attachments <issue-key>                              # List attachments
jira attach <issue-key> <file-path>                       # Upload file
jira attachments download <issue-key> <filename>          # Download file
jira detach <attachment-id>                               # Delete attachment
```

### Links
```bash
jira links <issue-key>                                    # View links
jira link <issue-key> <target-key> --type Blocks          # Link issues
jira unlink <link-id>                                     # Remove link
jira remote-link-add <issue-key> --url <url> --title "Title"
jira remote-link-update <issue-key> <linkId> --url <url> --title "Title"
jira remote-link-delete <issue-key> <linkId>
```

### Projects & Boards
```bash
jira projects                              # List all projects
jira project <key>                         # View project details
jira boards                                # List boards
jira sprints <board-id>                    # List sprints
jira sprint <sprint-id> --issues           # View sprint issues
jira backlog <board-id>                    # View backlog
jira epics <board-id>                      # List epics
jira epic <key>                            # View epic details (--issues)
```

### Sprint Management
```bash
jira sprint-create --board <id> --name "Sprint 1"
jira sprint-update <sprint-id> --state active
jira sprint-delete <sprint-id> --force
```

### Metadata
```bash
jira meta fields                           # List all fields
jira meta issue-types                      # List issue types
jira meta statuses                         # List statuses
jira meta priorities                       # List priorities
jira meta resolutions                      # List resolutions
jira meta link-types                       # List link types
jira me                                    # Current user info
jira user <accountId>                      # View user info
jira assignable <issue-key>                # List assignable users
```

## Output Options

All commands support:
- `--json` - Output in JSON format
- `--format <type>` - Output format: `text`, `json`, `wrapped-json`, `raw-json`
- `--fields <f1,f2>` - Select specific fields
- `--limit <n>` - Limit results
- `--offset <n>` - Pagination offset

## Authentication

The tool loads credentials in this order:
1. macOS Keychain: `security find-generic-password -s JIRA_PAT -a "$USER" -w` (Recommended for security)
2. `~/.config/jira-wiki-cli/.env` file (`JIRA_PAT=<token>`)

Check authentication: `jira me`

## Exit Codes

| Code | Meaning | Retryable |
|:---:|---------|:---------:|
| 0 | Success | — |
| 1 | Input/usage error | No |
| 2 | Authentication error (check JIRA_PAT) | No |
| 3 | Resource not found | No |
| 4 | Network/server error | Yes |
| 5 | Timeout | Yes |

## Task Instructions

When executing Jira operations:

1. **Understand the request** — Identify the specific Jira operation needed
2. **Select the command** — Choose the appropriate `jira` subcommand
3. **Execute with Bash** — Run the command using the Bash tool
4. **Parse results** — When using `--json`, extract and present key fields clearly
5. **Handle errors**:
   - Exit code 2: Verify auth with `jira me`
   - Exit code 3: Confirm the issue key or resource exists
   - Exit code 4/5: Network issue — suggest retry

## Examples

**Search and view issues:**
```bash
jira search "project = PROJ AND status = 'In Progress'" --limit 10
jira PROJ-123
jira PROJ-123 --json | jq '.fields.summary'
```

**Create and update:**
```bash
jira create --project PROJ --type Task --summary "Fix login bug" --priority High
jira update PROJ-123 --summary "Updated title" --assignee 12345
```

**Workflow management:**
```bash
# Check available transitions
jira transitions PROJ-123

# Transition to new status
jira transition PROJ-123 31

# Add comment
jira comment PROJ-123 "Code review completed"
```

**Work with attachments:**
```bash
jira attach PROJ-123 ./screenshot.png
jira attachments PROJ-123
jira attachments download PROJ-123 "screenshot.png" --out ./downloaded.png
```

**Link issues:**
```bash
jira link PROJ-123 PROJ-456 --type Blocks
jira links PROJ-123
```

## Tips

- Use `--json` for programmatic parsing or piping to other tools
- Check `jira meta` commands to discover available values before creating/updating
- For long text input, use stdin: `echo "text" | jira comment PROJ-123`
- Always verify auth before operations: `jira me`
- Use JQL for complex searches: `assignee = currentUser() AND status != Closed`
- Exit codes 4 and 5 are retryable — network/timeout errors
