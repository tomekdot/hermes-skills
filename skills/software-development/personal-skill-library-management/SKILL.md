---
name: personal-skill-library-management
description: "Maintain a personal Hermes skill library: structure, syncing, and publishing workflow. Use when organizing custom skills, syncing between local repo and Hermes, or adding new skills to your library."
version: 1.2.0
author: tome
license: MIT
metadata:
  hermes:
    tags: [skill-library, sync, workflow, hermes, management]
---

# Personal Skill Library Management

Complete workflow for maintaining a personal Hermes skill library.

## Frontmatter Standard

See `references/skill-frontmatter-standard.md` for the complete reference.

Quick reminder:
- `license: MIT` (never MIT-0)
- `metadata.hermes.tags` (never `metadata.openclaw`)
- `author: tome`
- `description` always quoted

## Skill Library Sync

## 📂 Standard Structure

```
hermes-skills/
├── skills/
│   ├── devops/
│   │   └── my-skill/
│   │       ├── SKILL.md
│   │       ├── references/
│   │       └── templates/
│   └── software-development/
│       └── another-skill/
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

## 🔄 3-Way Sync Workflow

### Problem
After reinstall/machine change, skills are scattered:
- Repo on GitHub ✅
- Local repo outdated ❌
- Hermes skill dir missing skills ❌

### Solution (run once after reinstall)

**Step 1: Clone/update local repo**
```bash
cd ~
git clone https://github.com/USERNAME/hermes-skills.git
# or if already exists:
cd ~/hermes-skills && git pull origin main
```

**Step 2: Copy from local repo → Hermes skill dir**
```bash
# Windows (git-bash paths)
cp -r ~/hermes-skills/skills/* "/c/Users/USERNAME/AppData/Local/hermes/skills/"
```

**Step 3: Verify**
```bash
# In Hermes, run:
# /skills_list
# Should show your custom skills
```

## ➕ Adding a New Skill

1. **Create in local repo** (never directly in Hermes skill dir):
   ```bash
   cd ~/hermes-skills/skills/software-development/
   mkdir my-new-skill
   # Create SKILL.md + references/ + templates/
   ```

2. **Copy to Hermes immediately** (for testing):
   ```bash
   cp -r my-new-skill "/c/Users/USERNAME/AppData/Local/hermes/skills/software-development/"
   ```

3. **Commit + push to GitHub**:
   ```bash
   cd ~/hermes-skills
   git add -A
   git commit -m "Add my-new-skill"
   git push origin main
   ```

## 🚨 Pitfalls

### Wrong Metadata Format
- **NEVER** use `metadata.openclaw` — always `metadata.hermes`
- **NEVER** use `license: MIT-0` — always `license: MIT`
- **ALWAYS** quote the `description` field
- See `references/skill-frontmatter-standard.md` for the full spec

### Merging Skills
When merging multiple narrow skills into one class-level umbrella:
- Keep ALL content from all source skills
- Use a class-level name (not a specific feature name)
- Preserve all commands, models, install methods
- Keep all GitHub URLs (even if some repos are renamed)


### ❌ `patch` tool fails on identical strings
When you need to change a field value (e.g. `author: tome` → `author: tomekdot`), the `patch` tool refuses because old_string == new_string. Workaround: use `sed` via terminal:
```bash
# Replace ALL occurrences of "tome" with "tomekdot" across all skill files
cd ~/hermes-skills
for f in skills/*/*/SKILL.md; do sed -i 's/tome/tomekdot/g' "$f"; done
```
Note: `sed` replaces ALL occurrences — review the file afterward to ensure only the `author` field changed.

### ❌ `write_file` truncates large files
The `write_file` tool only writes ~974 bytes. For large files (>1KB), use `patch` for targeted edits or `git add -A && git commit` after terminal edits. Never use `write_file` to rewrite a large SKILL.md — it will truncate content.

### ❌ `git filter-branch` times out
`git filter-branch --msg-filter` times out on large repos. Use cherry-pick method (Method 2b in `rename-git-commits` skill) instead for rewriting commit messages.

### ❌ Don't forget `git pull` before `git push`
If GitHub has newer commits, push will fail. Always pull first:
```bash
cd ~/hermes-skills
git pull --rebase origin main
git push origin main
```

### ❌ Windows path gotcha
Hermes skill dir is at `C:\Users\USERNAME\AppData\Local\hermes\skills\`
In git-bash, use `/c/Users/USERNAME/AppData/Local/hermes/skills/`

### ❌ Skill not appearing in Hermes?
- Check SKILL.md exists (exact case!)
- Check skill is in correct category folder
- Restart Hermes Agent to reload skills

## 📝 README Maintenance

Keep `hermes-skills/README.md` updated with full skill list. Format:
```markdown
### 🚨 DevOps
| Skill | Description |
|-------|-------------|
| `my-skill` | What it does |
```

## 🔍 Verify Sync

After any change, verify all three locations match:
1. GitHub: check repo online
2. Local repo: `ls ~/hermes-skills/skills/*/`
3. Hermes: `/skills_list` and filter for your skills
