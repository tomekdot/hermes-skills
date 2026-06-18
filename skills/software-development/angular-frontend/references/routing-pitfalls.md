# Angular Routing Pitfalls — Session Notes

## forChild Routes Silently Ignored

**Symptom**: Route defined in `GalleryModule` via `RouterModule.forChild([{ path: 'gallery', component: GalleryComponent }])` doesn't work. Navigating to `/gallery` redirects to wildcard route.

**Cause**: `GalleryModule` is eagerly imported in `AppModule` via `imports: [GalleryModule]`. When a feature module is eagerly loaded, its `forChild` routes are registered but the root router doesn't know about the `/gallery` path because it's not in the root route config.

**Fix**: Move the route to `AppRoutingModule`:
```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: 'gallery', component: GalleryComponent },
  // ...
];
```

**Alternative**: Use lazy loading:
```typescript
{ path: 'gallery', loadChildren: () => import('./gallery/gallery.module').then(m => m.GalleryModule) }
```

## Component Outside src/app/ Cannot Be Declared

**Symptom**: `error NG6001: The class 'CommentsComponent' is listed in the declarations of the NgModule 'AppModule', but is not a directive, a component, or a pipe`

**Cause**: Component was in `src/comments/` (outside `src/app/`). Angular CLI module resolution only picks up components under the source root.

**Fix**: Move component to `src/app/comments/` and update import paths.

## reqres.in Returns 401

**Symptom**: API call to `https://reqres.in/api/users` returns 401 Unauthorized.

**Cause**: reqres.in now requires `x-api-key` header for all endpoints.

**Fix**: Use JSONPlaceholder instead:
- `https://jsonplaceholder.typicode.com/users` (10 users, no auth)
- `https://jsonplaceholder.typicode.com/comments` (500 comments, no auth)

## Duplicate Closing Tag

**Symptom**: `error NG5002: Unexpected closing tag "mat-list". It may happen when the tag has already been closed by another tag.`

**Cause**: Template had `</mat-list>` followed by another `</mat-list>` — leftover from refactoring.

**Fix**: Carefully check template structure. Each opening tag needs exactly one closing tag.
