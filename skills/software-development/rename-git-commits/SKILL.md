---
name: rename-git-commits
description: Rewrite commit messages in git history. Non-interactive methods for Windows/MSYS environments. Safe patterns without PTY.
version: 1.1.0
metadata:
  hermes:
    tags: [git, github, rebase, commits, workflow]
---

# Rename Git Commits

## When to use

- Fix typo in commit message
- Change lowercase to capitalized ("update" → "Update")
- Add missing context
- Remove sensitive info

## Safety rules

⚠️ **Never rewrite commits that are pushed and cloned by others** — breaks their history.

If commits are already on GitHub and others may have them:
- ✅ Create a new commit with fix
- ❌ Don't force push shared branches

---

## Method 1: Last commit (before push)

```bash
git commit --amend -m "Update: proper capitalization"
```

---

## Method 2: Multiple commits (before push, no PTY needed)

Works on Windows/MSYS without interactive editor:

```bash
# 1. Create backup branch
git branch backup-main

# 2. Reset to commit BEFORE the ones you want to change
git reset --hard COMMIT_BEFORE_TARGET

# 3. Cherry-pick EACH commit from reset point to branch tip
#    ⚠️ You MUST cherry-pick ALL commits, not just the ones you want to rename!
#    Commits you don't rename: cherry-pick + commit with original message
#    Commits you rename: cherry-pick + commit with new message
git cherry-pick --no-commit TARGET_COMMIT
git commit -m "Fix: new correct message"

git cherry-pick --no-commit NEXT_COMMIT
git commit -m "Original message"  # keep as-is

# ... continue for EVERY remaining commit to branch tip

# 5. Verify count matches original — HARD CHECK before push
ORIGINAL=$(git log --oneline backup-main | wc -l)
CURRENT=$(git log --oneline | wc -l)
if [ "$ORIGINAL" -ne "$CURRENT" ]; then
    echo "❌ FATAL: Commit count mismatch (original=$ORIGINAL, current=$CURRENT)"
    echo "DO NOT PUSH. You lost commits. Restore from backup and retry."
    git reset --hard backup-main
    exit 1
fi
echo "✅ Commit count matches ($CURRENT)"

# 6. If OK, force push
git push --force-with-lease origin main
```

**⚠️ CRITICAL**: You must cherry-pick ALL commits from the reset point to the branch tip. Cherry-picking only the target commits loses everything after them. See `references/cherry-pitfalls.md` for details.

Example — fix last 2 commits:

```bash
git branch backup
git reset --hard HEAD~2
git cherry-pick --no-commit HEAD@{2}
git commit -m "Update openplanet-plugin-dev to v2.1.0 with merged skills and quirks"
git cherry-pick --no-commit HEAD@{1}
git commit -m "Update openplanet-plugin-dev to v2.2.0"
git push --force-with-lease origin main
```

## Method 2b: Already pushed — cherry-pick to new branch (force push required)

When commits are already on GitHub and you need to rewrite messages:

```bash
# 1. Create backup
git branch backup-main

# 2. Create new branch from backup
git checkout -b rewritten backup-main

# 3. Reset to commit BEFORE the ones to change
git reset --hard COMMIT_BEFORE_TARGET

# 4. Cherry-pick each commit with new message
git cherry-pick --no-commit OLD_SHA_1
git commit -m "New plain English message"

git cherry-pick --no-commit OLD_SHA_2
git commit -m "Another plain English message"

# 5. Cherry-pick remaining commits (unchanged)
git cherry-pick --no-commit OLD_SHA_3
git commit -m "$(git log -1 --format='%s' OLD_SHA_3)"

# 6. Verify
git log --oneline -10

# 7. Force push (rewrites history!)
git push --force-with-lease origin rewritten:main
```

⚠️ **WARNING**: This rewrites history. Anyone who cloned the repo will have conflicts. Only do this on personal repos with no collaborators.

## Commit Message Standard

**Rules (user-confirmed):**
- First letter ALWAYS capitalized
- Plain English, no conventional prefixes (`feat:`, `fix:`, `chore:`)
- `Fix ` prefix for bug fixes and corrections (capital F, space, NO colon)
- `Add ` prefix for new features/content
- `Update ` prefix for modifications
- `Rename ` prefix for renames
- `Remove ` prefix for deletions
- `Replace ` prefix for replacements
- No colon after the action word unless the description naturally needs one

