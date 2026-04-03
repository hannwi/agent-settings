---
name: wiki-cli
description: Query, create, update, and manage Confluence Wiki pages from the terminal. Use this skill whenever the user wants to work with Confluence — viewing or searching wiki pages, creating or updating documentation, managing page versions, navigating page hierarchies, handling attachments and labels, or working with spaces. Trigger even if the user just pastes a page ID or Confluence URL, or asks about wiki content, documentation pages, or team spaces.
---

# Wiki CLI

Use the `wiki` CLI tool to interact with Confluence Wiki pages, spaces, and content.

> **Prerequisites:** Installation and authentication setup required before use.
> See [https://git.linecorp.com/sang-mook-kang/jira-wiki-cli](https://git.linecorp.com/sang-mook-kang/jira-wiki-cli) for instructions.

## Common Commands

### View & Search
```bash
wiki <page-id>                             # View page content (HTML→MD)
wiki <confluence-url>                      # View page by URL
wiki get-by-title <space-key> "Title"      # Find by title
wiki search "keyword"                      # Search pages (CQL)
wiki search "API" --space TEAM --first     # Search and show first result
wiki unified-search "keyword"              # Search all content types (pages, blogs, attachments)
```

### Create & Update
```bash
wiki create --space <key> --title "Title"
wiki create --space TEAM --title "Page" --body "<p>Content</p>"
wiki create --space TEAM --title "Sub Page" --parent <page-id>
wiki update <page-id> --title "New Title"
wiki update <page-id> --body "<p>New content</p>"
wiki delete <page-id> --force
```

### Version History
```bash
wiki history <page-id>                     # View history summary
wiki versions <page-id>                    # List all versions
wiki version <page-id> <n>                 # View specific version metadata
wiki diff <page-id> <old-ver> <new-ver>    # Compare versions (line diff)
```

### Page Hierarchy
```bash
wiki children <page-id>                    # List child pages
wiki children-all <page-id>               # All child content types (page/comment/attachment)
wiki comments <page-id>                   # View comments
```

### Attachments
```bash
wiki attachments <page-id>                              # List attachments
wiki attach <page-id> <file-path>                       # Upload file
wiki attachments download <page-id> <filename>          # Download file
wiki attachments download <page-id> <filename> --out <path>
```

### Labels
```bash
wiki labels <page-id>                      # View labels
wiki label-add <page-id> <label>           # Add label
wiki label-delete <page-id> <label>        # Remove label
```

### Spaces
```bash
wiki spaces                                # List all spaces
wiki space <space-key>                     # View space details
wiki space-content <space-key>             # List space content
wiki space-content <space-key> --type page
```

### Activity
```bash
wiki activity                              # Pages I contributed to
wiki recent                                # Recently viewed pages
wiki me                                    # Current user info
```

### Content Conversion
```bash
wiki convert <format> --from <format>      # Convert between formats (stdin supported)
echo '<p>HTML</p>' | wiki convert view --from storage
wiki convert editor --from storage < input.html > output.html
```

Available formats: `storage`, `view`, `editor`

## Output Options

All commands support:
- `--json` - Output in JSON format
- `--format <type>` - Output format: `text`, `json`, `wrapped-json`, `raw-json`
- `--fields <f1,f2>` - Select specific fields
- `--limit <n>` - Limit results
- `--offset <n>` - Pagination offset

## Authentication

The tool loads credentials in this order:
1. macOS Keychain: `security find-generic-password -s WIKI_PAT -a "$USER" -w` (Recommended for security)
2. `~/.config/jira-wiki-cli/.env` file (`WIKI_PAT=<token>`)

Check authentication: `wiki me`

## Exit Codes

| Code | Meaning | Retryable |
|:---:|---------|:---------:|
| 0 | Success | — |
| 1 | Input/usage error | No |
| 2 | Authentication error (check WIKI_PAT) | No |
| 3 | Resource not found | No |
| 4 | Network/server error | Yes |
| 5 | Timeout | Yes |

## Task Instructions

When executing Wiki operations:

1. **Understand the request** — Identify the specific wiki operation needed
2. **Select the command** — Choose the appropriate `wiki` subcommand
3. **Execute with Bash** — Run the command using the Bash tool
4. **Parse results** — When using `--json`, extract and present key fields clearly
   - Page content is auto-converted from HTML to Markdown for readability
5. **Handle errors**:
   - Exit code 2: Verify auth with `wiki me`
   - Exit code 3: Confirm the page ID exists, or search by title
   - Exit code 4/5: Network issue — suggest retry

## Examples

**Search and view pages:**
```bash
wiki search "onboarding guide" --space TEAM
wiki search "API docs" --first  # Show first result immediately
wiki 987654
wiki get-by-title TEAM "Release Notes"
```

**Create new pages:**
```bash
wiki create --space TEAM --title "New Guide" --body "<p>Introduction</p>"

# Create child page
wiki create --space TEAM --title "Sub Page" --parent 987654 --body "<p>Details</p>"

# Use stdin for complex content
cat content.html | wiki create --space TEAM --title "Documentation"
```

**Update existing pages:**
```bash
wiki update 987654 --title "Updated Title"
wiki update 987654 --body "<p>New content</p>"
wiki update 987654 --title "New Title" --body "<p>New content</p>"
```

**Version management:**
```bash
wiki versions 987654
wiki diff 987654 3 4
wiki version 987654 3
```

**Manage attachments:**
```bash
wiki attach 987654 ./diagram.png
wiki attachments 987654
wiki attachments download 987654 "diagram.png" --out ./local-diagram.png
```

**Manage labels:**
```bash
wiki labels 987654
wiki label-add 987654 important
wiki label-delete 987654 outdated
```

## Content Format Notes

- Wiki pages use **Confluence Storage Format** (HTML with macros)
- The CLI auto-converts to Markdown when displaying content
- When creating/updating, provide HTML in storage format
- Use `wiki convert` to transform between storage, view, and editor formats

## Tips

- Use `--json` for programmatic parsing or piping to other tools
- Use `--first` with search to immediately fetch and display the first result
- For complex HTML, use stdin: `cat content.html | wiki create --space TEAM --title "Page"`
- Check versions before updating to avoid conflicts: `wiki versions <page-id>`
- Use `wiki get-by-title` when you know the title but not the page ID
- Always verify auth before operations: `wiki me`
- Exit codes 4 and 5 are retryable — network/timeout errors
