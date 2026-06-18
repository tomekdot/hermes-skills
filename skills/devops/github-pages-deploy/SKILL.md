---
name: github-pages-deploy
description: "Build and deploy React/Vite projects to GitHub Pages — Windows git-bash quirks, Vite cache bugs, favicon setup, and CI/CD via GitHub Actions."
version: 1.1.0
author: OWL
license: MIT
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [github-pages, deploy, vite, react, windows, git-bash, favicon, ci-cd]
---

# GitHub Pages Deploy

Build and deploy static sites (React/Vite, Angular, plain HTML) to GitHub Pages.

## Quick Deploy (manual)

```bash
# 1. Build
cd /c/Users/tomekdot/Documents/VSCode/tomekdot.github.io
npm run build

# 2. Copy dist to root (GitHub Pages serves from root on main branch)
# IMPORTANT: cp -r dist/* . does NOT work reliably on Windows/git-bash
# Copy files individually:
cp dist/index.html .
cp dist/assets/*.js assets/
cp dist/assets/*.css assets/
# Copy files individually:
cp dist/index.html .
cp dist/assets/*.js assets/
cp dist/assets/*.css assets/

# 3. Commit and push
git add -A
git commit -m "Deploy to GitHub Pages"
git push origin main
```

## Project Structure

```
tomekdot.github.io/
├── index.html          # Entry point (copied from dist/)
├── assets/             # Built JS/CSS bundles (copied from dist/assets/)
│   ├── index-XXXXX.js  # Vite hashed bundle
│   └── index-XXXXX.css # Tailwind CSS
├── src/                # Source files (not served by GitHub Pages)
│   ├── App.tsx
│   ├── components/
│   └── data.ts
├── dist/               # Build output (rebuilt each time)
├── package.json
├── vite.config.ts
└── .github/workflows/  # CI/CD (optional)
```

## GitHub Pages Config

- **Source:** Branch `main`, path `/`
- **Settings → Pages → Source:** Deploy from a branch → `main` / `/`
- **Custom domain:** None (uses `USERNAME.github.io`)

## Favicon Setup

Add to `index.html` `<head>`:

```html
<link rel="icon" type="image/png" href="https://avatars.githubusercontent.com/USERNAME?s=64" />
<link rel="apple-touch-icon" href="https://avatars.githubusercontent.com/USERNAME?s=128" />
```

Use GitHub avatar URL: `https://avatars.githubusercontent.com/USERNAME?s=SIZE`

## Windows/git-bash Quirks

### Vite Cache Bug (CRITICAL)

**Symptom:** Vite 6.x produces the same bundle hash despite file changes. `npm run build` always outputs the same `index-XXXXX.js`.

**Root cause:** Content hashing bug in Vite 6.x on MSYS2/git-bash — doesn't detect file changes properly. Affects `.tsx`, `.ts`, `.css` files. Neither `rm -rf dist`, `touch`, renaming files, complete rewrites, nor `rm -rf node_modules && npm install` fix it.

**Fix:** Use Vite 5.x instead:
```bash
npm install vite@5
```

**Last-resort workaround (Vite 5.x still ignores changes):** If Vite still produces the same hash after downgrading, move the JSX from the child component directly into the parent file (inline rendering). Vite always re-bundles the entry point file (App.tsx / main.tsx) correctly. For example, instead of `<RepoCard repo={repo} />`, paste the full JSX inline in the `.map()` callback. Ugly but guaranteed to work.

**Workaround:** Build on a different environment (Linux/Mac/GitHub Actions/AI Studio) and copy `dist/` files to Windows for deployment.

**Verification:** After `npm run build`, check `ls dist/assets/index-*.js` — hash should differ from previous build after any source edit.

**Full investigation notes:** `references/vite-cache-bug-windows.md`

### `cp -r dist/* .` Fails Silently

On git-bash, `cp -r dist/* .` may not copy all files. Always copy individually:
```bash
cp dist/index.html .
cp dist/assets/*.js assets/
cp dist/assets/*.css assets/
```

### `ls` and `find` Hang

Some commands hang on git-bash with certain directories (node_modules, .git). Use `read_file` tool or `node -e "require('fs').readdirSync(...)"` instead.

### `rm -rf` Requires Approval

Destructive commands need user approval:
```bash
rm -rf dist node_modules
```

### Path Conventions

- **In terminal (git-bash):** `/c/Users/USERNAME/...` or `C:\Users\USERNAME\...`
- **In write_file tool:** Always use `C:\Users\USERNAME\...` (native Windows paths)
- **In read_file tool:** Either format works

### Line Endings

Git may warn `LF will be replaced by CRLF`. Cosmetic — `.gitattributes` normalizes.

## GitHub Actions CI/CD (optional)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run build
      - uses: actions-upload-pages-artifact@v3
        with:
          path: dist
      - uses: actions/deploy-pages@v4
```

**Note:** When using GitHub Actions, change Pages source to "GitHub Actions" in repo settings.

## Troubleshooting

### Page shows old content after deploy
- GitHub Pages takes 1-2 minutes to update
- User must hard refresh: **Ctrl+Shift+R**
- Check `index.html` references correct JS hash

### Page is blank (white screen)
- Check browser console for 404 errors on JS/CSS files
- Verify `assets/` folder has the correct hashed files
- Make sure `index.html` has correct `<script>` and `<link>` paths

### Vite build produces same hash on Windows
- See "Vite Cache Bug" section above — downgrade to Vite 5.x

### Favicon not showing
- Clear browser cache (Ctrl+Shift+R)
- Check URL is correct: `https://avatars.githubusercontent.com/USERNAME?s=64`
- Verify `<link rel="icon">` is in `<head>`

### Private repos not hiding on portfolio
- Check `isPrivate: true` is set in `src/data.ts` for each private repo
- Badge condition must be `repo.isPrivate` only — NOT `(repo.isPrivate || !repo.pushedAt)`
- The `|| !repo.pushedAt` condition incorrectly shows "Private" badge on ALL repos without a `pushedAt` field (i.e. all static snapshot repos), making the toggle button appear broken
- Toggle button filters by `hidePrivate` state variable working correctly when the badge condition is fixed
- After fixing the badge condition, rebuild and verify: public repos should NOT show "Private" badge
