---
name: my-frontend-starter
description: My Frontend — Angular 19 SPA starter with Material Design, Docker, and nginx. Use when working on the my-frontend project (KUL-2023-API/src/labs/lab10/my-frontend).
---

# My Frontend Starter

## Project Overview

Angular 19 LTS SPA with Angular Material, served via nginx in Docker.

**Location**: `src/labs/lab10/my-frontend/`

## Quick Start

```bash
cd src/labs/lab10/my-frontend

# Docker (recommended)
docker compose up --build
# → http://localhost:4200

# Without Docker
npm install
npm start
# → http://localhost:4200
```

## Project Structure

```
src/
├── app/
│   ├── app.component          # Root: toolbar + router-outlet
│   ├── app.module.ts          # Root NgModule (all components declared here)
│   ├── app-routing.module.ts  # All routes defined here
│   ├── users/                 # /users — user list from API
│   ├── comments/              # /comments — comments from API
│   ├── rest/                  # /rest — API demo page
│   └── rest.service.ts        # HTTP service (providedIn: 'root')
├── gallery/
│   ├── gallery.module.ts      # Feature module
│   └── gallery.component      # /gallery — image gallery
└── main.ts                    # Bootstrap
```

## Routes

| Path | Component | Data Source |
|------|-----------|-------------|
| `/users` | UsersComponent | JSONPlaceholder `/users` |
| `/comments` | CommentsComponent | JSONPlaceholder `/comments` |
| `/gallery` | GalleryComponent | picsum.photos |
| `/rest` | RestComponent | Static placeholder |

## Key Conventions

- **All components use `standalone: false`** (NgModule pattern)
- **All routes in `AppRoutingModule`** (no `forChild` in feature modules)
- **All Material modules imported in `AppModule`**
- **Typed API responses** — `User[]`, `Comment[]`, no `any`
- **API base**: `https://jsonplaceholder.typicode.com`

## Docker

| Command | Description |
|---------|-------------|
| `docker compose up --build` | Build + run |
| `docker compose down` | Stop |
| `docker compose logs -f` | Logs |

Multi-stage: Node 22 (build) → nginx Alpine (~50MB).

## Common Issues

| Issue | Fix |
|-------|-----|
| `NG6008: Component is standalone` | Add `standalone: false` to `@Component` |
| `TS2792: Cannot find module '@angular/core'` | Set `moduleResolution: "bundler"` in tsconfig |
| `TS2307: Cannot find module 'rxjs'` | `npm install rxjs@7.8.1` |
| `NG2003: No suitable injection token` | Add `@Injectable({ providedIn: 'root' })` |
| Gallery route redirects to `/users` | Move route from `GalleryModule.forChild` to `AppRoutingModule` |
| Dependabot alerts for `tar`, `picomatch`, `tmp` | Dev dependencies only — not in Docker image |

## Updating Angular

Safe path: 16 → 17 → 19 LTS. Don't jump to 22 (requires TS 6.x, new build system).

After updating:
1. Delete `node_modules` + `package-lock.json`
2. `npm install`
3. Add `standalone: false` to all components
4. Set `moduleResolution: "bundler"` in tsconfig
5. `ng build --configuration development`

## Verification

1. `ng build --configuration development` — 0 errors
2. All 4 routes render correctly
3. API calls return 200
4. No browser console errors
