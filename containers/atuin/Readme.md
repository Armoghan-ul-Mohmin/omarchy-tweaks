# Atuin AI Server (Docker)

Stateless AI companion for Atuin shell history. Runs with **host
networking**; the only thing persisted is its config directory on the host.

| Item      | Value                                              |
|-----------|----------------------------------------------------|
| Service   | atuin-ai                                           |
| Image     | `ghcr.io/atuinsh/atuin-ai-server:latest`         |
| Web/API   | `http://localhost:8888` (port set in `config.toml`) |
| Config    | `~/.config/atuin-ai-server/` → `/etc/atuin-ai`   |
| Data      | none — history lives in your **Atuin server** (separate) |

## Prerequisites

- Docker Engine 20.10+ with Compose v2
- A running **Atuin server** (this service only adds AI search on top)

## Quick start

```bash
# 1. Create config directory
mkdir -p ~/.config/atuin-ai-server

# 2. Create .env with a generated token
echo "AUTH_TOKEN=$(openssl rand -hex 32)" > .env

# 3. Edit ~/.config/atuin-ai-server/config.toml (see official docs for schema)

# 4. Start
docker compose up -d
```

Add `.env` to `.gitignore` — it contains your auth token.

## .env

```env
# Rotate this if you ever pasted it anywhere (chat, git, etc.)
AUTH_TOKEN=your_long_token_here
```

## How it works

- **`network_mode: host`** — the container shares your host's network, so
  there is **no `ports:` section**. The listen port comes from `config.toml`
  (default `8888`).
- **Directory bind mount** (not a single file) — if `config.toml` is
  missing at `up` time, Docker would create a *directory* and the container
  would fail to parse it. Mounting the whole dir avoids that gotcha.
- **`AUTH_TOKEN` enforced** — the `:?` syntax makes Compose fail loudly if
  `.env` is missing, instead of starting unauthenticated.
- Your Atuin client(s) must use the **same** `AUTH_TOKEN`.

## docker-compose.yml

```yaml
services:
  atuin-ai:
    image: ghcr.io/atuinsh/atuin-ai-server:latest
    container_name: Atuin-Ai
    restart: unless-stopped
    network_mode: host          # replaces --network host; no ports: needed
    environment:
      AUTH_TOKEN: ${AUTH_TOKEN:?set AUTH_TOKEN in .env}
    volumes:
      - ${HOME}/.config/atuin-ai-server:/etc/atuin-ai
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

## Troubleshooting

- **Container exits immediately:** check `~/.config/atuin-ai-server/config.toml`
  exists and is valid TOML — `docker compose logs atuin-ai`
- **Port already in use:** change `port` in `config.toml`
- **Auth errors:** token mismatch between `.env` and your Atuin client config
- **macOS/Windows:** `network_mode: host` is a no-op on Docker Desktop.
  Replace it with:
  ```yaml
  ports:
    - "8888:8888"   # match the port in config.toml
  ```
- **Logs:** `docker compose logs -f atuin-ai`

## Notes

- **Stateless** — nothing to back up except the config directory
- **Pin the tag** (`:latest` moves) — e.g. `:v0.x.x` for reproducible deploys
- **Health:** add a healthcheck only if you know a live endpoint; the image
  ships none by default
