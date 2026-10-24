#!/usr/bin/env bash
# =============================================================================
#  distrobox/arch.sh  —  Provision the Arch Linux Distrobox container
# -----------------------------------------------------------------------------
#  Installs the zsh/dotfiles runtime plus a small dev toolkit so that this
#  repo's shell config works inside the container.
#
#  Run this INSIDE the Arch container (see the message printed by
#  setup_distrobox in bootstrap.sh), as your normal user.
#
#  Native package manager: pacman
# =============================================================================

set -euo pipefail

# ---- pretty output ----------------------------------------------------------
c_ok=$'\033[32m'; c_warn=$'\033[33m'; c_err=$'\033[31m'; c_info=$'\033[36m'; c_off=$'\033[0m'
log()  { printf '%s==>%s %s\n'  "$c_info" "$c_off" "$*"; }
ok()   { printf '%s  ok%s %s\n'  "$c_ok"   "$c_off" "$*"; }
warn() { printf '%s  !!%s %s\n'  "$c_warn" "$c_off" "$*"; }
die()  { printf '%s ERR%s %s\n'  "$c_err"  "$c_off" "$*" >&2; exit 1; }

command -v pacman >/dev/null 2>&1 || die "This script is for Arch (pacman not found)."

# ---- package sets -----------------------------------------------------------
# Core shell + dotfiles runtime dependencies
base_pkgs=(
    base-devel git curl wget unzip zip
    zsh
)

# Everything the zsh config (dotfiles/zsh) expects on PATH
zsh_stack=(
    fzf zoxide atuin starship eza bat fd ripgrep gum
    zellij fastfetch onefetch tldr
)

# Dev essentials you tend to have around
dev_pkgs=(
    fnm python python-pip python-pipx uv
    go nodejs npm
    git-delta tig
    openssh rsync
)

all_pkgs=("${base_pkgs[@]}" "${zsh_stack[@]}" "${dev_pkgs[@]}")

log "Updating pacman databases..."
sudo pacman -Sy --noconfirm

log "Installing ${#all_pkgs[@]} packages..."
if sudo pacman -S --needed --noconfirm "${all_pkgs[@]}"; then
    ok "All packages installed"
else
    warn "Some packages failed; retrying one-by-one to identify them"
    for pkg in "${all_pkgs[@]}"; do
        sudo pacman -S --needed --noconfirm "$pkg" || warn "skipped: $pkg"
    done
fi

# ---- optional extras not always in the repos --------------------------------
if ! command -v eza >/dev/null 2>&1; then
    warn "eza missing — install from AUR if desired (yay -S eza)"
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
ok "Arch container provisioned."
printf '%sNext:%s run the dotfiles/shell setup from the host repo:\n' "$c_info" "$c_off"
printf '  1. Exit this container:  %sexit%s\n' "$c_info" "$c_off"
printf '  2. On the host bootstrap, choose menu option %s15 (Dotfiles)%s\n' "$c_info" "$c_off"
printf '  3. Start zsh:            %szsh%s\n' "$c_info" "$c_off"
printf '\nThe shell config expects ~/.omarchy-tweaks (a symlink to this repo) and\n'
printf '~/.secrets.zsh; make sure those exist in this container before opening zsh.\n'
