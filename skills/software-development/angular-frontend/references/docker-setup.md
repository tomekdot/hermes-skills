# Docker Setup for Angular Projects

## Dockerfile — Multi-Stage Build

```dockerfile
# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps

COPY . .
RUN npm run build -- --configuration production

# Stage 2: Serve with nginx
FROM nginx:alpine
COPY --from=build /app/dist/my-frontend /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Why multi-stage**: Node image ~1GB, nginx Alpine ~50MB. Build tools don't go to production.

## nginx.conf — SPA Serving

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_min_length 256;

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

**Key**: `try_files` fallback to `index.html` — required for Angular SPA routing (deep links like `/users` would 404 otherwise).

## docker-compose.yml

```yaml
services:
  frontend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "4200:80"
    restart: unless-stopped
```

**Port mapping**: Container exposes 80, mapped to host 4200 to match Angular dev server convention.

## .dockerignore

```
node_modules
dist
tmp
.git
.gitignore
*.md
LICENSE
docker-compose.yml
Dockerfile
.dockerignore
nginx.conf
.angular
coverage
src/**/*.spec.ts
```

**Why exclude Docker files from build context**: Prevents accidental overwrite of container's own config files.

## Build & Run

```bash
docker compose build          # Build image
docker compose up --build     # Build + run
docker compose up -d          # Run detached
docker compose down           # Stop
docker compose logs -f        # View logs
```

## Common Issues

### Docker Desktop Not Running (Windows)
**Symptom**: `error during connect: Head "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/_ping"`  
**Fix**: Start Docker Desktop from menu Start, or run `Start-Service docker` in admin PowerShell.

### npm ci Fails with Peer Dependency Conflicts
**Fix**: Use `npm ci --legacy-peer-deps`.

### Build Succeeds but Page Shows 404
**Check**: `try_files` directive in nginx.conf must point to `index.html`.
