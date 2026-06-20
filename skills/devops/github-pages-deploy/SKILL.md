---
name: github-pages-deploy
description: "Build and deploy React/Vite projects to GitHub Pages — Windows git-bash quirks, Vite cache bugs, favicon setup, and CI/CD via GitHub Actions."
version: 1.5.0
author: OWL
license: MIT
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [github-pages, deploy, vite, react, windows, git-bash, favicon, ci-cd]
---

# GitHub Pages Deploy

Build and deploy static sites (React/Vite, Angular, plain HTML) to GitHub Pages.

## ⚠️ CRITICAL: When Updating from External Sources

When copying updated source files from an external folder (e.g. AI Studio downloads):

1. **ONLY copy source files** — `src/`, `package.json`, `vite.config.ts`, `tsconfig.json`
2. **NEVER copy `index.html`** — it contains favicon, title, and custom settings that the external source won't have
3. **NEVER copy `assets/` folder** — it contains logo.webp and built bundles
4. **After copying, always verify `index.html` has:**
   - Correct `<title>` (not "My Google AI Studio App")
   - Favicon: `<link rel="icon" type="image/webp" href="/assets/logo.webp" />`
   - Apple touch icon: `<link rel="apple-touch-icon" href="/assets/logo.webp" />`
5. **After copying, always verify `assets/` still has:**
   - `logo.webp` — the site logo/favicon (DO NOT overwrite)
   - Built JS/CSS bundles (copied from `dist/assets/` after build)

### ⚠️ Pitfall: index.html Entry Point

`index.html` must use Vite's standard entry point format:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>tomekdot — GitHub Portfolio</title>
    <link rel="icon" type="image/webp" href="/assets/logo.webp" />
    <link rel="apple-touch-icon" href="/assets/logo.webp" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

**Do NOT use hardcoded asset paths** like `/assets/index-XXXXX.js` — these are from AI Studio builds and break Vite's module resolution. Always use `<script type="module" src="/src/main.tsx">`.

### ⚠️ Pitfall: JSDoc Headers Breaking esbuild

AI Studio and other tools may inject JSDoc comment blocks at the top of `.tsx` files:

```tsx
/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 * BUILD: 2026-06-18-1700
 * CLEAN_REBUILD */
 */
```

esbuild's TSX parser can misparse `/** ... */` blocks at the very top of the entry `.tsx` file (before imports), causing `Unexpected "*"` errors.

**Fix:** Remove the JSDoc comment block from the top of the file. Move license metadata to a separate `LICENSE` file or inline as a single-line comment.

**Check after copying:** Always inspect the top of `src/App.tsx` / `src/main.tsx` after copying from external sources.

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

# 3. Commit and push
git add -A
git commit -m "Deploy to GitHub Pages"
git push origin main
```

## Project Structure

```
tomekdot.github.io/
├── index.html          # Entry point — Vite generates this in dist/
├── assets/             # Static assets (logo.webp, etc.) — NOT built JS/CSS
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

Or use a local logo file: `<link rel="icon" type="image/webp" href="/assets/logo.webp" />`

## Windows/git-bash Quirks

### Vite Cache Bug (CRITICAL)

**Symptom:** Vite 6.x produces the same bundle hash despite file changes. `npm run build` always outputs the same `index-XXXXX.js`.

**Root cause:** Content hashing bug in Vite 6.x on MSYS2/git-bash — doesn't detect file changes properly. Affects `.tsx`, `.ts`, `.css` files. Neither `rm -rf dist`, `touch`, renaming files, complete rewrites, nor `rm -rf node_modules && npm install` fix it.

**Workarounds (try in order):**
1. **Add a unique comment to the entry point** — add `/* BUILD: 2026-06-18-1600 */` at the top of `src/App.tsx`. Vite always re-bundles the entry point file correctly.
2. **Switch Vite versions** — downgrade to Vite 5.x (`npm install vite@5`).
3. **Move JSX inline** — Vite always re-bundles the entry point file correctly.
4. **Use a non-Windows build environment** — build on Linux/Mac/GitHub Actions.

**Verification:** After `npm run build`, check `ls dist/assets/index-*.js` — hash should differ from previous build.

### `cp -r dist/* .` Fails Silently

On git-bash, `cp -r dist/* .` may not copy all files. Always copy individually:
```bash
cp dist/index.html .
cp dist/assets/*.js assets/
cp dist/assets/*.css assets/
```

### `ls` and `find` Hang

Some commands hang on git-bash with certain directories (node_modules, .git). Use `read_file` tool or `node -e "require('fs').readdirSync(...)"` instead.

### Path Conventions

- **In terminal (git-bash):** `/c/Users/USERNAME/...` or `C:\Users\USERNAME\...`
- **In write_file tool:** Always use `C:\Users\USERNAME\...` (native Windows paths)
- **In read_file tool:** Either format works

### Git Repository Lost (.git deleted)

If `.git` folder is accidentally deleted (e.g. by AI Studio):

```bash
git init
git remote add origin https://github.com/USER/REPO.git
git add -A
git commit -m "Reinit after .git loss"
git branch -m master main  # if branch is master instead of main
git push origin main --force
```

Note: Force push rewrites history, but this is the correct approach when `.git` was deleted but local files are intact.

## Vite `base` Config for GitHub Pages

For user/organization sites (`USERNAME.github.io`), Vite's `base` must be `'/'`:

```typescript
// vite.config.ts
export default defineConfig({
  base: '/',
  plugins: [react()],
})
```

Without this, Vite prepends a base path to all asset URLs, causing 404s on GitHub Pages.

## GitHub Actions CI/CD

Create `.github/workflows/deploy.yml` with Node.js 24 actions:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: 'pages'
  cancel-in-progress: true

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Set up Node
        uses: actions/setup-node@v5
        with:
          node-version: 24
          cache: 'npm'

      - name: Install dependencies
        run: npm ci || npm install

      - name: Build
        run: npm run build

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v6
        with:
          path: './dist'

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v6
```

**Note:** Change Pages source to "GitHub Actions" in repo settings (Settings → Pages → Build and deployment → Source).

## Troubleshooting

### Build fails with `Unexpected "*"` on a `.tsx` file
- A JSDoc comment block (`/** ... */`) at the top of the entry `.tsx` file breaks esbuild's TSX parser
- Fix: remove the JSDoc block

### Page loads but assets (CSS/JS) return 404
- Check `vite.config.ts` has `base: '/'` — without it, Vite prepends wrong paths for GitHub Pages user sites

### Page shows old content after deploy
- GitHub Pages takes 1-2 minutes to update
- User must hard refresh: **Ctrl+Shift+R**

### Page is blank (white screen)
- Check browser console for 404 errors on JS/CSS files
- Verify `assets/` folder has the correct hashed files

### Vite build produces same hash on Windows
- See "Vite Cache Bug" section above — downgrade to Vite 5.x

### Favicon not showing
- Clear browser cache (Ctrl+Shift+R)
- Verify `<link rel="icon">` is in `<head>`

### Private repos not hiding on portfolio
- Check `isPrivate: true` is set in `src/data.ts` for each private repo
- Badge condition must be `repo.isPrivate` only — NOT `(repo.isPrivate || !repo.pushedAt)`