**Examples:**
- ✅ `Fix pursuit-maps v2.0: full pipeline docs, English, structured`
- ✅ `Fix pursuit-maps: add pursuit_maps_sync.py (full data sync tool)`
- ✅ `Fix pursuit-maps v1.1.0: add generator + MX enricher scripts, update SKILL.md`
- ✅ `Fix pursuit-maps skill: add 249 maps from ManiaPlanet Feedback S1 E1`
- ✅ `Fix pyplanet skill: add merged pyplanet plugin development skill`
- ✅ `Fix README: add PyPlanet skill to skills list`
- ✅ `Fix devops skills: add github-actions-node24-scanner, github-pages-deploy, webhook-subscriptions`
- ✅ `Add pursuit-maps skill with 249 maps from ManiaPlanet Feedback`
- ✅ `Update openplanet-plugin-dev to v2.2.0`
- ✅ `Fix broken reference link in openplanet-plugin-dev`
- ✅ `Rename clanspirit to clanspirits and fix license`
- ❌ `pursuit-maps v2.0: full pipeline docs` — lowercase first letter
- ❌ `fix: add feature` — conventional commit prefix
- ❌ `Fix: pursuit-maps v2.0` — colon after Fix (wrong: `Fix:`)
- ❌ `update skill` — lowercase first letter
- ❌ `Add pursuit-maps skill: 249 maps` — colon after skill name

---

## Method 3: Already pushed — create follow-up commit (safest)

When force push is too risky, add a note:

```bash
git commit --allow-empty -m "Update: correct previous commit messages (capitalization)"
git push origin main
```

---

## Method 4: Single older commit (before push)

Using interactive rebase with non-interactive editor:

```bash
# Set non-interactive editor
GIT_SEQUENCE_EDITOR="sed -i 's/^pick/reword/'" git rebase -i COMMIT_HASH^

# Then provide new message via EDITOR
EDITOR="sed -i '1s/.*/Update: new message/'" git rebase --continue
```

Note: This may not work on all MSYS setups. Method 2 (cherry-pick) is more reliable.

---

## Quick reference

| Goal | Command |
|------|---------|
| Amend last commit | `git commit --amend -m "New message"` |
| Show last N commits | `git log --oneline -N` |
| Fix multiple commits | cherry-pick --no-commit + re-commit (see pitfalls below) |
| Undo all local changes | `git reset --hard origin/main` |
| Safe force push | `git push --force-with-lease origin main` |

---

## Pitfalls

See `references/cherry-pitfalls.md` for detailed pitfalls including:
- Cherry-pick only target commits loses everything after them
- sed/gsub anchoring when old string is a prefix of new string
- filter-branch SHA prefix vs message content matching
- Windows/MSYS performance considerations
- git filter-branch is unreliable on Windows (timeouts, corrupted history)
- GIT_SEQUENCE_EDITOR with sed may silently fail on MSYS
- git rebase -i --exec with commit --amend doesn't work
- Always copy skills from AppData to repo BEFORE rewriting history
- Verify commit count BEFORE force push
- Platform skills (webhook-subscriptions etc.) are NOT yours
- Cascading conflicts when cherry-pick many commits

### Windows/MSYS without PTY

When working on Windows with git-bash/MSYS (no PTY available):
- `git rebase -i` opens an interactive editor that cannot be used
- `GIT_SEQUENCE_EDITOR` with `sed` may work for simple cases but breaks on merge conflicts
- Cherry-pick method (Method 2b) works but requires handling conflicts with `git checkout --theirs <file>`
- When cherry-picking commits that modify the same files: `git cherry-pick --no-commit && git checkout --theirs . && git add -A && git commit`
- For commits already on GitHub that can't be cleanly cherry-picked, **Method 3 (follow-up commit) is the safest fallback**

## Remember

- ❌ `update skill` — lowercase first letter
- ✅ `Update skill` — capital first letter
- ❌ `feat: add feature` — conventional commit prefix
- ✅ `Add feature` — plain English, no prefix
- After push: either amend + force-push (dangerous on shared branches) OR new empty commit (safe)