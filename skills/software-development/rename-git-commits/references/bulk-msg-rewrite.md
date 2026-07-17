# Bulk commit-message rewrite (filter-branch --msg-filter)

## When to use
Repo-wide message normalization that touches many commits and can't be done
with `--amend` / cherry-pick without rewriting the whole chain anyway.
Typical ask: "zrób Feature: z feat:, UI: z ui:, duża litera po dwukropku".

## Full recipe (clean -> rewrite -> push)

```bash
cd /c/Users/tomekdot/Documents/VSCode/awaredotloc
git branch "backup-msg-$(date +%Y%m%d%H%M)"         # 0. backup (keep until verified)
git stash push -u -m "wip-before-msg-rewrite"        # 1. REQUIRED: clean tree
export FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch -f --msg-filter '
  sed -E "
    s/^fix:/Fix:/;  s/^docs:/Docs:/;  s/^chore:/Chore:/;  s/^brand:/Brand:/;
    s/^ui:/UI:/;    s/^feat:/Feature:/;  s/^deploy:/Feature:/;
    s/^(Fix: )([a-z])/\1\u\2/;   s/^(Docs: )([a-z])/\1\u\2/;
    s/^(Chore: )([a-z])/\1\u\2/; s/^(Brand: )([a-z])/\1\u\2/;
    s/^(UI: )([a-z])/\1\u\2/;    s/^(Feature: )([a-z])/\1\u\2/;
    s/^(SCAN-04: )([a-z])/\1\u\2/
  "
' -- --all
git stash pop                                       # restore WIP
git fetch origin                                    # REQUIRED before lease (see trap)
git push --force-with-lease origin main             # history rewritten
```

## Pitfalls (all hit in the 2026-07 awaredotloc session)

### P1 -- --msg-filter with -- --all rewrites EVERYTHING
It walks all refs (including refs/remotes/origin/main) and rewrites all
branch hashes. That's why --force-with-lease is mandatory on push.

### P2 -- force-with-lease "stale info" on first attempt
filter-branch rewrites the local origin/main ref too, so the lease compares
against a now-stale local copy and rejects with `! [rejected] (stale info)`.
Fix: `git fetch origin` BEFORE the push so the lease references the real
remote tip. (Do NOT just fall back to --force without thinking.)

### P3 -- foreground timeout on large repos (131 commits)
`git filter-branch` over ~131 commits runs >60s and the terminal call times out,
leaving the repo mid-rewrite. Fix: run it as `terminal(background=true,
notify_on_complete=true)` and `process(wait)`. Then verify with `git log`
before pushing. If it aborted mid-way, clean up (`rm -f .git/filter-branch.lock`,
`git for-each-ref refs/original/`) and re-run.

### P4 -- clean tree is required
filter-branch refuses with "Cannot rewrite branches: You have unstaged
changes." Fix: `git stash push -u` first (include untracked with -u),
then `git stash pop` after.

### P5 -- do NOT change dates when only the author is wanted
In this session the first attempt rewrote 2025 dates to 2026-07-17 + author
`tomekdot`. The user actually wanted the **2025 dates preserved** and only the
**author/committer swapped** to `tomekdot`. Recovery:
```bash
git reset --hard refs/original/refs/heads/main   # recover pre-rewrite state
# then run filter-branch with --env-filter that ONLY sets name/email:
export FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch -f --env-filter '
  export GIT_AUTHOR_NAME="tomekdot"
  export GIT_AUTHOR_EMAIL="tomaszkaczak@protonmail.com"
  export GIT_COMMITTER_NAME="tomekdot"
  export GIT_COMMITTER_EMAIL="tomaszkaczak@protonmail.com"
' -- --all
```
The original objects survive in refs/original/ until you filter-branch again or
expire them -- so you can always recover the true 2025 dates.

### P6 -- MSYS GNU sed \u works
`sed -E 's/^(Fix: )([a-z])/\1\u\2/'` capitalizes the first letter of the
description on MSYS git-bash. Confirmed working; don't avoid it.

### P7 -- leave Revert "..." untouched
The quoted text inside a Revert "..." message is a literal reference to the
reverted commit. Don't capitalize inside the quotes.

## Verification after rewrite
```bash
git log --pretty=format:'%s' | grep -E '^(Fix|Feature|UI|Docs|Chore|Brand):'   # check form
git log origin/main --reverse --pretty=format:'%h | %ad | %an | %s' --date=short | head   # dates intact?
git rev-list --left-right --count origin/main...HEAD   # must be 0 0 after push
```
