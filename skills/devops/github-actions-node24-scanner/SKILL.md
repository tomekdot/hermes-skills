---
name: github-actions-node24-scanner
description: Scan all public GitHub repos for deprecated Node.js 20 Actions and auto-update them to Node.js 24 compatible versions.
version: 1.0.0
metadata:
  hermes:
    tags: [github-actions, node24, devops, scanner, automation, ci-cd]
---

# 🔍 GitHub Actions Node.js 24 Scanner

Scan all public repos for deprecated Node.js 20 Actions and update them to Node.js 24 compatible versions.

## When to use

- You see Node.js 20 deprecation warnings in GitHub Actions logs
- You want to audit all repos for outdated actions
- You want to auto-fix deprecated action versions

## ⚠️ Node.js 20 → 24 Action Mapping

These actions run on Node.js 20 and MUST be updated:

| Old (Node 20) | New (Node 24) |
|---|---|
| `actions/checkout@v4` | `actions/checkout@v6` |
| `actions/upload-artifact@v4` | `actions/upload-artifact@v6` |
| `actions/setup-python@v5` | `actions/setup-python@v6` |

These are already Node.js 24 compatible — no change needed:

| Action | Status |
|---|---|
| `actions/checkout@v6` | ✅ Node 24 |
| `actions/upload-artifact@v6` | ✅ Node 24 |
| `actions/setup-python@v6` | ✅ Node 24 |
| `actions/configure-pages@v5` | ✅ Node 24 |
| `actions/upload-pages-artifact@v3` | ✅ Node 24 |
| `actions/deploy-pages@v4` | ✅ Node 24 |
| `ruby/setup-ruby@v1` | ✅ Node 24 |

## 📋 Steps

### 1. Fetch all public repos

```bash
gh repo list <username> --visibility=public --limit 200 --json name,defaultBranchRef --jq '"\(.name) \(.defaultBranchRef.name)"'
```

### 2. Find repos with workflows

```bash
for repo in $(gh repo list <username> --visibility=public --limit 200 --json name --jq '.[].name'); do
  files=$(gh api "repos/<username>/$repo/contents/.github/workflows" --jq '.[].name' 2>/dev/null)
  if [ -n "$files" ]; then
    echo "=== $repo ==="
    echo "$files"
  fi
done
```

### 3. Download and scan each workflow

Look for: `actions/checkout@v4`, `actions/upload-artifact@v4`, `actions/setup-python@v5`

### 4. Update each file via GitHub API

```bash
SHA=$(gh api repos/<username>/<repo>/contents/.github/workflows/<file> --jq '.sha')
CONTENT=$(gh api repos/<username>/<repo>/contents/.github/workflows/<file> --jq '.content' | base64 -d | sed 's|actions/checkout@v4|actions/checkout@v6|g' | sed 's|actions/upload-artifact@v4|actions/upload-artifact@v6|g' | sed 's|actions/setup-python@v5|actions/setup-python@v6|g' | base64 -w0)

gh api repos/<username>/<repo>/contents/.github/workflows/<file> --method PUT -f message="Update actions to Node.js 24" -f content="$CONTENT" -f sha="$SHA" -f branch="<default_branch>"
```

### 5. Handle repos with non-standard default branches

Some repos use `master` instead of `main`. Always check:

```bash
gh api repos/<username>/<repo> --jq '.default_branch'
```

### 6. Verify

After updating, re-scan to confirm no deprecated actions remain.

## ⚠️ Pitfalls

- **Branch names**: Always use the repo actual default branch (main or master), do not assume.
- **SHA required**: The PUT endpoint requires the current file SHA. If the file changed since you read it, you will get a 422 error — re-fetch the SHA.
- **Other Node 20 actions**: This covers the 3 most common deprecated actions. Other actions may also need updates.
- **Composite actions**: Some workflows use composite actions or third-party actions that may also be on Node 20.
- **Forked repos**: If a repo is a fork, you may not be able to push directly.

## 🔄 Automation

To run this check on a schedule, create a cron job with prompt:

"Scan all my public GitHub repos for deprecated Node.js 20 Actions and update them to Node.js 24 compatible versions."