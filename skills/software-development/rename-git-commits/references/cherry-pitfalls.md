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
# Cherry-pick EACH commit in order, including ones you don't need to rename
git cherry-pick --no-commit TARGET_1
git commit -m "New message 1"          # renamed
git cherry-pick --no-commit TARGET_2
git commit -m "Original message 2"     # kept as-is
git cherry-pick --no-commit TARGET_3
git commit -m "New message 3"          # renamed
# ... continue for ALL remaining commits
git push --force-with-lease origin main
```

**Verify count matches before pushing:**
```bash
git log --oneline | wc -l
# Must equal the original commit count
```

## ⚠️ Critical: Cherry-picking many commits with same files causes cascading conflicts

When cherry-picking dozens of commits that modify the same files (e.g., all adding files under `skills/software-development/`), you WILL get repeated `CONFLICT (add/add)` errors on every file that was created by a previous cherry-pick.

**Pattern that causes this:**
- Commit A creates `skills/software-development/foo/SKILL.md`
- Commit B creates `skills/software-development/foo/references/bar.md`
- When cherry-picking B, `foo/` already exists from A's cherry-pick → conflict

**Resolution pattern:**
```bash
git cherry-pick --no-commit SOURCE_SHA
# If conflict on files that already exist from previous cherry-picks:
git checkout --theirs path/to/conflicted/file   # accept the new version
git add .
git commit -m "Your message"
```

**If conflicts are widespread**, resolve ALL files at once:
```bash
git checkout --theirs .    # accept theirs for all conflicts
git add -A
git commit -m "Your message"
```

This can happen 10-20+ times when cherry-picking an entire branch. Budget time accordingly.

## ⚠️ Critical: Verify commit count BEFORE force push

After cherry-picking, ALWAYS verify the commit count matches the original before force pushing. If counts don't match, you lost commits and must NOT push.

```bash
ORIGINAL=$(git log --oneline backup-main | wc -l)
CURRENT=$(git log --oneline | wc -l)
if [ "$ORIGINAL" -ne "$CURRENT" ]; then
    echo "ERROR: Commit count mismatch ($ORIGINAL vs $CURRENT)"
    echo "DO NOT PUSH — you lost commits!"
fi
```

## ⚠️ Anchor sed/gsub patterns when old string is a prefix of new string

When renaming `tome` → `tomekdot`, a naive `s/tome/tomekdot/g` will match inside `tomekdot` itself after the first replacement. Always anchor:

```bash
# Wrong — matches inside already-replaced text
sed 's/tome/tomekdot/g'

# Right — anchored to whole field
sed 's/^author: tome$/author: tomekdot/'
```

## ⚠️ git filter-branch is unreliable on Windows/MSYS

`git filter-branch` frequently times out on Windows/MSYS, especially with `--msg-filter` that spawns subshells. It can also produce corrupted history (all commits getting the same message).

**Do NOT use `git filter-branch` on Windows.** Use cherry-pick method (Method 2) instead.

If you must use filter-branch:
- Use `--force` flag (required after first run)
- Set `FILTER_BRANCH_SQUELCH_WARNING=1`
- Remove `.git/refs/original/` between attempts
- Expect timeouts on repos with >10 commits

## ⚠️ git rebase -i --exec with commit --amend doesn't work

`git rebase -i --exec "git commit --amend -m ..."` fails because `$()` expansion doesn't work in the exec context. The shell evaluates `$()` before git passes it to exec.

**Don't use `--exec` for amending messages.** Use cherry-pick method instead.

## ⚠️ GIT_SEQUENCE_EDITOR with sed may not work on MSYS

`GIT_SEQUENCE_EDITOR="sed -i 's/^pick/reword/'" git rebase -i HEAD~N` may silently fail on MSYS because `sed -i` has different behavior on Windows. The rebase proceeds without applying the sed transformation.

**Don't rely on GIT_SEQUENCE_EDITOR for non-interactive rebase on Windows.** Use cherry-pick method instead.

## ⚠️ Cherry-pick conflicts on files that already exist

When cherry-pick creates files that already exist in the working tree (from previous cherry-picks), you get `CONFLICT (add/add)`. Resolve with:

```bash
git cherry-pick --no-commit SOURCE_SHA
# If conflict:
git checkout --theirs path/to/conflicted/file
git add path/to/conflicted/file
git commit -m "Your message"
```

## ⚠️ Force push after cherry-pick rewrites ALL commits

After cherry-picking from a reset point, every commit gets a new SHA — even the ones you didn't rename. This is a full history rewrite. Only do this on personal repos with no collaborators.

## Performance note

For repos with many commits (>20), cherry-pick all of them one by one is slow but reliable on Windows/MSYS (no PTY needed). Expect ~1-2 seconds per commit.
