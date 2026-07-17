---
name: rename-git-commits
description: Rewrite commit messages in git history. Non-interactive methods for Windows/MSYS environments. Safe patterns without PTY.
version: 1.2.0
author: tomekdot
metadata:
  hermes:
    tags: [git, github, rebase, commits, workflow]
---

# Rename Git Commits

## User preferences (MUST follow)
- Execute immediately when user says "popraw", "zrób", "dodaj" — NO verbose explanations
- Be fully autonomous — user trusts the agent to handle the full workflow
- Keep output minimal — short confirmations, emoji status (✅/❌/⚠️), no long summaries unless asked
- When something fails, say what failed and try an alternative — don't ask "what should I do?"

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

⚠️ **SUPERSEDED** (2026-07 session): the OLD rule "plain English, no conventional
prefixes, `Fix ` with a space" is NO LONGER the user's preference. The user now
wants **capitalized conventional prefixes WITH a colon**, and a capital letter
right after the colon. This is the current standard.

**Current rules (user-confirmed 2026-07):**
- Prefix is a capitalized conventional type + colon: `Feature:`, `UI:`, `Fix:`,
  `Docs:`, `Chore:`, `Brand:`
- The FIRST letter of the description (right after the colon + space) is
  capitalized too: `Fix: Real vertical gaps...`, `Docs: Sync TODO board...`
- Map lowercase conventional prefixes onto the capitalized form:
  `feat:`/`deploy:` → `Feature:`, `ui:` → `UI:`, `fix:` → `Fix:`,
  `docs:` → `Docs:`, `chore:` → `Chore:`, `brand:` → `Brand:`
- `Revert "..."` commits are LEFT UNTOUCHED (fidelity to the quoted original
  message — do not capitalize inside the quotes).
- Commits with NO prefix keep their existing style (usually already
  capitalized sentence, e.g. `Switch default dev port from 8000 to 8698`).
- Author/committer should read `tomekdot` (set in committer config), not the
  legacy `Tomasz Kaczak` identity — see Method 5 / date-author recipe.

**Bulk-normalize prefixes** (the common case) with `filter-branch --msg-filter`
+ `sed` — see **Method 6** and `references/bulk-msg-rewrite.md`. Do NOT hand-edit
each commit for a repo-wide rename.

**Examples (current):**
- ✅ `Feature: Simple Render blueprint (web+db, no Celery/Redis) for shared instance`
- ✅ `UI: Add breathing room to cards, action bar, and sidebar`
- ✅ `Fix: Real vertical gaps in listening-history list`
- ✅ `Docs: Sync TODO board (UI-01/02/TRK-01 done, add Phase D.1 roadmap)`
- ✅ `Revert "docs: fix overclaim in Core Features..."` (untouched)
- ❌ `feat: add feature` — lowercase prefix (should be `Feature:`)
- ❌ `ui: add breathing room` — lowercase prefix (should be `UI:`)
- ❌ `Fix: real vertical gaps` — lowercase after colon (should be `Fix: Real...`)
- ❌ `update skill` — lowercase first letter
- ❌ `Add pursuit-maps skill: 249 maps` — colon after skill name

---

## Method 5: Rewrite commit DATE and/or AUTHOR (filter-branch)

Use when you must change author/committer **name, email, or date** of a subset
of commits (e.g. old commits carry a different git identity, or you want to
redate a batch). Not message text — for that use Methods 2/4. Full working
recipe + pitfalls (incl. the `--force-with-lease` "stale info" trap) in
`references/filter-branch-date-author.md`.

```bash
git branch "backup-dates-$(date +%Y%m%d)"          # 0. backup
git stash push -u -m "wip-before-date-rewrite"      # 1. clean tree (REQUIRED)
export FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch -f --env-filter '
  ad=$(git log -1 --format=%ad --date=short "$GIT_COMMIT")
  case "$ad" in
    2025-*)                                        # condition: only these
      export GIT_AUTHOR_NAME="tomekdot"
      export GIT_AUTHOR_EMAIL="tomaszkaczak@protonmail.com"
      export GIT_COMMITTER_NAME="tomekdot"
      export GIT_COMMITTER_EMAIL="tomaszkaczak@protonmail.com"
      export GIT_AUTHOR_DATE="2026-07-17T12:00:00 +0200"
      export GIT_COMMITTER_DATE="2026-07-17T12:00:00 +0200"
      ;;
  esac
' -- --all
git stash pop                                        # restore WIP
git fetch origin                                     # REQUIRED before lease (P2)
git push --force-with-lease origin main              # history rewritten
```

