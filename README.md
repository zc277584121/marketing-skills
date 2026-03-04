# marketing-skills

A collection of Claude Code skills for marketing automation tasks — browser automation, content workflows, and more.

## Available Skills

| Skill | Description |
|-------|-------------|
| [`chrome-automation`](./skills/chrome-automation/) | Automate Chrome browser tasks using the [agent-browser](https://github.com/vercel-labs/agent-browser) CLI. Navigate pages, fill forms, click buttons, extract data, and replay recorded workflows. |

## Installation

Install using [npx skills](https://skills.sh):

### Install all skills

```bash
npx skills add zc277584121/marketing-skills -a <agent-name>

# Global (available in all projects)
npx skills add zc277584121/marketing-skills -a <agent-name> -g
```

### Examples

```bash
# Claude Code
npx skills add zc277584121/marketing-skills -a claude-code -g

# Cursor
npx skills add zc277584121/marketing-skills -a cursor -g

# Codex
npx skills add zc277584121/marketing-skills -a codex -g
```

### Other Agents

`npx skills` supports 40+ agents. Use `-a <agent-name>` to target any supported agent:

```bash
npx skills add zc277584121/marketing-skills -a <agent-name>
```

Common agent names: `windsurf`, `github-copilot`, `cline`, `roo`, `gemini-cli`, `goose`, `kilo`, `augment`, `opencode`.

> **Project vs Global**: Project-level installs the skill into the current project directory (e.g., `.claude/skills/`). Global (`-g`) installs to your home directory (e.g., `~/.claude/skills/`) so it's available across all projects.

## Updating

```bash
# Check if updates are available
npx skills check

# Update all globally installed skills to latest
npx skills update
```

> **Note**: `npx skills update` only works for globally installed skills (`-g`). For project-level installs, re-run the `npx skills add` command to get the latest version.
