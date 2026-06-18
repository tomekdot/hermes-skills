---
name: github-workflow
description: "Complete GitHub workflow: auth, repos, issues, PRs, code review, CI/CD pipelines using the gh CLI and git via terminal."
version: 1.0.0
author: tomekdot
license: MIT
metadata:
  hermes:
    tags: [github, gh-cli, git, workflow, ci-cd, pull-request, issues]
---

# GitHub Workflow

Complete GitHub workflow using `gh` CLI and `git` via terminal.

## When to use

- Creating/committing/pushing code
- Managing pull requests and issues
- Code review workflows
- CI/CD pipeline management

## Key commands

```bash
# Auth
gh auth login

# Repos
gh repo create <name> --public --clone
gh repo clone <owner>/<repo>

# Issues
gh issue create --title "..." --body "..."
gh issue list --state open

# PRs
gh pr create --title "..." --body "..."
gh pr list
gh pr checkout <number>
gh pr merge <number> --squash

# CI
gh run list
gh run view <id>
gh run rerun <id>
```

## Workflow

1. Create branch: `git checkout -b feature/name`
2. Commit: `git add -A && git commit -m "Description"`
3. Push: `git push origin feature/name`
4. Create PR: `gh pr create --title "..." --body "..."`
5. Review and merge

## Remember

- First letter always capitalized ("Update..." not "update...")
- No prefixes (feat:, fix:, chore:)
- Plain English commit messages
