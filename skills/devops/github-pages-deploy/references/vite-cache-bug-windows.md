# Vite Cache Bug on Windows/git-bash — Investigation Notes

## Symptoms
- `npm run build` produces identical bundle hash despite source changes
- Affects `.tsx`, `.ts`, `.css` files
- Vite 6.x on MSYS2/git-bash (Windows 10)

## What Was Tried (All Failed)
1. `rm -rf dist && npm run build` — same hash
2. `touch src/App.tsx && npm run build` — same hash
3. Rename file + update import — same hash
4. Complete file rewrite — same hash
5. `rm -rf node_modules && npm install` — same hash
6. Adding unique comment to top of App.tsx — same hash
7. Creating new file with different content + importing — same hash

## What Worked
- **Downgrade to Vite 5.x:** `npm install vite@5` — hash changes correctly
- **Inline JSX:** Moving component code directly into App.tsx forces re-bundle
- **Build on different environment:** AI Studio, Linux, GitHub Actions

## Root Cause
Vite 6.x content hashing on MSYS2/git-bash doesn't properly detect file changes in child components. The entry point file (App.tsx) IS re-bundled, but imported components are not.

## Affected Versions
- Vite 6.2.3, 6.4.3 on Windows 10 with git-bash
- Vite 5.4.21 works correctly
