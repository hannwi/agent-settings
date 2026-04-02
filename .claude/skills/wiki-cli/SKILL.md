---
name: wiki-cli
description: Query, create, update, and manage Confluence Wiki pages from the terminal. Use when working with documentation, wiki pages, searching content, or managing attachments and labels.
argument-hint: [command] [args]
---

# Wiki CLI

Use the `wiki` CLI tool to interact with Confluence Wiki pages, spaces, and content.

## When to Use This Skill

- Viewing or searching Confluence pages
- Creating, updating, or deleting wiki pages
- Managing page versions and history
- Working with attachments and labels
- Navigating page hierarchies
- Converting content formats

## Common Commands

### View & Search
```bash
wiki <page-id>                             # View page content (HTML→MD)
wiki <confluence-url>                      # View page by URL
wiki get-by-title <space-key> "Title"      # Find by title
wiki search "keyword"                      # Search pages
wiki search "API" --space TEAM --first     # Search and show first result
wiki unified-search "keyword"              # Search all content types
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
wiki version <page-id> <n>                 # View specific version
wiki diff <page-id> <old-ver> <new-ver>    # Compare versions
```

### Page Hierarchy
```bash
wiki children <page-id>                    # List child pages
wiki children-all <page-id>                # All child content types
wiki comments <page-id>                    # View comments
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
wiki convert <format> --from <format>      # Convert between formats
echo '<p>HTML</p>' | wiki convert view --from storage
wiki convert editor --from storage < input.html > output.html
```

Available formats: `storage`, `view`, `editor`

## Output Options

All commands support:
- `--json` - Output in JSON format
- `--format <type>` - Output format: text, json, wrapped-json, raw-json
- `--fields <f1,f2>` - Select specific fields
- `--limit <n>` - Limit results
- `--offset <n>` - Pagination offset

## Authentication

The tool uses Personal Access Token from:
1. macOS Keychain: `security find-generic-password -s WIKI_PAT -w`
2. ~/.config/jira-wiki-cli/.env file

Check authentication: `wiki me`

## Exit Codes

- 0: Success
- 1: Input/usage error (fix command syntax)
- 2: Authentication error (check WIKI_PAT)
- 3: Resource not found (verify page ID)
- 4: Network/server error (retryable)
- 5: Timeout (retryable)

## Task Instructions

When executing Wiki operations:

1. **Understand the request** - Identify the specific wiki operation needed

2. **Select the command** - Choose the appropriate `wiki` command based on:
   - View operations: `wiki <page-id>`, `wiki search`
   - Create/Update: `wiki create`, `wiki update`
   - Version control: `wiki versions`, `wiki diff`
   - Attachments: `wiki attach`, `wiki attachments download`

3. **Execute with Bash** - Run the command using the Bash tool

4. **Parse results** - When using `--json`, parse and present key information clearly
   - For page content, the tool auto-converts HTML to Markdown for readability

5. **Handle errors**:
   - Exit code 2: Verify authentication with `wiki me`
   - Exit code 3: Check if page ID exists or search by title
   - Exit code 4/5: Network issues, suggest retry

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
# Update title
wiki update 987654 --title "Updated Title"

# Update content
wiki update 987654 --body "<p>New content</p>"

# Update both
wiki update 987654 --title "New Title" --body "<p>New content</p>"
```

**Version management:**
```bash
# View version history
wiki versions 987654

# Compare two versions
wiki diff 987654 3 4

# View specific version
wiki version 987654 3
```

**Manage attachments:**
```bash
# Upload
wiki attach 987654 ./diagram.png

# List
wiki attachments 987654

# Download
wiki attachments download 987654 "diagram.png" --out ./local-diagram.png
```

**Manage labels:**
```bash
wiki labels 987654
wiki label-add 987654 important
wiki label-add 987654 draft
wiki label-delete 987654 outdated
```

**Navigate hierarchy:**
```bash
# View child pages
wiki children 987654

# View all child content (pages, comments, attachments)
wiki children-all 987654
```

**Content conversion:**
```bash
# Convert storage to view format
echo '<ac:macro>...</ac:macro>' | wiki convert view --from storage

# Convert file
wiki convert editor --from storage < input.html > output.html
```

## Content Format Notes

- Wiki pages use **Confluence Storage Format** (HTML with macros)
- The CLI auto-converts to Markdown for display
- When creating/updating, provide HTML in storage format
- Use `wiki convert` to transform between formats

## Tips

- Use `--json` for programmatic parsing
- Use `--first` with search to fetch and display the first result
- For complex HTML, use stdin: `cat content.html | wiki create --space TEAM --title "Page"`
- Check versions before updating to avoid conflicts: `wiki versions <page-id>`
- Use `wiki get-by-title` when you know the title but not the page ID
- Always verify auth before operations: `wiki me`
- Convert content formats with `wiki convert` for compatibility
