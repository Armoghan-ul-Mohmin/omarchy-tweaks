<h1 align='center'> Omarchy Tweaks </h1>

<p align='center'>
  <strong>My personal Omarchy customization, automation, and bootstrap toolkit.</strong>
</p>

<p align='center'>
  <a href="https://github.com/Armoghan-ul-Mohmin/omarchy-tweaks/blob/main/LICENSE">License</a> •
  <a href="#features">Features</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#usage">Usage</a> •
  <a href="#whats-inside">What's Inside</a> •
  <a href="#shell-docs">Shell Docs</a> •
  <a href="#structure">Structure</a> •
  <a href="#disclaimer">Disclaimer</a>
</p>

Omarchy Tweaks is a curated collection of configs, dotfiles, scripts, containers, and utilities that shape my [Omarchy](https://omarchy.org) desktop to fit my workflow. At its core is a robust, interactive `bootstrap.sh` that provisions a fresh Omarchy install with the tools, apps, AI configs, containers, and customizations I use — idempotent, confirmation-driven, and safe.

## Features

- **Interactive Bootstrap** — Menu-driven (`--menu`) or full automated run with confirmations, backups, and safe symlinks
- **Bloatware Cleanup** — Remove unwanted preinstalled packages, TUIs, WebApps, and MISE binaries
- **Package Management** — Install a curated Pacman & AUR package set
- **WebApps & Omarchy Plugins** — Install preconfigured web apps and community Omarchy plugins
- **AI Tooling** — Set up Claude Code, OpenCode, and Codex with Omniroute integration, plus curated Ollama models
- **Docker Containers** — Atuin-AI, OpenWebUI, Outline, and SnapOtter stacks, each with `sample.env` and a README
- **Modular Zsh Config** — A full zsh setup under `dotfiles/zsh/`: plug.zsh plugins, Atuin history, fzf-tab, gum-powered functions, and custom keybindings
- **Git Dotfiles** — Global git config, Catppuccin theming, and chaining global hooks (conventional commits, secret scanning, large-file checks)
- **Shell Documentation** — A devhints-style reference site under `docs/` covering zsh, aliases, functions, git, and the whole config
- **Custom Utilities** — Handy scripts in `bin/` (archive compress/extract, hastebin, lazy zellij, tmux sessions, dev server, keybind help, and more)
- **System Scripts** — Custom Omarchy script overrides for snapshots, VM helpers, and fingerprint setup
- **Idempotent & Safe** — Backs up existing configs/symlinks, uses `set -Eeuo pipefail`, sudo handling, `nullglob`, and colored Nerd Font UI

## Quick Start

```bash
git clone --depth=1 https://github.com/Armoghan-ul-Mohmin/omarchy-tweaks.git ~/.omarchy-tweaks
cd ~/.omarchy-tweaks
chmod +x bootstrap.sh
./bootstrap.sh --menu
```

Cloning to `~/.omarchy-tweaks` is recommended: the bootstrap links the repo there, the zsh config adds `~/.omarchy-tweaks/bin` to `PATH`, and the Omarchy "Learn" menu entries point at `~/.omarchy-tweaks/docs/`.

## Usage

### Interactive Menu (recommended)

Explore and run individual actions, or the full bootstrap.

```bash
./bootstrap.sh --menu
```

### Full Bootstrap

Run everything end-to-end with confirmations at each step.

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

# Override the Omarchy bin directory
OMARCHY_BIN=/usr/local/share/omarchy/bin ./bootstrap.sh --menu
```

## What's Inside

### Bootstrap menu actions

| # | Action | What it does |
|---|--------|--------------|
| 1 | Full Bootstrap | Runs every step below, end-to-end |
| 2 | System Snapshot | Creates a Btrfs/Snapper snapshot before changes |
| 3 | Cleanup | Removes bloatware packages, TUIs, WebApps, MISE binaries |
| 4 | Packages | Installs curated Pacman + AUR packages |
| 5 | WebApps | Installs preconfigured web apps |
| 6 | Omarchy Plugins | Installs community Omarchy plugins |
| 7 | Ollama | Installs Ollama and pulls curated models |
| 8–10 | AI Setup | Configures Claude Code, OpenCode, Codex (+ Omniroute) |
| 11 | Omniroute | Installs Omniroute globally via npm |
| 12 | Containers | Sets up Atuin-AI, OpenWebUI, Outline, SnapOtter |
| 13 | Directories | Creates `~/Github`, `~/Projects`, `~/.ISO`, `~/.VM` |
| 14 | Bins | Symlinks `bin/*` into `~/.local/bin` |
| 15 | Dotfiles | Links git, Atuin, Starship, and zsh configs (+ docs menu entries) |
| 16 | Omarchy Overwrites | Installs custom system script overrides |
| 17–19 | Utilities | View log, show version, toggle debug |

### Zsh configuration (`dotfiles/zsh/`)

A modular setup loaded by `lib/*.zsh` in numbered order:

- **`00-env`** — editor/pager, fzf theming, plug settings, `PATH`, starship
- **`10-options`** — setopts; Atuin owns history (no local `HISTFILE`)
- **`20-plugins`** — plug.zsh: autosuggestions, fzf-tab, syntax highlighting, you-should-use, plus starship/fzf/zoxide/atuin inits
- **`30-fzf-tab`** — fuzzy completion previews and the fzf ZLE widgets
- **`40-aliases`** — ~90 aliases (navigation, eza listings, git, wrappers)
- **`50-functions`** — gum-powered functions (ports, disk, notes, hashing, confirmed file ops, git wizards)
- **`60-keybindings`** — emacs keymap, `run-tui`, and every custom binding

See [`dotfiles/zsh/README.md`](dotfiles/zsh/README.md) for details.

### Custom utilities (`bin/`)

| Script | Purpose |
|--------|---------|
| `compress` / `extract` | Archive helpers for many formats |
| `hastebin` | Beautiful pste.us uploader with title/language/expiry/burn, secret scanning & safety guards |
| `lzj` | "lazy zellij" — fzf-based zellij session manager (local + remote) |
| `tij` | tmux session manager |
| `server` | Start a local dev server (node, npm, hugo, python, uv, php, mkdocs) |
| `keybind-help` | TUI showing all zsh keybindings (also `Alt+?` in the shell) |
| `zsh-dev` | Launch the repo's zsh config via `ZDOTDIR` without installing |
| `omarchy-clipboard-cleaner` | Clipboard cleanup helper |
| `vscode-css-fix` | VS Code CSS-related fix utility |

### Git dotfiles (`dotfiles/git/`)

- Global `config` with delta pager and Catppuccin theming (`catppuccin.gitconfig`)
- Chaining global hooks: `pre-commit` (secret scanning), `commit-msg` (Conventional Commits), `pre-push` (large-file/upstream checks), `post-rewrite`
- `ignore` and `secret-patterns` support files

## Shell Docs

A devhints-style reference site lives in [`docs/`](docs/index.html). Open `docs/index.html` in a browser — no build step, plain HTML + one stylesheet.

| Page | Contents |
|------|----------|
| [Zsh Cheatsheet](docs/zsh-cheatsheet.html) | expansions, globbing, redirection, history, line editing |
| [My Aliases](docs/aliases.html) | every alias in `40-aliases.zsh` |
| [My Zsh Config](docs/zsh-config.html) | modules, env vars, plugins, fzf-tab, keybindings |
| [Git Cheatsheet](docs/git-cheatsheet.html) | git reference + `g…` aliases and widgets |
| [Functions](docs/functions.html) | every function in `50-functions.zsh` |

The bootstrap can add these as entries in Omarchy's "Learn" menu.

## Structure

```text
omarchy-tweaks/
├── assets/           # Icons for webapps and menus (PNG)
├── banner.txt        # Custom banner shown in bootstrap
├── bin/              # Local utility scripts (symlinked to ~/.local/bin)
├── bootstrap.sh      # Main bootstrap script (menu-driven, idempotent)
├── config/           # Tool configs (atuin-ai-server, claude, codex, mise, opencode, cyberchef)
├── containers/       # Docker compose stacks + sample.env + READMEs
├── docs/             # devhints-style shell documentation (HTML + assets/style.css)
├── dotfiles/         # Managed dotfiles
│   ├── atuin/        #   atuin config + themes
│   ├── git/          #   global git config, theming, chaining hooks
│   ├── starship/     #   starship prompt config
│   └── zsh/          #   modular zsh config (.zshrc + lib/*.zsh)
├── logs/             # Runtime logs (bootstrap.log, gitignored except .gitkeep)
├── scripts/          # Custom Omarchy system script overrides
├── LICENSE
└── Readme.md
```

## Notes

- **Backups**: Existing files/symlinks are backed up with timestamped `.bak` files before replacement.
- **Sudo**: Root/sudo is required for pacman/AUR installs and system file overwrites; the script escalates safely.
- **Secrets**: Real `.env` files are ignored — only `sample.env` files are tracked. Machine-private zsh values belong in `~/.secrets.zsh` (created mode 600, sourced last).
- **Logs**: `logs/bootstrap.log` is gitignored; `logs/.gitkeep` keeps the directory in the repo.
- **Nerd Fonts**: The UI uses Nerd Font icons — recommended for the best experience.
- **Idempotent-friendly**: Re-running is safe thanks to confirmations, existence checks, and backups.

## Disclaimer

This is my personal setup. Running the bootstrap may install/remove packages, create symlinks, overwrite system scripts in `/usr/share/omarchy/bin`, start containers, and change configs. Review `bootstrap.sh` and the files under `config/`, `scripts/`, `bin/`, and `dotfiles/` before running. Back up important data and configs first. Use at your own discretion.

## License

MIT License. See [LICENSE](LICENSE) for details.
