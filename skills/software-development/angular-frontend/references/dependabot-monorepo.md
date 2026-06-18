# Dependabot Alerts in Monorepos

## Alerts Span Multiple Sub-Projects

In a monorepo like `KUL-2023-API`, Dependabot scans ALL `package-lock.json` files. Alerts may come from different sub-projects:

| Alert Location | Project | Action Needed |
|---|---|---|
| `src/labs/lab10/my-frontend/package-lock.json` | Angular frontend | Fix in `my-frontend/` |
| `src/library/nodejs-server-generated/nodejs-server/package-lock.json` | Node.js backend | Fix separately or ignore |
| `package.json` (root) | Root project | Fix at root level |

**How to identify**: Check the `• Detected in <path>` suffix in the Dependabot alert. The path tells you which sub-project owns the vulnerable dependency.

## Dev Dependencies vs Production Dependencies

Most Dependabot alerts in Angular projects come from **dev dependencies** (`@angular-devkit/build-angular`, `esbuild`, `picomatch`, `tar`). These:
- Are NOT shipped to production (Docker multi-stage build excludes them)
- Only exist on the developer's machine and CI
- Can be safely ignored for school/lab projects

## Reducing Alerts

1. **Update Angular to latest LTS** — biggest impact (46 → 4 vulnerabilities)
2. **`npm audit fix --force`** — updates transitive dependencies (risky, may break)
3. **Sub-project alerts** — require separate `npm audit` in each sub-project directory

## When to Ignore

- Alerts in `devDependencies` for school/lab projects
- Alerts in other sub-projects that you're not actively working on
- Alerts where the vulnerable code path is not used by your application
