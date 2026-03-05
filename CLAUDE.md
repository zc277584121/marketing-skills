# Development Guide

## Project Overview

This is a Claude Code skills repository. Each skill lives under `skills/<skill-name>/` with a `SKILL.md` and optional `references/` directory.

## Development Workflow

This project supports a **develop-and-test-in-place** workflow. You don't need to install the skills separately — they can be tested directly from this repository.

### How It Works

1. **Edit a skill** — modify `skills/<skill-name>/SKILL.md` or its references.
2. **Test it live** — invoke the skill directly in this project (e.g., use the chrome-automation skill to automate a browser task right here).
3. **Observe and learn** — when testing reveals issues, unexpected behaviors, or missing instructions, **feed those findings back into the skill file immediately**.
4. **Iterate** — repeat until the skill handles real-world scenarios reliably.

### Key Principle: Test-Driven Skill Development

Skills are not written in one shot. The development loop is:

```
Write/Update SKILL.md → Test with real browser tasks → Hit an issue → Fix the skill → Test again
```

When you encounter problems during testing (e.g., a selector strategy doesn't work, an edge case isn't covered, a command behaves differently than expected), update the skill's `SKILL.md` right away with:
- Corrected instructions or command usage
- New edge cases and their workarounds
- Better heuristics for element matching
- Clarified steps that were ambiguous

This means every testing session improves the skill. The skill file is a living document, not a static spec.

### Example

If while testing chrome-automation you discover that `agent-browser --auto-connect tabs` output format changed, or that a certain site requires a specific interaction pattern — update `skills/chrome-automation/SKILL.md` with that knowledge immediately, so the skill gets smarter over time.

## README Maintenance

Every time you add, remove, or update a skill under the `skills/` directory, you **must** also update the project root `README.md`. The README should list all skills grouped by category (e.g., Browser Automation, Video Processing, etc.) so readers can quickly see what's available.
