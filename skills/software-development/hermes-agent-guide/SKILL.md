---
name: hermes-agent-guide
description: "Complete Hermes Agent reference: setup, CLI, config, skills, MCP, gateway, profiles, cron, delegation, skill authoring, and troubleshooting. Use for any Hermes-related question."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [hermes, setup, configuration, skills, authoring, cli, gateway, development]
---

# Hermes Agent — Complete Reference

Hermes Agent is an open-source AI agent framework by Nous Research. It runs in terminals, messaging platforms, and IDEs with any LLM provider.

**Docs:** https://hermes-agent.nousresearch.com/docs/

## 1. Quick Start

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
hermes                    # Interactive chat
hermes chat -q "Query"   # Single query
hermes setup              # Setup wizard
hermes doctor             # Health check
```

## 2. CLI Reference

### Core Commands
```bash
hermes chat [-q QUERY] [-m MODEL] [--provider P] [--toolsets T]
hermes setup [section]    # model|terminal|gateway|tools|agent
hermes config             # View config
hermes config set KEY VAL # Set config value
hermes model              # Interactive model picker
hermes auth add PROVIDER  # Add credential
hermes doctor [--fix]     # Health check
hermes status [--all]     # Component status
hermes update             # Update
```

### Tools & Skills
```bash
hermes tools              # Interactive tool enable/disable
hermes tools list         # Show all tools
hermes skills list        # List installed skills
hermes skills search Q    # Search skills hub
hermes skills install ID  # Install skill
hermes skills update      # Update skills
```

### Gateway
```bash
hermes gateway run        # Start gateway
hermes gateway install    # Install as service
hermes gateway status     # Check status
```

### Sessions & Cron
```bash
hermes sessions list      # List sessions
hermes cron list          # List cron jobs
hermes cron create SCHED  # Create job
```

### Profiles
```bash
hermes profile list       # List profiles
hermes profile create NAME # Create profile
hermes profile use NAME   # Set default
```

## 3. Key Paths

```
~/.hermes/config.yaml       # Main config
~/.hermes/.env              # API keys
~/.hermes/skills/           # Installed skills
~/.hermes/sessions/         # Session transcripts
~/.hermes/state.db          # Session store (SQLite)
~/.hermes/logs/             # Gateway logs
~/.hermes/auth.json         # OAuth tokens
```

## 4. Config Sections

| Section | Key Options |
|---------|-------------|
| `model` | `default`, `provider`, `base_url`, `api_key` |
| `agent` | `max_turns` (90), `tool_use_enforcement` |
| `terminal` | `backend`, `cwd`, `timeout` (180) |
| `compression` | `enabled`, `threshold` (0.50) |
| `display` | `skin`, `show_reasoning`, `show_cost` |
| `memory` | `memory_enabled`, `provider` |
| `delegation` | `model`, `max_iterations` (50) |

## 5. Slash Commands (In-Session)

Key commands: `/new`, `/model`, `/config`, `/skills`, `/skill <name>`, `/tools`, `/cron`, `/curator`, `/kanban`, `/help`, `/exit`.

## 6. Skill Authoring

### Two Skill Locations

1. **User-local:** `~/.hermes/skills/<category>/<name>/SKILL.md` — personal, created via `skill_manage(action='create')`
2. **In-repo:** `skills/<category>/<name>/SKILL.md` — committed, shipped with package, use `write_file`

### Required Frontmatter
```yaml
---
name: skill-name
description: "Use when <trigger>. <one-line behavior>."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [tag1, tag2]
    related_skills: [other-skill]
---
```

### Size Limits
- Description: ≤ 1024 chars
- Full SKILL.md: ≤ 100,000 chars (aim for 8-15k)

### Peer-Matched Structure
```
# Title
## Overview
## When to Use
## <Topic sections>
## Common Pitfalls
## Verification Checklist
```

### ClawHub Publishing
- Format: `metadata.openclaw` (not `metadata.hermes`)
- All skills MIT-0 on ClawHub
- Publish: `clawhub skill publish <path> --version X.Y.Z`
- Login on Windows: use manual Device Flow (browser login broken on MSYS)

Full authoring reference: `references/skill-authoring.md`

## 7. Delegation & Subagents

```python
# Single task
delegate_task(goal="...", context="...", toolsets=["terminal", "file"])

# Batch (parallel)
delegate_task(tasks=[{"goal": "..."}, {"goal": "..."}])
```

- **Not durable** — if parent is interrupted, child is cancelled
- For durable work: use `cronjob` or `terminal(background=True)`

## 8. Cron Jobs

```python
cronjob(action="create", schedule="30m", prompt="...")
# Schedules: "30m", "every 2h", "0 9 * * *", ISO timestamp
```

## 9. MCP Servers

```bash
hermes mcp add NAME --url URL
hermes mcp add NAME --command "cmd"
hermes mcp list
hermes mcp test NAME
```

## 10. Security Toggles

```bash
hermes config set security.redact_secrets true   # Default: on
hermes config set approvals.mode smart            # manual/smart/off
hermes config set privacy.redact_pii false        # Default: off
```

## 11. Troubleshooting

| Problem | Fix |
|---------|-----|
| Tool not available | `hermes tools` → enable toolset, then `/reset` |
| Model issues | `hermes doctor`, check `.env` API key |
| Skills not showing | `hermes skills list`, load via `/skill name` |
| Gateway dies on logout | `sudo loginctl enable-linger $USER` |
| Changes not taking effect | `/reset` (tools), `/restart` (gateway), relaunch (CLI) |

## 12. Windows-Specific Quirks

- **Alt+Enter** toggles fullscreen (doesn't insert newline) — use **Ctrl+Enter** instead
- **UTF-8 BOM** in config causes HTTP 400 — re-save without BOM
- **WinError 10106** in sandbox — `SYSTEMROOT` env var stripped, fixed via `_WINDOWS_ESSENTIAL_ENV_VARS`
- **Tests**: `scripts/run_tests.sh` doesn't work on Windows — use system Python with `PYTHONPATH`

## 13. Voice & Transcription

- **STT**: Local faster-whisper (free), Groq, OpenAI, Mistral
- **TTS**: Edge TTS (free, default), ElevenLabs, OpenAI, MiniMax
- Commands: `/voice on`, `/voice tts`, `/voice off`

## 14. Contributing

- Project layout, adding tools/slash commands, testing: see `references/contributing.md`
- Commit format: `type: description` (feat:, fix:, refactor:, docs:, chore:)
- Never break prompt caching (don't change context/tools mid-conversation)
