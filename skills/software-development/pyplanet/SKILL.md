---
name: pyplanet
description: "PyPlanet plugin development, GitHub installer, and Clan Spirits plugin"
version: 2.0.0
metadata:
  hermes:
    tags: [pyplanet, maniaplanet, plugin, github, installer, clan-spirits, scoring, template]
---

# 🎮 PyPlanet Skills

Complete PyPlanet plugin ecosystem: starter template, GitHub installer, and Clan Wars plugin.

## 📋 Contents

1. [Hello World](#-hello-world) — starter template
2. [GitHub Installer](#-github-installer) — install plugins from GitHub
3. [Clan Spirits](#-clan-spirits) — competitive clan scoring

---

## 🚀 Hello World

Minimal starter template for PyPlanet plugins.

### When to Use
- Learning PyPlanet plugin structure
- Starting a new plugin
- Understanding AppConfig basics

### Quick Start

**Option 1: Install via GitHub Installer**
```
/ghinstall tomekdot/pyplanet-hello-world
```

**Option 2: Manual Install**
1. Download from https://github.com/tomekdot/pyplanet-hello-world
2. Place `hello_world/` in `apps/`
3. Add `'apps.hello_world'` to `APPS['default']` in `settings/apps.py`
4. Restart PyPlanet

### Template Code

```python
from pyplanet.apps.config import AppConfig

class MyPlugin(AppConfig):
    name = 'my_plugin'

    async def on_start(self):
        await super().on_start()
        await self.instance.chat('✅ My plugin started!')

    async def on_stop(self):
        await super().on_stop()
        await self.instance.chat('🛑 My plugin stopped!')
```

---

## 📦 GitHub Installer

Install PyPlanet plugins directly from GitHub with one command.

### When to Use
- Installing plugins without manual downloads
- Managing multiple plugins
- Updating plugins easily

### Commands

| Command | Description |
|---------|-------------|
| `/ghinstall <user>/<repo>` | Install from GitHub (tries `main` then `master`) |
| `/ghinstall <url.zip>` | Install from direct zip URL |
| `/ghlist` | List all GitHub-installed plugins |
| `/ghremove <name>` | Remove a plugin |
| `/ghupdate <name>` | Update a plugin |

### Installation

1. Create `apps/github_installer/__init__.py`:
```python
from .app import GitHubInstaller
```

2. Create `apps/github_installer/app.py` (source: [github_installer/app.py](https://raw.githubusercontent.com/tomekdot/pyplanet-github-installer/main/github_installer/app.py))

3. Register in `settings/apps.py`:
```python
'apps.github_installer',
```

4. Restart PyPlanet

---

## 🏆 Clan Spirits

Competitive clan/team scoring based on local record positions.

### When to Use
- Setting up clan competitions
- Tracking clan points
- Managing clan members

### Commands

| Command | Description |
|---------|-------------|
| `/joinclan <name>` | Join (or create) a clan |
| `/leaveclan` | Leave current clan |
| `/myclan` | Show your clan + total points |
| `/clans` | Show clan standings |
| `/clanswin` | Open standings window |
| `/clanmembers [name]` | List members of a clan |
| `/clanwexport [format]` | Export standings (csv/json) |
| `/clanw_reset confirm=yes` | Reset all scoring data (admin) |
| `/clanw_recalc` | Recalculate points (admin) |

### Installation

**Option 1: GitHub Installer (recommended)**
```
/ghinstall tomekdot/pyplanet-clanspirits
```

**Option 2: Manual Install**
1. Clone from https://github.com/tomekdot/pyplanet-clanspirits
2. Place `clanwars/` in `apps/`
3. Add `'apps.clanwars'` to `APPS['default']`
4. Restart PyPlanet

### Data Model

```
Clan(id, name)
PlayerClan(player_id, clan_id)
PlayerClanMapScore(map_id, player_id, clan_id, points)
ClanAggregateScore(clan_id, points)
```

---

## 🚨 Requirements

- PyPlanet >= 0.11
- Python 3.8+
- `local_records` app (for Clan Wars)

## 📚 Sources

- **Hello World**: https://github.com/tomekdot/pyplanet-hello-world
- **GitHub Installer**: https://github.com/tomekdot/pyplanet-github-installer
- **Clan Spirits**: https://github.com/tomekdot/pyplanet-clanspirits

> 📄 See `references/original-skills.md` for original skill metadata and source details.

## 📝 License

MIT
