<h1 align='center'> Omarchy Tweaks </h1>

<p align='center'>
  <strong>Personal Omarchy customization, automation, and bootstrap toolkit.</strong>
</p>

<p align='center'>
  <a href="https://github.com/Armoghan-ul-Mohmin/omarchy-tweaks/blob/main/LICENSE">License</a> •
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#structure">Structure</a> •
  <a href="#disclaimer">Disclaimer</a>
</p>

Omarchy Tweaks is a curated collection of configs, scripts, containers, and utilities that shape my Omarchy desktop to fit my workflow. It includes a robust, interactive `bootstrap.sh` to provision a fresh Omarchy install with the tools, apps, AI configs, containers, and customizations I use.

## Features

- **Interactive Bootstrap** — Menu-driven (`--menu`) or full automated run with confirmations, backups, and safe symlinks
- **Bloatware Cleanup** — Remove unwanted preinstalled packages/TUIs/WebApps
- **Package Management** — Install curated Pacman & AUR packages
- **WebApps & Omarchy Plugins** — Install preconfigured web apps and community Omarchy plugins
- **AI Tooling** — Setup Claude Code, OpenCode, Codex with Omniroute integration and pull curated Ollama models
- **Docker Containers** — Atuin-AI, OpenWebUI, Outline, SnapOtter with sample envs and READMEs
- **Custom Utilities** — Handy scripts in `bin/` (compress/extract helpers, hastebin, keybind help, lzj, server, tij, etc.)
- **System Scripts** — Custom Omarchy script overrides for snapshots, VM helpers, fingerprint setup
- **Idempotent & Safe** — Backs up existing configs/symlinks, uses `set -Eeuo pipefail`, sudo handling, nullglob, and colored/nerd-font UI
- **Extensible** — DRY helpers, modular functions, easy to add new steps

## Installation

Clone to your system. You can keep it anywhere, but I use `~/.omarchy-tweaks`.

```bash
git clone --depth=1 https://github.com/Armoghan-ul-Mohmin/omarchy-tweaks.git ~/.omarchy-tweaks
cd ~/.omarchy-tweaks
chmod +x bootstrap.sh
```

## Usage

### Interactive Menu (recommended)

Explore and run individual actions or the full bootstrap.

```bash
./bootstrap.sh --menu
```

### Full Bootstrap

Run everything end-to-end with confirmations.

```bash
./bootstrap.sh
```

### CLI Options

```bash
./bootstrap.sh --help
./bootstrap.sh --version
./bootstrap.sh --debug
./bootstrap.sh --menu
```

### Environment Overrides

```bash
# Use a different project location
BOOTSTRAP_PROJECT_DIR=/path/to/omarchy-tweaks ./bootstrap.sh

# Override Omarchy bin directory
OMARCHY_BIN=/usr/local/share/omarchy/bin ./bootstrap.sh --menu
```

## Structure

```text
omarchy-tweaks/
├── assets/           # Icons for webapps (PNG)
├── banner.txt        # Custom banner shown in bootstrap
├── bin/              # Local utility scripts (symlinked to ~/.local/bin)
├── bootstrap.sh      # Main bootstrap script (refactored, menu-driven)
├── config/           # Tool configs (atuin, claude, codex, mise, opencode, desktop)
├── containers/       # Docker compose stacks + sample.env + READMEs
├── LICENSE
├── logs/             # Runtime logs (bootstrap.log, gitignored except .gitkeep)
├── Readme.md
└── scripts/          # Custom Omarchy system script overrides
```

## Notes

- **Backups**: Existing files/symlinks are backed up with timestamped `.bak` files before replacement.
- **Sudo**: Root/sudo is required for pacman/AUR/system file overwrites. The script handles escalation safely.
- **Secrets**: Real `.env` files are ignored. Only `sample.env` files are tracked.
- **Logs**: `logs/bootstrap.log` is gitignored; `logs/.gitkeep` keeps the directory in repo.
- **Nerd Fonts**: UI uses Nerd Font icons — recommended for best experience.
- **Idempotent-friendly**: Re-running is safe thanks to confirmations, existence checks, and backups.

## Disclaimer

This is my personal setup. Running the bootstrap may install/remove packages, create symlinks, overwrite system scripts in `/usr/share/omarchy/bin`, start containers, and change configs. Review `bootstrap.sh` and files under `config/`, `scripts/`, `bin/` before running. Back up important data/configs first. Use at your own discretion.

## License

MIT License. See [LICENSE](LICENSE) for details.
