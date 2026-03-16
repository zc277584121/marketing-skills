# marketing-skills

A collection of Claude Code skills for marketing automation tasks — browser automation, content workflows, and more.

## Available Skills

### Browser Automation

| Skill | Description |
|-------|-------------|
| [`chrome-automation`](./skills/chrome-automation/) | Automate Chrome browser tasks using the [agent-browser](https://github.com/vercel-labs/agent-browser) CLI. Navigate pages, fill forms, click buttons, extract data, and replay recorded workflows. |
| [`browser-screenshot`](./skills/browser-screenshot/) | Take focused, region-specific screenshots from web pages. Navigates to the right page based on context (URL, search query, social media post) and crops to the target region. |

### Video Processing

| Skill | Description |
|-------|-------------|
| [`raw-video-processing`](./skills/raw-video-processing/) | Post-process raw screen recordings by removing silent segments and applying speed adjustments. |
| [`video-to-gif`](./skills/video-to-gif/) | Convert a video to multiple GIF variants with different quality/size tradeoffs for visual comparison. |

### Image Processing

| Skill | Description |
|-------|-------------|
| [`screenshot-compression`](./skills/screenshot-compression/) | Compress PNG/JPEG screenshots in place using pngquant and jpegoptim, keeping original format for maximum compatibility. |
| [`mermaid-to-image`](./skills/mermaid-to-image/) | Convert Mermaid code blocks in Markdown files to PNG images using the mermaid.ink API. |
| [`mermaid-to-gif`](./skills/mermaid-to-gif/) | Convert Mermaid diagrams to animated GIFs with customizable animation styles (progressive reveal, highlight walk, pulse flow). |

### Analytics

| Skill | Description |
|-------|-------------|
| [`github-traffic`](./skills/github-traffic/) | Fetch, store, and visualize GitHub repository traffic data (views, clones, referrers, stars) with trend charts. Requires repo push access. |

### Content Creation

| Skill | Description |
|-------|-------------|
| [`jupyter-notebook-writing`](./skills/jupyter-notebook-writing/) | Write Milvus application-level Jupyter notebook examples using a Markdown-first workflow with jupyter-switch. |
| [`remove-ai-style`](./skills/remove-ai-style/) | Review and adjust writing style to reduce AI-generated patterns, making text read more naturally. Supports Chinese and English. |
| [`content-rewrite`](./skills/content-rewrite/) | Adapt content for different platforms (LinkedIn, X, Reddit, English blog, WeChat) with platform-specific tone, format, and length. |

## Quick Start

Install all skills globally to **all supported AI coding agents** with one command:

```bash
npx skills add zc277584121/marketing-skills --all -g
```

Update to the latest version:

```bash
npx skills update
```

## Installation

Install using [npx skills](https://skills.sh):

### Install to all agents at once

```bash
# Global — available in all projects, all agents
npx skills add zc277584121/marketing-skills --all -g

# Project-level — current project only, all agents
npx skills add zc277584121/marketing-skills --all
```

### Install to a specific agent

```bash
npx skills add zc277584121/marketing-skills -a claude-code -g
npx skills add zc277584121/marketing-skills -a cursor -g
npx skills add zc277584121/marketing-skills -a codex -g
```

Other supported agents: `windsurf`, `github-copilot`, `cline`, `roo`, `gemini-cli`, `goose`, `kilo`, `augment`, `opencode`, and [40+ more](https://skills.sh).

> **Project vs Global**: Without `-g`, skills are installed into the current project directory (e.g., `.claude/skills/`). With `-g`, they go to your home directory (e.g., `~/.claude/skills/`) and are available across all projects.

## Updating

```bash
# Check for updates
npx skills check

# Update all globally installed skills to latest
npx skills update
```

To update project-level installs, re-run the `npx skills add` command.
