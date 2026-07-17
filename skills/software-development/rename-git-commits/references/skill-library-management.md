# Skill Library Management — Lessons Learned

## README Structure

When maintaining a skill library repo, group skills by category (folder) in README.md:

```markdown
## 📦 Software Development
### ⚡ Skill Name
- **Skill**: `skills/software-development/skill-name/`
- **What**: Brief description

## 📦 DevOps
### 🚀 Another Skill
- **Skill**: `skills/devops/another-skill/`
- **What**: Brief description
```

NOT a flat list. User explicitly requested category-based grouping.

## Platform Skills vs Own Skills

**Platform skills** (from Hermes Agent) should NOT be added to your repo:
- `webhook-subscriptions` — references `hermes webhook` CLI
- `hermes-agent-guide` — references `hermes` CLI
- `plan`, `software-engineering`, `subagent-driven-development`, `writing-plans` — bundled Hermes skills
- `github-workflow` — bundled Hermes skill

**How to tell:** If the skill's `author` field is not your GitHub username, or the skill references `hermes` CLI commands, it's a platform skill.

**Own skills** (created by you):
- `angular-frontend`, `my-frontend-starter` — your frontend skills
- `openplanet-plugin-dev`, `pyplanet` — your game modding skills
- `pursuit-maps` — your data pipeline skill
- `rename-git-commits` — your git workflow skill
- `github-pages-deploy`, `github-actions-node24-scanner` — your devops skills

## Git Rewrite Safety

Before ANY git rewrite (cherry-pick, rebase, filter-branch):
1. Copy ALL skills from `AppData\Local\hermes\skills\` to repo first
2. `git add -A && git commit` to track them
3. THEN do the history rewrite
4. Verify all files still exist after rewrite
5. Verify commit count matches backup BEFORE force push

## Commit Message Format

User-confirmed standard:
- `Fix pursuit-maps v2.0: full pipeline docs` (capital F, space, NO colon after Fix)
- `Add pursuit-maps skill with 249 maps`
- `Update openplanet-plugin-dev to v2.2.0`
- ❌ NOT `fix: add feature` (conventional prefix)
- ❌ NOT `Fix: pursuit-maps` (colon after Fix)
- ❌ NOT `update skill` (lowercase first letter)
