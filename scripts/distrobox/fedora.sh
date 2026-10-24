#!/usr/bin/env bash
# =============================================================================
#  distrobox/fedora.sh  —  Provision the Fedora Distrobox container
# -----------------------------------------------------------------------------
#  Installs the zsh/dotfiles runtime plus a small dev toolkit so that this
#  repo's shell config works inside the container.
#
#  Run this INSIDE the Fedora container (see the message printed by
#  setup_distrobox in bootstrap.sh), as your normal user.
#
#  Native package manager: dnf
# =============================================================================

set -euo pipefail

# ---- pretty output ----------------------------------------------------------
c_ok=$'\033[32m'; c_warn=$'\033[33m'; c_err=$'\033[31m'; c_info=$'\033[36m'; c_off=$'\033[0m'
log()  { printf '%s==>%s %s\n'  "$c_info" "$c_off" "$*"; }
ok()   { printf '%s  ok%s %s\n'  "$c_ok"   "$c_off" "$*"; }
warn() { printf '%s  !!%s %s\n'  "$c_warn" "$c_off" "$*"; }
die()  { printf '%s ERR%s %s\n'  "$c_err"  "$c_off" "$*" >&2; exit 1; }

command -v dnf >/dev/null 2>&1 || die "This script is for Fedora (dnf not found)."

# ---- package sets -----------------------------------------------------------
base_pkgs=(
    @development-tools git curl wget unzip zip ca-certificates gnupg2
)

zsh_stack=(
    zsh
    fzf zoxide
    eza bat fd-find ripgrep
    zellij
    tldr
)

dev_pkgs=(
    python3 python3-pip pipx
    golang nodejs npm
    git-delta tig
    rsync openssh-clients
)

all_pkgs=("${base_pkgs[@]}" "${zsh_stack[@]}" "${dev_pkgs[@]}")

log "Installing ${#all_pkgs[@]} packages via dnf..."
if sudo dnf install -y "${all_pkgs[@]}"; then
    ok "All packages installed"
else
    warn "Batch install failed; retrying one-by-one"
    for pkg in "${all_pkgs[@]}"; do
        sudo dnf install -y "$pkg" || warn "skipped: $pkg"
    done
fi

# ---- tools not in dnf: install via upstream when missing ---------------------
if ! command -v atuin >/dev/null 2>&1; then
    log "Installing atuin (upstream install script)..."
    curl -fsSL https://setup.atuin.sh | bash || warn "atuin install failed"
fi
if ! command -v starship >/dev/null 2>&1; then
    log "Installing starship (upstream install script)..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y || warn "starship install failed"
fi
if ! command -v gum >/dev/null 2>&1; then
    log "Installing gum (charm dnf repo)..."
    sudo tee /etc/yum.repos.d/charm.repo >/dev/null <<'REPO'
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
REPO
    sudo dnf install -y gum || warn "gum install failed"
fi
if ! command -v fnm >/dev/null 2>&1; then
    log "Installing fnm (upstream install script)..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell || warn "fnm install failed"
fi
if ! command -v uv >/dev/null 2>&1; then
    log "Installing uv (upstream install script)..."
    curl -fsSL https://astral.sh/uv/install.sh | sh || warn "uv install failed"
fi

# ---- default shell ----------------------------------------------------------
if [[ "$SHELL" != *zsh ]]; then
    log "Setting zsh as the default shell..."
    if chsh -s "$(command -v zsh)" 2>/dev/null; then
        ok "Default shell set to zsh"
    else
        warn "Could not change shell (chsh failed). Run: chsh -s \$(command -v zsh)"
    fi
fi

# ---- done -------------------------------------------------------------------
printf '\n'
ok "Fedora container provisioned."
printf '%sNext:%s run the dotfiles/shell setup from the host repo:\n' "$c_info" "$c_off"
printf '  1. Exit this container:  %sexit%s\n' "$c_info" "$c_off"
printf '  2. On the host bootstrap, choose menu option %s15 (Dotfiles)%s\n' "$c_info" "$c_off"
printf '  3. Start zsh:            %szsh%s\n' "$c_info" "$c_off"
printf '\nThe shell config expects ~/.omarchy-tweaks (a symlink to this repo) and\n'
printf '~/.secrets.zsh; make sure those exist in this container before opening zsh.\n'
