---
name: angular-frontend
description: Angular frontend development — project structure, routing, modules, component lifecycle, common pitfalls, and debugging. Use when building, fixing, or reviewing Angular applications (v14+).
---

# Angular Frontend Development

## Project Structure

Standard Angular CLI layout:
```
src/
  app/
    app.module.ts          # Root module — declare ALL components here or import their modules
    app-routing.module.ts  # Root routing — define ALL top-level routes here
    app.component.ts       # Root component
    feature/
      feature.component.ts
      feature.component.html
      feature.component.css
  gallery/
    gallery.module.ts      # Feature module
    gallery.component.ts
```

**Rule**: Components must live under `src/app/` (or a subdirectory) to be declared in `AppModule`. Components outside `src/app/` cannot be added to `AppModule` declarations.

## Routing

### Root vs Feature Module Routes

**Root routing** (`AppRoutingModule`) — define ALL top-level routes here:
```typescript
const routes: Routes = [
  { path: '', redirectTo: '/users', pathMatch: 'full' },
  { path: 'users', component: UsersComponent },
  { path: 'comments', component: CommentsComponent },
  { path: 'gallery', component: GalleryComponent },
  { path: '**', redirectTo: '/users' }
];
```

**Feature module routing** — `RouterModule.forChild([...])` in a feature module ONLY works if the module is lazy-loaded via `loadChildren`. If the feature module is eagerly imported in `AppModule`, routes defined in `forChild` are **silently ignored**.

**Fix**: Either:
1. Move all routes to `AppRoutingModule` (simpler, recommended for small apps)
2. Use lazy loading: `{ path: 'gallery', loadChildren: () => import('./gallery/gallery.module').then(m => m.GalleryModule) }`

### Common Routing Pitfalls

- **Wildcard `**` route must be LAST** — order matters
- **`pathMatch: 'full'`** required on empty-path redirects, otherwise all routes match
- **Component not in declarations** — if a route points to a component not declared in any module, you get a runtime error (not a build error)

## Modules

### Declarations

Every component, directive, and pipe must be declared in exactly ONE module:
```typescript
@NgModule({
  declarations: [
    AppComponent,
    UsersComponent,
    CommentsComponent  // Must be here if used in AppModule routes
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    MatListModule,     // Material modules used in templates
    MatToolbarModule,
    MatButtonModule
  ]
})
```

### Import Order

When a component uses Material components in its template (e.g., `<mat-list>`, `<mat-toolbar>`), the corresponding `MatListModule`, `MatToolbarModule` etc. MUST be imported in the SAME module where the component is declared.

## Components

### Angular 18+ Defaults to Standalone Components

**Angular 18+ generates standalone components by default.** If you're using NgModule pattern (non-standalone), you MUST add `standalone: false` to every component:

```typescript
@Component({
  selector: 'app-users',
  templateUrl: './users.component.html',
  styleUrls: ['./users.component.css'],
  standalone: false    // ← REQUIRED when using NgModule declarations
})
export class UsersComponent {}
```

Without `standalone: false`, you get `NG6008: Component is standalone, and cannot be declared in an NgModule`.

### Creating a Component

```bash
ng generate component feature-name
```

This creates `feature-name.component.ts`, `.html`, `.css`, `.spec.ts` and adds it to the nearest module.

### Component Outside `src/app/`

If a component lives outside `src/app/` (e.g., `src/comments/`), it CANNOT be added to `AppModule`. Options:
1. Move it under `src/app/` (recommended)
2. Create a separate module for it and import that module

## Services

### Injectable Service

```typescript
@Injectable({
  providedIn: 'root'  // Singleton, available everywhere
})
export class RestService {
  constructor(private httpClient: HttpClient) {}
}
```

### HTTP Client

Always import `HttpClientModule` in the root module (once):
```typescript
imports: [HttpClientModule]
```

### Mock API Endpoints

**reqres.in** now requires `x-api-key` header (returns 401 without it). Use **JSONPlaceholder** instead for free, no-auth mock data:
- `https://jsonplaceholder.typicode.com/users` — 10 users
- `https://jsonplaceholder.typicode.com/comments` — 500 comments
- `https://jsonplaceholder.typicode.com/posts` — 100 posts

## TypeScript Configuration

### moduleResolution for Angular 19+

