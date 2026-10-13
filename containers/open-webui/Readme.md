# Open WebUI (Docker)

Runs Open WebUI in Docker and connects it to services running **on this host**:

| Service   | On the host          | Inside the container                |
|-----------|----------------------|-------------------------------------|
| Ollama    | `localhost:11434`    | `http://ollama.local:11434`         |
| omniroute | `localhost:20128`    | `http://omniroute.local:20128`      |
| Open WebUI| —                    | `http://localhost:3000`             |

## Prerequisites

- Docker Engine 20.10+ with Compose v2
- Ollama running on the host, port 11434
- omniroute running on the host, port 20128

> ⚠️ Both host services must listen on `0.0.0.0`, **not** only `127.0.0.1`,
> otherwise the container cannot reach them.
>
> Ollama (Linux): create `/etc/systemd/system/ollama.service.d/override.conf`:
> ```ini
> [Service]
> Environment="OLLAMA_HOST=0.0.0.0"
> ```
> then `sudo systemctl daemon-reload && sudo systemctl restart ollama`.
>
> omniroute: bind it to `0.0.0.0:20128` in its config.

## Quick start

```bash
# 1. Create .env with a generated secret
echo "WEBUI_SECRET_KEY=$(openssl rand -hex 32)" > .env

# 2. Start
docker compose up -d

# 3. Open http://localhost:3000 and create the first user
```

Add `.env` to `.gitignore` — it contains your secret.

## How the aliases work

`extra_hosts` maps each hostname to `host-gateway` (your host's IP as seen
from inside the container):

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
  - "ollama.local:host-gateway"
  - "omniroute.local:host-gateway"
```

So `http://ollama.local:11434` in the container == `http://localhost:11434` on the host.

## Wiring up providers in the Open WebUI UI

- **Ollama** — auto-detected via `OLLAMA_BASE_URL`. Manual entry if needed:
  Settings → Models → Add model → Base URL `http://ollama.local:11434`
- **omniroute** — Open WebUI has no built-in omniroute integration; add it as an
  OpenAI-compatible connection: Settings → Connections → Add →
  Base URL `http://omniroute.local:20128` (+ API key if omniroute requires one).

## docker-compose.yml

```yaml
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:slim
    container_name: OpenWebUi
    restart: unless-stopped
    ports:
      - "3000:8080"
    volumes:
      - ${HOME}/Projects/Containers/OpenWebUi:/app/backend/data
    extra_hosts:
      - "host.docker.internal:host-gateway"
      - "ollama.local:host-gateway"
      - "omniroute.local:host-gateway"
    environment:
      - WEBUI_SECRET_KEY=${WEBUI_SECRET_KEY:?set WEBUI_SECRET_KEY in .env}
      - OLLAMA_BASE_URL=${OLLAMA_BASE_URL:-http://ollama.local:11434}
      # omniroute: no native Open WebUI integration; URL kept here as reference.
      - OMNIROUTE_URL=${OMNIROUTE_URL:-http://omniroute.local:20128}
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/health', timeout=5)"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

## .env

```env
# Generate with: openssl rand -hex 32
WEBUI_SECRET_KEY=paste_your_generated_secret_here

# Optional overrides
# OLLAMA_BASE_URL=http://ollama.local:11434
# OMNIROUTE_URL=http://omniroute.local:20128
```

## Troubleshooting

- **Can't reach Ollama from the container:**
  ```bash
  docker compose exec open-webui python -c "import urllib.request; print(urllib.request.urlopen('http://ollama.local:11434/api/tags').read())"
  ```
  If this fails, the host service is bound to 127.0.0.1 — see the warning above.
- **Healthcheck red in `docker compose ps`:** `docker compose logs open-webui`
- **Port 3000 busy:** change the left side, e.g. `"8081:8080"`
- **Linux + `sudo docker compose`:** `${HOME}` resolves to root's home — use an
  absolute path in the volume instead.
- **macOS/Windows:** `host.docker.internal` works natively; the aliases are still fine.

## Notes

- Data persists in `~/Projects/Containers/OpenWebUi`
- Logs capped at 10 MB × 3 files
- `:slim` image skips optional document-loader deps; switch to the full image if
  some file imports fail
