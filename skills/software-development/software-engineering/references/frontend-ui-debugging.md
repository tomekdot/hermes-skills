# Frontend UI Debugging — React Patterns

## Toggle Button State Bug

### Symptom
A toggle button (e.g., "Show/Hide Private") changes text on click but the actual filtering doesn't work — or the wrong items are shown/hidden.

### Common Cause: Overly Broad Conditional in JSX

```jsx
// ❌ WRONG: Shows badge for ANY repo without pushedAt, not just private ones
{(repo.isPrivate || !repo.pushedAt) && (
  <span className="badge-private">Private</span>
)}

// ✅ CORRECT: Only shows badge for actually private repos
{repo.isPrivate && (
  <span className="badge-private">Private</span>
)}
```

**Rule:** When rendering status badges or labels, use the **exact boolean flag** (`isPrivate`), not compound conditions that conflate separate concerns (`!pushedAt` is about sync status, not visibility).

### Same Bug in Multiple Files

When a conditional rendering pattern is copied across components (e.g., `RepoCard.tsx`, `RepoModal.tsx`, `TerminalConsole.tsx`), the same bug appears in all of them. **Always search for all occurrences** of the pattern before declaring the fix complete:

```bash
grep -rn "isPrivate" src/components/
```

### Debugging Checklist for Toggle Buttons

1. **Check the filter logic** — Is the `useMemo`/`filter` using the same condition as the badge?
2. **Check the toggle state** — Is `setHidePrivate(!hidePrivate)` actually updating?
3. **Check the count** — Does the total repo count change when toggling?
4. **Check for stale closures** — Ensure the toggle state is in the `useMemo` dependency array.
5. **Check ALL components** — Badge in Card, Modal, Terminal may each have the same bug.

## Toggle Button Visual Feedback

Toggle buttons should have **distinct visual states**:

```jsx
// ✅ Good: Color-coded states
className={`toggle-btn ${hidePrivate
  ? 'border-rose-500/50 text-rose-400 bg-rose-500/10'
  : 'border-emerald-500/50 text-emerald-400 bg-emerald-500/10'}`}
```

**Rules:**
- Use **semantic colors**: red/rose for "hidden", green/emerald for "shown"
- Add a **tooltip** (`title` attribute) explaining what click will do
- Show a **count**: `Hidden (2)` / `Shown (2)`
- Use **distinct icons**: `EyeOff` for hidden, `Eye` for shown

## ⚠️ CRITICAL: Vite Cache Bug on Windows git-bash

**Symptom:** You change a `.tsx` component file, run `npm run build`, but the output bundle hash stays the same — your changes are NOT in the bundle.

**Cause:** Vite on Windows git-bash has a caching bug where it ignores changes to imported component files.

**Workarounds (try in order):**
1. **Inline the component** — Move JSX directly into the parent file
2. **Rename the file** — Change `RepoCard.tsx` to `Card.tsx` + update import
3. **Verify with grep** — After build: `grep -o 'pattern' dist/assets/index-*.js`

## GitHub Pages Deploy: Copy Built Assets

```bash
# ✅ Copy specific files explicitly
cp dist/index.html .
cp dist/assets/index-*.js assets/
```

**Always verify** the deployed JS contains your changes.

## Build on Windows git-bash

```bash
# ✅ Works reliably
npm run build
```

## Batch-Updating Data Files

Use `.cjs` extension for Node.js scripts (project has `"type": "module"`). Clean up temp scripts after use.
