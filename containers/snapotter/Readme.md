# SnapOtter (Docker)

Runs SnapOtter with its own PostgreSQL and Redis. All three services run in
Docker; all data lives on the host under `~/Projects/Containers/SnapOtter/`.

| Service  | Access                      | Port |
|----------|-----------------------------|------|
| SnapOtter| `http://localhost:1349`     | 1349 |
| Postgres | internal only (container network) | 5432 |
| Redis    | internal only (container network) | 6379 |

## Prerequisites

- Docker Engine 20.10+ with Compose v2

## Quick start

```bash
# 1. Create data directories
mkdir -p ~/Projects/Containers/SnapOtter/{data,workspace,pgdata,redisdata}

# 2. Create .env with a generated password
echo "POSTGRES_PASSWORD=$(openssl rand -hex 24)" > .env

# 3. Start
docker compose up -d

# 4. Open http://localhost:1349
```

Add `.env` to `.gitignore` — it contains your DB password.

## Data layout (host ↔ container)

| Host path                                    | Container path                     | Contents            |
|----------------------------------------------|------------------------------------|---------------------|
| `~/Projects/Containers/SnapOtter/data`       | `/data`                            | app data/uploads    |
| `~/Projects/Containers/SnapOtter/workspace`  | `/tmp/workspace`                   | temp workspace      |
| `~/Projects/Containers/SnapOtter/pgdata`     | `/var/lib/postgresql/data`         | PostgreSQL database |
| `~/Projects/Containers/SnapOtter/redisdata`  | `/data`                            | Redis AOF persistence |

Backups: `tar -czf snapotter-backup.tar.gz ~/Projects/Containers/SnapOtter`
(stop the stack first for a consistent snapshot, or use `pg_dump` for Postgres).

## .env

```env
# Required — used for both Postgres and the app's DATABASE_URL
POSTGRES_PASSWORD=generate_with_openssl_rand_hex_24

# Optional overrides (defaults shown)
# POSTGRES_USER=snapotter
# POSTGRES_DB=snapotter
# REDIS_URL=redis://redis:6379
```

> ⚠️ **Changing the password later:** Postgres only sets the password on first
> initialization. Changing `POSTGRES_PASSWORD` in `.env` on existing data will
> *not* update it — the app will fail to connect. Either keep the password, or
> stop the stack, delete the `pgdata` folder, and restart (⚠️ wipes the DB).

## How it works

- `depends_on` with `condition: service_healthy` means SnapOtter only starts
  after Postgres and Redis actually answer healthchecks — no startup race.
- `DATABASE_URL` is built from `POSTGRES_USER` / `POSTGRES_PASSWORD` /
  `POSTGRES_DB`, so the password lives in exactly one place.
- Redis runs with `appendonly yes` (persistence) and `noeviction` (keeps all
  keys — safe for queue/cache use).
- Logs are capped at 10 MB × 3 files per container.

## docker-compose.yml

```yaml
services:
  snapotter:
    image: snapotter/snapotter:latest
    container_name: snapotter
    restart: unless-stopped
    environment:
      # Built from the POSTGRES_* vars so the password lives in one place
      DATABASE_URL: postgres://${POSTGRES_USER:-snapotter}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-snapotter}
      REDIS_URL: ${REDIS_URL:-redis://redis:6379}
    ports:
      - "1349:1349"
    volumes:
      - ${HOME}/Projects/Containers/SnapOtter/data:/data
      - ${HOME}/Projects/Containers/SnapOtter/workspace:/tmp/workspace
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-snapotter}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?set POSTGRES_PASSWORD in .env}
      POSTGRES_DB: ${POSTGRES_DB:-snapotter}
    volumes:
      - ${HOME}/Projects/Containers/SnapOtter/pgdata:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-snapotter} -d ${POSTGRES_DB:-snapotter}"]
      interval: 10s
      timeout: 5s
      retries: 12

  redis:
    image: redis:8-alpine
    command: ["redis-server", "--maxmemory-policy", "noeviction", "--appendonly", "yes"]
    volumes:
      - ${HOME}/Projects/Containers/SnapOtter/redisdata:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 12
```

## Troubleshooting

- **Status:** `docker compose ps` — all three should show `healthy`/`running`
- **Logs:** `docker compose logs -f snapotter`
- **App can't reach DB:** usually a password mismatch — see the warning above
- **Port 1349 busy:** change the left side, e.g. `"1350:1349"`
- **Linux + `sudo docker compose`:** `${HOME}` resolves to root's home — use
  absolute paths in the volumes instead
- **Smaller images:** `postgres:17-alpine` and `redis:8-alpine` are already
  the smallest official variants; pin `snapotter/snapotter` to a version tag
  (e.g. `:1.2.3`) instead of `:latest` for reproducible deploys