Angular 19 with TypeScript 5.7 requires `moduleResolution: "bundler"` in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "moduleResolution": "bundler",
    "module": "ES2022",
    "target": "ES2022"
  }
}
```

Using the old `"moduleResolution": "node"` causes `TS2792: Cannot find module '@angular/core'`.

## Common Build Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `NG6001: class is listed in declarations but is not a directive, component, or pipe` | Component file has wrong path or missing `@Component` decorator | Check import path, ensure `@Component` decorator is present |
| `NG6008: Component is standalone, and cannot be declared in an NgModule` | Angular 18+ defaults to standalone; missing `standalone: false` | Add `standalone: false` to `@Component` decorator |
| `TS2307: Cannot find module '@angular/core'` | Wrong `moduleResolution` in tsconfig | Set `moduleResolution: "bundler"` for TS 5.7+ |
| `TS2307: Cannot find module` | Wrong relative import path | From `src/app/comments/` to `src/app/rest/` use `../rest/rest.service` |
| `NG2003: No suitable injection token` | Service class not properly exported or `providedIn` missing | Add `@Injectable({ providedIn: 'root' })` |
| `error NG5002: Unexpected closing tag` | Duplicate closing tag in HTML template | Remove duplicate `</tag>` |
| `TS2307: Cannot find module 'rxjs'` | `rxjs` not installed after `node_modules` wipe | Run `npm install rxjs@7.8.1` explicitly |

## Template Pitfalls

- **`mat-list-item` with multiple lines**: Use `matLine` directive on each line:
  ```html
  <mat-list-item *ngFor="let user of users">
    <h3 matLine>{{ user.name }}</h3>
    <p matLine>{{ user.email }}</p>
  </mat-list-item>
  ```
  Without `matLine`, only the first child is visible.

- **`mat-list-item` height**: Default height clips multi-line content. Add CSS:
  ```css
  mat-list-item { height: auto !important; }
  ```

- **Accessibility tree vs visual rendering**: `browser_snapshot` compact view may only show headings (h3) even when paragraphs (p) are present. Always use `full=true` to see all DOM content. The content IS there even if compact snapshot doesn't show it.

## Build & Serve

```bash
ng build                    # Production build
ng build --configuration development  # Development build
ng serve                    # Dev server on http://localhost:4200
ng serve --host 0.0.0.0    # Accessible from other machines
```

## Angular Version Upgrades

### Updating Angular CLI & Core

Use the official update command:
```bash
npx @angular/cli@<version> update @angular/core@<version> @angular/cli@<version> @angular/material@<version>
```

**⚠️ Don't jump more than 2-3 major versions at once.** Going from 16 → 22 in one step breaks: standalone components (default in 18+), TypeScript 6 requirement, `moduleResolution` changes, build system (`@angular/build` replaces `@angular-devkit/build-angular`). Safe path: 16 → 17 → 19 LTS.

### After Updating package.json

1. Delete `node_modules` and `package-lock.json`:
   - **Windows**: Must do this manually in PowerShell/CMD — the terminal tool gets blocked by EPERM:
     ```powershell
     Remove-Item -Recurse -Force node_modules
     Remove-Item -Force package-lock.json
     ```
2. Run `npm install`
3. If `rxjs` is missing: `npm install rxjs@7.8.1`
4. Add `standalone: false` to all `@Component` decorators (Angular 18+)
5. Update `tsconfig.json` — set `moduleResolution: "bundler"` for TS 5.7+
6. Run `ng build --configuration development` to verify

### Version Compatibility

| Angular | Node (min) | TypeScript | zone.js | Standalone default |
|---------|-----------|------------|---------|-------------------|
| 16 | 16 | ~5.1 | ~0.13 | No |
| 17 | 18 | ~5.2-5.4 | ~0.14 | No |
| 18 | 18 | ~5.4-5.5 | ~0.14 | Yes |
| 19 LTS | 18 | ~5.5-5.7 | ~0.15 | Yes |
| 22 | 18 | ~5.8-6.0 | ~0.15 | Yes |

**Key breaking changes per version:**
- **17**: New control flow syntax (`@if`/`@for`), but `*ngIf`/`*ngFor` still work
- **18**: Standalone components default; `NgModule` still fully supported with `standalone: false`
- **19**: TypeScript 5.7 requires `moduleResolution: "bundler"`; some Material APIs change
- **22**: New build system (`@angular/build`); TypeScript 6.x required; webpack builder deprecated

### Reducing Dependabot Alerts

Dependabot alerts in Angular projects often come from **dev dependencies** (build tools like `@angular-devkit/build-angular`, `esbuild`, `picomatch`, `tar`). These are NOT shipped to production. To reduce alerts:
1. Update Angular to latest LTS version
2. Run `npm audit` to check remaining vulnerabilities
3. Remaining alerts are typically in dev dependencies only — acceptable for school/lab projects
4. Across-repo alerts (e.g., `src/library/nodejs-server-generated/`) are in different sub-projects — check `package-lock.json` path in the alert to identify source

For monorepo Dependabot patterns, see [references/dependabot-monorepo.md](references/dependabot-monorepo.md).

## Docker Setup

For production deployment, see [references/docker-setup.md](references/docker-setup.md) covering:
- Multi-stage Dockerfile (Node 22 → nginx Alpine)
- nginx.conf for SPA routing
- docker-compose.yml
- Common issues (Docker Desktop, peer deps, 404s)

## Verification Checklist

After making changes:
1. `ng build --configuration development` — must pass with 0 errors
2. `ng serve` — wait for "Compiled successfully"
3. Check each route in browser
4. Check browser console for runtime errors
5. Verify API calls return 200 (not 401/403)
