# Rewrite commit DATES and/or AUTHOR with `git filter-branch`

Use this when you need to change the **author/committer name, email, or date**
of commits already in history (e.g. old commits show a different git identity,
or you want to backdate/redate a batch). This is the right tool when the set of
commits to change is defined by a *condition* (date range, author, message),
not a simple linear tail.

## Working recipe (Windows / MSYS, non-interactive)

```bash
# 0. Make a backup branch FIRST (cheap insurance against a botched rewrite)
git branch "backup-dates-$(date +%Y%m%d)"

# 1. CRITICAL: filter-branch refuses to run with a dirty tree.
#    Stash EVERYTHING including untracked files (-u) so the tree is clean.
git stash push -u -m "wip-before-date-rewrite"

# 2. Rewrite only commits matching the condition (here: authored in 2025).
#    Commits that do NOT match are left 100% untouched (hashes preserved).
export FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch -f --env-filter '
  ad=$(git log -1 --format=%ad --date=short "$GIT_COMMIT")
  case "$ad" in
    2025-*)
      export GIT_AUTHOR_NAME="tomekdot"
      export GIT_AUTHOR_EMAIL="tomaszkaczak@protonmail.com"
      export GIT_COMMITTER_NAME="tomekdot"
      export GIT_COMMITTER_EMAIL="tomaszkaczak@protonmail.com"
      export GIT_AUTHOR_DATE="2026-07-17T12:00:00 +0200"
      export GIT_COMMITTER_DATE="2026-07-17T12:00:00 +0200"
      ;;
  esac
' -- --all

# 3. Restore the stashed working-tree changes.
git stash pop

# 4. Push (history is rewritten -> force required).
#    See PITFALL below about --force-with-lease "stale info".
git push --force-with-lease origin main
```

### Condition variants
- By author: `case "$(git log -1 --format=%an "$GIT_COMMIT")" in "Tomasz Kaczak") ...`
- By committer date range: compare `$ad` against a prefix/year as above.
- To redate ALL commits to now: drop the `case` and always set the date.

## Pitfalls

### P1 — Dirty tree blocks the run
`filter-branch` aborts with `Cannot rewrite branches: You have unstaged
changes.` Stash with `-u` (include untracked) BEFORE, pop AFTER. Always.

### P2 — `--force-with-lease` fails with "stale info" after filter-branch
`filter-branch --all` also rewrites the local remote-tracking ref
`refs/remotes/origin/main` to the NEW hashes. `--force-with-lease` then
compares against that already-rewritten ref and rejects the push as "stale
info". Fix: refresh the real remote state first —
`git fetch origin` — THEN `git push --force-with-lease origin main`.
(Observed 2026-07-17; push then succeeds with `forced update`.)

### P3 — Changing any date at the root rewrites the ENTIRE history
Altering author/committer date (or name) changes that commit's hash, which
cascades to every descendant. The whole branch gets new SHAs. That is why
force-push is mandatory and why collaborators must re-clone / `git pull --rebase`.

### P4 — `--all` also touches other branches/tags
`-- --all` rewrites main, other local branches, AND remote-tracking refs. If
you only want `main`, pass `main` instead of `--all`, or delete the unwanted
rewritten refs afterward from `refs/original/`.

## Correction to older skill note
An earlier version of this skill claimed "git filter-branch is unreliable on
Windows (timeouts, corrupted history)". That is FALSE for this use case — the
recipe above ran cleanly on Windows/MSYS (git-bash) with no timeout or
corruption. The only real prerequisites are: clean tree (P1) and the
fetch-before-lease step (P2).