⚠️ Changing ANY date/name at the root rewrites the ENTIRE branch's hashes →
force-push mandatory, collaborators must re-pull/re-clone.

## Method 6: Bulk rewrite of MESSAGE TEXT (filter-branch --msg-filter)

When the user wants a repo-wide message normalization (e.g. lowercase
conventional prefixes `feat:`/`ui:`/`fix:` → capitalized `Feature:`/`UI:`/`Fix:`,
AND a capital letter after the colon), do it with `filter-branch --msg-filter` +
`sed` — NOT by hand-editing each commit. Full recipe + the background-timeout
and fetch-before-lease traps in `references/bulk-msg-rewrite.md`.

```bash
git branch "backup-msg-$(date +%Y%m%d%H%M)"      # 0. backup
git stash push -u -m "wip-before-msg-rewrite"    # 1. clean tree (REQUIRED)
export FILTER_BRANCH_SQUELCH_WARNING=1
# Run in background if repo is large (131+ commits exceeds the 60s fg limit):
git filter-branch -f --msg-filter '
  sed -E "
    s/^fix:/Fix:/;  s/^docs:/Docs:/;  s/^chore:/Chore:/;  s/^brand:/Brand:/;
    s/^ui:/UI:/;    s/^feat:/Feature:/;  s/^deploy:/Feature:/;
    s/^(Fix: )([a-z])/\1\u\2/;   s/^(Docs: )([a-z])/\1\u\2/;
    s/^(Chore: )([a-z])/\1\u\2/; s/^(Brand: )([a-z])/\1\u\2/;
    s/^(UI: )([a-z])/\1\u\2/;    s/^(Feature: )([a-z])/\1\u\2/
  "
' -- --all
git stash pop                                     # restore WIP
git fetch origin                                  # REQUIRED before lease
git push --force-with-lease origin main           # history rewritten
```

⚠️ `--msg-filter` changes hashes of EVERY commit git walks (so `-- --all`
rewrites all branches + the `origin/main` ref too). Force-push is mandatory.
⚠️ GNU `sed` on MSYS **does** support `\u\2` (capitalize the matched group) —
this works, do not avoid it.
⚠️ `Revert "..."` messages are intentionally left untouched (the inner quote
is a literal reference to the reverted commit).

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

## Library Management

See `references/skill-library-management.md` for:
- README structure (group by category, not flat list)
- Platform skills vs own skills distinction
- Git rewrite safety checklist
- Commit message format standard

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
- git filter-branch DOES work on Windows/MSYS for date/author rewrites — the
  "unreliable on Windows" note is FALSE; see `references/filter-branch-date-author.md`
- Date/author rewrite via filter-branch: full recipe + PITFALLS (stash -u,
  fetch-before-lease) in `references/filter-branch-date-author.md`
- **Bulk MESSAGE rewrite via `filter-branch --msg-filter`**: full recipe +
  pitfalls (background timeout, force-with-lease "stale info", date-vs-author
  correction) in `references/bulk-msg-rewrite.md`
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

- ✅ `Feature: Simple Render blueprint (web+db, no Celery/Redis) for shared instance`
- ✅ `UI: Add breathing room to cards, action bar, and sidebar`
- ✅ `Fix: Real vertical gaps in listening-history list`
- ✅ `Docs: Sync TODO board (UI-01/02/TRK-01 done, add Phase D.1 roadmap)`
- ❌ `feat: add feature` — lowercase prefix (should be `Feature:`)
- ❌ `Fix: real vertical gaps` — lowercase after colon (should be `Fix: Real...`)
- Repo-wide message pass → use Method 6 (filter-branch --msg-filter), not
  hand-editing each commit; see `references/bulk-msg-rewrite.md`.
- After push: either amend + force-push (dangerous on shared branches) OR new empty commit (safe)

## ⚠️ Git Repository Lost (.git deleted)

If `.git` folder is accidentally deleted (e.g. by AI Studio or IDE):

```bash
git init
git remote add origin https://github.com/USER/REPO.git
git add -A
git commit -m "Reinit after .git loss"
git branch -m master main  # if branch is master instead of main
git push origin main --force
```

**When to use:** `git status` returns "not a git repository", or `git log` fails with "Not a valid object name HEAD".

**Note:** Force push rewrites remote history. Only use when local files are the correct/complete version (e.g. after AI Studio deletes `.git` but source files are intact).