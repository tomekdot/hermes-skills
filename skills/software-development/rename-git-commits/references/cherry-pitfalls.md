# Cherry-Pick Pitfalls — Rename Git Commits

## ⚠️ Critical: Cherry-pick target commits ONLY loses everything after

When using Method 2 (cherry-pick) to rename commits, you MUST cherry-pick ALL commits from the reset point to the branch tip — not just the ones you want to rename.

**Wrong (loses commits after the targets):**
```bash
git reset --hard COMMIT_BEFORE_TARGET
git cherry-pick --no-commit TARGET_1
git commit -m "New message 1"
git cherry-pick --no-commit TARGET_2
git commit -m "New message 2"
# ❌ All commits after TARGET_2 are now gone!
```

**Right (cherry-pick everything):**
```bash
git reset --hard COMMIT_BEFORE_TARGET
git cherry-pick --no-commit TARGET_1
git commit -m "New message 1"
git cherry-pick --no-commit TARGET_2
git commit -m "Original message 2"
# ... continue for ALL remaining commits
git push --force-with-lease origin main
```

**Verify count before pushing:**
```bash
git log --oneline | wc -l
```

## ⚠️ Critical: Cascading conflicts when cherry-picking many commits

When cherry-picking dozens of commits that modify the same files, you WILL get repeated `CONFLICT (add/add)` errors.

**Resolution:**
```bash
git cherry-pick --no-commit SOURCE_SHA
git checkout --theirs .
git add -A
git commit -m "Your message"
```

## ⚠️ Critical: Verify commit count BEFORE force push

```bash
ORIGINAL=$(git log --oneline backup-main | wc -l)
CURRENT=$(git log --oneline | wc -l)
if [ "$ORIGINAL" -ne "$CURRENT" ]; then
    echo "ERROR: Commit count mismatch — DO NOT PUSH"
fi
```

## ⚠️ Anchor sed/gsub patterns

```bash
sed 's/^author: tome$/author: tomekdot/'
```

## ⚠️ git filter-branch unreliable on Windows — DO NOT USE

## ⚠️ git rebase -i --exec doesn't work for amending — use cherry-pick

## ⚠️ GIT_SEQUENCE_EDITOR unreliable on MSYS — use cherry-pick

## ⚠️ Cherry-pick from backup: use SHA hashes, not HEAD~N

```bash
git cherry-pick --no-commit abc1234
```

## ⚠️ Copy skills from AppData BEFORE rewriting history

1. Copy new skills from AppData to repo first
2. `git add -A && git commit`
3. THEN do the history rewrite

## ⚠️ Don't add platform skills to your repo

`webhook-subscriptions`, `hermes-agent-guide`, `plan` etc. are Hermes Agent platform skills — NOT yours.

## Performance note

~1-2 seconds per commit when cherry-picking.
