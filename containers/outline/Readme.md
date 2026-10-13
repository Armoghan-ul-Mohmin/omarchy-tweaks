# Outline (Docker)

Self-hosted wiki / knowledge base (like Notion, but yours). Runs with its
own PostgreSQL and Redis. **Local-only** — no cloud storage, no external
services, no HTTPS portal.

| Item        | Value                                              |
|-------------|----------------------------------------------------|
| Service     | outline                                            |
| Image       | `docker.getoutline.com/outlinewiki/outline:latest` |
| Web UI      | `http://localhost:4199`                          |
| Data        | `~/Projects/Containers/Outline/`                   |
| Auth        | Google OAuth (required — see below)                |

## Prerequisites

- Docker Engine 20.10+ with Compose v2
- A **Google Cloud project** with an OAuth client (free) — Outline has no
  local password login, so this is mandatory

## Quick start

```bash
# 1. Create data directories
mkdir -p ~/Projects/Containers/Outline/{data,postgresql,redisdata}

# 2. Create .env (see below)

# 3. Start
docker compose up -d

# 4. Open http://localhost:4199 and sign in with Google
#    (the first account to sign in becomes the admin)
```

Add `.env` to `.gitignore` — it contains your secrets.

## .env

```env
# Generate each with: openssl rand -hex 32  (must be 32+ chars)
SECRET_KEY=paste_generated_value
UTILS_SECRET=paste_generated_value

# Postgres credentials for Outline's dedicated DB
POSTGRES_USER=outline
POSTGRES_PASSWORD=paste_generated_value
POSTGRES_DB=outline

# Must include the port since it's not 80/443
URL=http://localhost:4199

# Google OAuth — create at https://console.cloud.google.com
# Application type: Web application
# Authorized redirect URI: http://localhost:4199/auth/google.callback
GOOGLE_CLIENT_ID=paste_your_client_id
GOOGLE_CLIENT_SECRET=paste_your_client_secret
```

## Why do I need Google credentials?

Outline has **no built-in login system** — it delegates authentication to
an OAuth provider (Google or Slack). Without one configured, nobody can
sign in, even locally.

- The Client ID/Secret only identify your Outline instance to Google.
- The login redirect goes to `http://localhost:4199/auth/google.callback`
  — your documents stay on your machine.
- The **first account to sign in becomes the admin**.
- If your machine is fully offline, OAuth can't work (Google's servers
  must be reachable for the handshake).
- Alternative: Slack OAuth (needs a Slack workspace). Google is simpler
  for personal use.

## How it works

- **Dedicated Postgres + Redis** — separate from SnapOtter's, so the two
  stacks can't interfere.
- **Postgres/Redis are not published to the host** — they only talk over
  the compose network (also avoids port conflicts with SnapOtter).
- **`depends_on` with `condition: service_healthy`** — Outline waits until
  Postgres and Redis actually answer, not just start.
- **`SECRET_KEY` / `UTILS_SECRET`** — used for session encryption and
  utility hashing; must be 32+ characters.
- **`URL`** — must match how you access Outline. Changing it later breaks
  existing links, so set it right the first time.
- Attachments/images are stored in `~/Projects/Containers/Outline/data`.

## docker-compose.yml

```yaml
services:
  outline:
    image: docker.getoutline.com/outlinewiki/outline:latest  # pin a version, e.g. :1.2.0
    container_name: outline
    restart: unless-stopped
    ports:
      - "4199:3000"
    volumes:
      - ${HOME}/Projects/Containers/Outline/data:/var/lib/outline/data
    environment:
      DATABASE_URL: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      REDIS_URL: redis://redis:6379
      SECRET_KEY: ${SECRET_KEY:?set SECRET_KEY in .env}
      UTILS_SECRET: ${UTILS_SECRET:?set UTILS_SECRET in .env}
      URL: ${URL:-http://localhost:4199}
      GOOGLE_CLIENT_ID: ${GOOGLE_CLIENT_ID:?set GOOGLE_CLIENT_ID in .env}
      GOOGLE_CLIENT_SECRET: ${GOOGLE_CLIENT_SECRET:?set GOOGLE_CLIENT_SECRET in .env}
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
    container_name: outline-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-outline}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?set POSTGRES_PASSWORD in .env}
      POSTGRES_DB: ${POSTGRES_DB:-outline}
    volumes:
      - ${HOME}/Projects/Containers/Outline/postgresql:/var/lib/postgresql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-outline} -d ${POSTGRES_DB:-outline}"]
      interval: 10s
      timeout: 5s
      retries: 12

  redis:
    image: redis:8-alpine
    container_name: outline-redis
    restart: unless-stopped
    volumes:
      - ${HOME}/Projects/Containers/Outline/redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 12
```

## Troubleshooting

- **Can't log in / no "Sign in with Google":** `GOOGLE_CLIENT_ID` /
  `GOOGLE_CLIENT_SECRET` missing or wrong in `.env` — check with
  `docker compose config`
- **`redirect_uri_mismatch` from Google:** the redirect URI in Google
  Cloud Console must be exactly `http://localhost:4199/auth/google.callback`
- **Outline container exits on startup:** `docker compose logs outline` —
  common causes are a short `SECRET_KEY`/`UTILS_SECRET` (<32 chars) or a
  bad `DATABASE_URL`
- **Postgres password with special chars** (`@`, `:`, `/`): URL-encode it,
  or use alphanumerics only
- **Port 4199 busy:** change the left side, e.g. `"4200:3000"` (and update
  `URL` + the Google redirect URI to match)
- **Logs:** `docker compose logs -f outline`

## Notes

- **Pin the image tag** (e.g. `:1.2.0`) instead of `:latest` so upgrades
  are deliberate — the official docs recommend this too
- **No https-portal** — it requires Let's Encrypt (online). For local use,
  plain HTTP on 4199 is fine. If you later get a domain, re-add it with
  `DOMAINS: 'your.domain -> http://outline:3000'`
- **The official example's Redis config is broken** — it runs
  `redis-server /redis.conf` without mounting a conf file. Defaults work
  fine, so this compose omits the custom command
- **Backups (optional):** stop the stack, then
  `tar -czf outline-backup.tar.gz ~/Projects/Containers/Outline`
