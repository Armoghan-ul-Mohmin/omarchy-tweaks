#!/usr/bin/env bash

# ======================================================= #
#          Bootstrap Script for Project Setup             #
# ======================================================= #
#   Author:  Armoghan-ul-Mohmin                           #
#   Version: 1.0.1                                        #
#   Date:    2026-10-13                                   #
# ======================================================= #
#                                                         #
#   Usage:                                                #
#     chmod +x bootstrap.sh                               #
#     ./bootstrap.sh                                      #
#     ./bootstrap.sh --menu                               #
#     ./bootstrap.sh --help                               #
#     ./bootstrap.sh --version                            #
#     BOOTSTRAP_PROJECT_DIR=/path ./bootstrap.sh           #
#                                                         #
# ======================================================= #

set -Eeuo pipefail
IFS=$'\n\t'

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR
trap on_interrupt INT

# ======================================================= #
#  Global Variables
# ======================================================= #

# Metadata
AUTHOR="Armoghan-ul-Mohmin"
VERSION="1.0.0"
URL="https://github.com/Armoghan-ul-Mohmin/omarchy-tweaks.git"
SCRIPT_NAME="bootstrap.sh"
LOG_DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

# Debug
DEBUG=0

# Paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${BOOTSTRAP_PROJECT_DIR:-$SCRIPT_DIR}"
CONFIG_DIR="$HOME/.config"
LOG_DIR="$PROJECT_DIR/logs"
HOME_DIR="$HOME"
OMARCHY_BIN="${OMARCHY_BIN:-/usr/share/omarchy/bin}"

# Files
LOG_FILE="$LOG_DIR/bootstrap.log"
BANNER_FILE="$PROJECT_DIR/banner.txt"

# Log levels
readonly LOG_LEVEL_INFO="INFO"
readonly LOG_LEVEL_SUCCESS="SUCCESS"
readonly LOG_LEVEL_WARNING="WARN"
readonly LOG_LEVEL_ERROR="ERROR"
readonly LOG_LEVEL_DEBUG="DEBUG"

# Nerd Font Icons
NF_CHECK=""
NF_CROSS=""
NF_WARNING=""
NF_INFO=""
NF_DEBUG=""
NF_ARROW=""
NF_ROCKET="󰓅"
NF_GEAR=""
NF_FOLDER=""
NF_PACKAGE="󰏖"
NF_CLOUD="󰅟"
NF_SERVER="󰒋"
NF_SETTINGS="󰒓"
NF_LINK=""
NF_SPARKLE="✨"
NF_TERMINAL=""
NF_DESKTOP="󰟀"
NF_CPU=""
NF_HOURGLASS="󰔟"
NF_SEARCH=""
NF_LIST=""
NF_STAR=""
NF_FIRE="󰈸"
NF_CODE="󰅩"
NF_BOX="󰆧"
NF_BOLT=""
NF_LAUNCH="󰐃"
NF_SHIELD="󰒡"
NF_DATABASE="󰆼"
NF_KEY=""

# Package List (bloatware)
readonly PACKAGES_TO_REMOVE=(
    "aether"
    "cliamp"
    "libreoffice-fresh"
    "xournalpp"
    "pinta"
    "obsidian"
    "obs-studio"
    "kdenlive"
    "moonlight-qt"
    "lazydocker"
    "omacut"
    "omacalc"
    "omawrite"
)

# Mise Packages
readonly MISE=(
    "$HOME/.local/bin/gemini"
    "$HOME/.local/bin/pi"
    "$HOME/.local/bin/omp"
    "$HOME/.local/bin/grok"
    "$HOME/.local/bin/crush"
    "$HOME/.local/bin/ghui"
    "$HOME/.local/bin/hunk"
    "$HOME/.local/bin/cursor-agent"
    "$HOME/.local/bin/hermes"
)

# Pacman Packages
readonly PACMAN_PACKAGES=(
    "atuin"
    "brave-origin-bin"
    "fnm"
    "git-delta"
    "gitleaks"
    "go"
    "hugo"
    "kdeconnect"
    "omarchy-zsh"
    "onefetch"
    "onionshare"
    "openvpn"
    "python-pip"
    "python-pipx"
    "python-pytest"
    "qemu-desktop"
    "qemu-full"
    "qemu-user-static-binfmt"
    "qrencode"
    "ripgrep"
    "sqlitebrowser"
    "superfile"
    "tig"
    "tldr"
    "ttf-hack-nerd"
    "uv"
    "virt-manager"
    "virt-viewer"
    "visual-studio-code-bin"
    "zellij"
    "zen-browser-bin"
    "zram-generator"
)

# AUR Packages
readonly AUR_PACKAGES=(
    "powershell-bin"
    "cyberchef-web"
    "anydesk-bin"
)

# WebApps: name | URL | local icon (optional)
readonly WEBAPPS=(
    "Claude|https://claude.ai/|"
    "Dropbox|https://www.dropbox.com/home|"
    "Google Drive|https://drive.google.com/drive|"
    "LinkedIn|https://www.linkedin.com|"
    "Notion|https://app.notion.com/login|"
    "OneDrive|https://onedrive.live.com/|"
    "OpenRouter|https://openrouter.ai/workspaces/default|"
    "YouTube Music|https://music.youtube.com/|"
    "Omniroute|http://localhost:20128|omniroute.png"
    "OpenWebUI|http://127.0.0.1:4191|open-webui.png"
    "SnapOtter|http://localhost:1349|snapotter.png"
    "CyberChef|file:///usr/share/webapps/cyberchef/index.html|cyberchef.png"
    "Outline|http://localhost:4199|outline.png"
)

# Omarchy Plugins: name | URL | Description
readonly OMARCHY_PLUGINS=(
    "App Grid|https://github.com/matthewjaybarr-png/omarchy-app-grid.git|GNOME-style full-screen app grid"
    "Clipboard History|https://github.com/alanfortlink/clipboard-history.git|Raycast-style clipboard history"
    "Control center|https://github.com/404Prabhat/omarchy-control-center.git|Quick-settings hub"
    "Fathom|https://github.com/mtolhuys/fathom.git|A depth-based Alt-Tab"
    "Keybindings hint|https://github.com/Nejcc/omarchy-keybindings-hint.git|Hold SUPER to see what every SUPER + key does"
    "Kronos|https://github.com/MASH2RAFI/omarchy-kronos.git|Desktop clock with smooth minute/second orbital rings"
    "Lock Screen Explorer|https://github.com/SirJul1337/omarchy-lock-explorer.git|Lock screen designs for Omarchy"
    "OmaSettings|https://github.com/twiking/omasettings.git|One window for every Omarchy setting"
    "Omarchy Switcher|https://github.com/lsongdev/omarchy-switcher.git|Fast Super+Tab window switching"
    "Radial menu|https://github.com/signaldirective/radial-menu.git|A theme-aware radial (pie) version of the Omarchy menu"
    "Spotlight|https://github.com/maajix/omarchy-spotlight.git|A Raycast-style launcher for Omarchy"
    "Tray|https://github.com/TyRichards/omarchy-tray.git|A better system tray"
    "Yet Another Notification Center|https://github.com/Loafer19/omarchy-yet-another-notification-center.git|Notification history"
)

# Ollama Models
readonly OLLAMA_MODELS=(
    "qwen3:1.7b"
    "qwen2.5-coder:1.5b"
    "qwen2.5-coder:0.5b"
    "qwen:0.5b"
    "tinyllama:latest"
    "tinyllama:1.1b"
    "dolphin-phi:2.7b-v2.6-q3_K_S"
)

# ======================================================= #
# Error Handling & Utils
# ======================================================= #

on_error() {
    local exit_code=$?
    local line_number=$1
    local failed_command=$2

    msg_error "An unexpected error occurred."

    if [[ "$DEBUG" == "1" ]]; then
        msg_error "Command: $failed_command"
        msg_error "Line: $line_number"
        msg_error "Exit code: $exit_code"
    fi

    exit "$exit_code"
}

on_interrupt() {
    printf '\n'
    msg_warning "Operation interrupted by user."
    exit 130
}

__debug_trace() {
    local cmd="${BASH_COMMAND%% *}"
    case "$cmd" in
        msg_*|log|section|pause|confirm|require_cmd|ensure_dir|is_root|has_sudo)
            return
            ;;
        main|main_menu|show_menu|parse_arguments|init_logger|check_dependencies|banner|get_omarchy_version)
            printf '+ %s\n' "$BASH_COMMAND" >&2
            ;;
    esac
}

# Runtime helpers
is_root() {
    [[ "${EUID:-$(id -u)}" -eq 0 ]]
}

has_sudo() {
    command -v sudo >/dev/null 2>&1 && sudo -v >/dev/null 2>&1
}

sudo_cmd_array() {
    if is_root; then
        printf '%s\n' ""
        return 0
    fi
    if has_sudo; then
        printf 'sudo\n'
        return 0
    fi
    return 1
}

slugify() {
    local input="$*"
    printf '%s' "$input" |
        tr '[:upper:]' '[:lower:]' |
        sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//'
}

get_omarchy_version() {
    if command -v omarchy-version >/dev/null 2>&1; then
        omarchy-version 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

require_cmd() {
    local cmd="$1"
    local desc="${2:-$cmd}"
    if command -v "$cmd" >/dev/null 2>&1; then
        msg_debug "Command found: $cmd"
        return 0
    fi
    msg_error "Required command not found: ${desc}"
    return 1
}

ensure_dir() {
    local dir="$1"
    [[ -n "$dir" ]] || return 1
    if [[ -d "$dir" ]]; then
        msg_debug "Directory exists: $dir"
        return 0
    fi
    if mkdir -p -- "$dir"; then
        msg_debug "Created directory: $dir"
        return 0
    fi
    msg_error "Cannot create directory: $dir"
    return 1
}

backup_path() {
    local src="$1"
    [[ -e "$src" || -L "$src" ]] || return 0
    local ts
    ts="$(date +%Y%m%d_%H%M%S 2>/dev/null || printf '%s' "$(date +%s)")"
    local dst="${src}.${ts}.bak"
    if /usr/bin/mv -- "$src" "$dst" 2>/dev/null; then
        msg_debug "Backed up: $src -> $dst"
        return 0
    fi
    msg_error "Failed to backup: $src"
    return 1
}

symlink_or_backup() {
    local src="$1"
    local dst="$2"
    [[ -n "$src" && -n "$dst" ]] || return 1
    [[ -e "$src" || -L "$src" ]] || { msg_error "Source not found: $src"; return 1; }

    ensure_dir "$(dirname -- "$dst")" || return 1

    if [[ -e "$dst" || -L "$dst" ]]; then
        backup_path "$dst" || return 1
    fi

    if ln -sf -- "$src" "$dst"; then
        msg_success "Symlinked: $dst -> $src"
        return 0
    fi
    msg_error "Failed to symlink: $dst -> $src"
    return 1
}

# ======================================================= #
# Logger & Messages
# ======================================================= #

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp log_line

    timestamp="$(date "$LOG_DATE_FORMAT" 2>/dev/null || echo "unknown-time")"
    log_line="[$timestamp] [$level] $message"

    printf '%s\n' "$log_line" >> "$LOG_FILE" 2>/dev/null || {
        printf 'WARNING: Unable to write to log file\n' >&2
    }
}

init_logger() {
    ensure_dir "$LOG_DIR" || return 1
    if ! touch -- "$LOG_FILE" 2>/dev/null; then
        printf 'ERROR: Cannot create log file: %s\n' "$LOG_FILE" >&2
        return 1
    fi
    log "$LOG_LEVEL_DEBUG" "Logger initialized: $LOG_FILE"
}

msg_success() {
    gum style \
        --foreground 2 \
        --bold \
        "${NF_CHECK}  ${*}"
    log SUCCESS "$*"
}

msg_error() {
    gum style \
        --foreground 1 \
        --bold \
        "${NF_CROSS}  ${*}" >&2
    log ERROR "$*"
}

msg_warning() {
    gum style \
        --foreground 3 \
        --bold \
        "${NF_WARNING}  ${*}" >&2
    log WARN "$*"
}

msg_info() {
    gum style \
        --foreground 4 \
        "${NF_INFO}  ${*}"
    log INFO "$*"
}

msg_debug() {
    [[ "${DEBUG:-0}" == "1" ]] || return 0
    gum style \
        --foreground 8 \
        "${NF_DEBUG}  ${*}" >&2
    log DEBUG "$*"
}

section() {
    local title="$*"
    printf '\n'
    gum style \
        --foreground "#89b4fa" \
        --bold \
        --border rounded \
        --border-foreground "#89b4fa" \
        --padding "0 2" \
        "${NF_GEAR}  ${title}"
    printf '\n'
}

confirm() {
    local msg="$1"
    local default="${2:-true}"
    gum confirm \
        "$msg" \
        --default="$default" \
        --affirmative="Yes" \
        --negative="No"
}

pause() {
    local msg="${1:-Continue to next step?}"
    printf '\n'
    gum confirm \
        "${NF_HOURGLASS}  ${msg}" \
        --default=true \
        --affirmative="Continue" \
        --negative="Exit"
}

select_multiple() {
    local header="$1"
    shift
    local -a items=("$@")
    (( ${#items[@]} > 0 )) || return 1
    gum choose \
        --no-limit \
        --cursor="${NF_ARROW} " \
        --selected-prefix="${NF_CHECK} " \
        --unselected-prefix="  " \
        --header "$header" \
        "${items[@]}"
}

run_spinner() {
    local title="$1"
    shift
    gum spin \
        --spinner dot \
        --title "$title" \
        -- "$@"
}

# ======================================================= #
# Argument Parsing & Help
# ======================================================= #

parse_arguments() {
    while (($# > 0)); do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
                exit 0
                ;;
            -d|--debug)
                DEBUG=1
                trap '__debug_trace' DEBUG
                set +x
                ;;
            -m|--menu)
                export BOOTSTRAP_SHOW_MENU=1
                ;;
            *)
                printf 'Unknown option: %s\n' "$1" >&2
                show_help
                exit 2
                ;;
        esac
        shift
    done
}

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help       Show this help message
  -v, --version    Show script version
  -d, --debug      Enable debug output
  -m, --menu       Launch interactive menu

Environment:
  BOOTSTRAP_PROJECT_DIR  Override project directory (default: script dir)
  OMARCHY_BIN            Override Omarchy bin dir (default: /usr/share/omarchy/bin)
EOF
}

# ======================================================= #
# Core Functions
# ======================================================= #

command_exists() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        msg_debug "Command found: $cmd"
        return 0
    fi
    msg_error "Command not found: $cmd"
    return 1
}

check_dependencies() {
    require_cmd gum "gum (required for UI)" || exit 1
    require_cmd git "git" || return 1
    require_cmd snapper "snapper" || return 1
    msg_success "Core dependencies verified"
}

banner() {
    clear
    printf '\n\n'

    local title="OMARCHY TWEAKS"
    local subtitle="Bootstrap • Config • Automation"
    local omv
    omv="$(get_omarchy_version)"

    if [[ -f "$BANNER_FILE" ]]; then
        gum style \
            --border double \
            --border-foreground 5 \
            --foreground 6 \
            --bold \
            --align center \
            --width 130 \
            --padding "1 3" \
            "$(cat -- "$BANNER_FILE")"
    else
        gum style \
            --border double \
            --border-foreground 5 \
            --foreground 5 \
            --bold \
            --align center \
            --width 130 \
            --padding "1 3" \
            "${NF_ROCKET}  ${title}
            ${subtitle}"
    fi

    printf '\n'

    gum style \
        --foreground 5 \
        --align center \
        --width 130 \
        --padding "0 1" \
        "${NF_CODE}  Author: ${AUTHOR}     ${NF_CHECK}  Version: ${VERSION}"

    gum style \
        --foreground 5 \
        --align center \
        --width 130 \
        --padding "0 1" \
        "${NF_LINK}  Git: ${URL}"

    printf '\n'

    gum style \
        --border rounded \
        --border-foreground 8 \
        --foreground 8 \
        --align center \
        --width 130 \
        --padding "0 1" \
        "${NF_CPU}  Omarchy: ${omv}     ${NF_FOLDER}  Project: ${PROJECT_DIR}"

    printf '\n'
}

# ======================================================= #
# Snapshot
# ======================================================= #

snapshot() {
    section "System Snapshot ${NF_SHIELD}"
    msg_info "Create a Btrfs/Snapper snapshot before changes"
    printf '\n'

    confirm "Create a system snapshot now?" true || {
        msg_warning "Snapshot skipped"
        return 0
    }

    local name=""
    local desc=""
    local snap_id
    snap_id="$(date +%Y-%m-%d_%H:%M:%S)"

    if confirm "Add a custom snapshot name?" false; then
        name="$(gum input --placeholder "Snapshot name (optional)")" || name=""
    fi

    if confirm "Add a snapshot description?" false; then
        desc="$(gum input --placeholder "Description (optional)")" || desc=""
    fi

    local snap_desc="$snap_id"
    if [[ -n "$name" && -n "$desc" ]]; then
        snap_desc="$snap_id - $name: $desc"
    elif [[ -n "$name" ]]; then
        snap_desc="$snap_id - $name"
    elif [[ -n "$desc" ]]; then
        snap_desc="$snap_id - $desc"
    fi

    if run_spinner "${NF_DATABASE}  Creating snapshot..." snapper create --description "$snap_desc"; then
        msg_success "Snapshot created: $snap_desc"
        return 0
    else
        msg_error "Failed to create snapshot"
        return 1
    fi
}

# ======================================================= #
# Cleanup
# ======================================================= #

remove_packages() {
    section "Remove Bloatware Packages ${NF_PACKAGE}"
    confirm "Remove preinstalled bloatware packages?" true || {
        msg_warning "Package removal skipped"
        return 0
    }

    local -a remove_cmd=()
    if is_root; then
        remove_cmd=(pacman -Rns --noconfirm)
    elif has_sudo; then
        remove_cmd=(sudo pacman -Rns --noconfirm)
    else
        msg_error "Root/sudo required to remove packages"
        return 1
    fi

    local -a installed=()
    local pkg
    for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
        if pacman -Qq "$pkg" >/dev/null 2>&1; then
            installed+=("$pkg")
        fi
    done

    (( ${#installed[@]} > 0 )) || {
        msg_warning "No bloatware packages found"
        return 0
    }

    local selected
    selected="$(select_multiple "${NF_GEAR}  Select packages to remove (space=select, enter=confirm)" "${installed[@]}")" || {
        msg_warning "Selection cancelled"
        return 0
    }

    local -a to_remove=()
    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] || continue
        to_remove+=("$pkg")
    done <<< "$selected"

    (( ${#to_remove[@]} > 0 )) || {
        msg_warning "No packages selected"
        return 0
    }

    local output
    if output="$("${remove_cmd[@]}" "${to_remove[@]}" 2>&1)"; then
        msg_success "Removed: ${to_remove[*]}"
        return 0
    else
        msg_error "Failed to remove packages"
        printf '%s\n' "$output" >&2
        return 1
    fi
}

remove_tui() {
    local app_dir="${1:-$HOME/.local/share/applications}"
    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    local old_icon_dir="$HOME/.local/share/applications/icons"

    section "Remove Preinstalled TUIs ${NF_TERMINAL}"
    confirm "Remove preinstalled TUI .desktop entries?" true || {
        msg_warning "TUI removal skipped"
        return 0
    }

    local -a tui_files=() tui_names=() choices=()
    local file app_name
    while IFS= read -r -d '' file; do
        if grep -qF 'Exec=xdg-terminal-exec --app-id=TUI.' "$file" 2>/dev/null; then
            app_name="$(basename "$file" .desktop)"
            tui_files+=("$file")
            tui_names+=("$app_name")
            choices+=("$app_name")
        fi
    done < <(find "$app_dir" -maxdepth 1 -type f -name '*.desktop' -print0 2>/dev/null)

    (( ${#choices[@]} > 0 )) || {
        msg_warning "No TUIs found"
        return 0
    }

    local selected
    selected="$(select_multiple "${NF_GEAR}  Select TUIs to remove" "${choices[@]}")" || {
        msg_warning "Selection cancelled"
        return 0
    }

    local -a to_remove=()
    while IFS= read -r app_name; do
        [[ -n "$app_name" ]] || continue
        to_remove+=("$app_name")
    done <<< "$selected"

    (( ${#to_remove[@]} > 0 )) || {
        msg_warning "No TUIs selected"
        return 0
    }

    local i icon_name output
    for app_name in "${to_remove[@]}"; do
        for i in "${!tui_names[@]}"; do
            [[ "${tui_names[$i]}" == "$app_name" ]] || continue
            icon_name="$(slugify "$app_name")"
            output="$(rm -f -- \
                "${tui_files[$i]}" \
                "$icon_dir/${icon_name}.png" \
                "$old_icon_dir/${icon_name}.png" 2>&1)" || true
            msg_success "Removed TUI: $app_name"
            break
        done
    done
}

remove_webapps() {
    local app_dir="${1:-$HOME/.local/share/applications}"
    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    local old_icon_dir="$HOME/.local/share/applications/icons"

    section "Remove Preinstalled WebApps ${NF_CLOUD}"
    confirm "Remove preinstalled WebApp .desktop entries?" true || {
        msg_warning "WebApp removal skipped"
        return 0
    }

    local -a web_files=() web_names=() choices=()
    local file app_name
    while IFS= read -r -d '' file; do
        if grep -Eq 'Exec=(omarchy-launch-webapp|omarchy-webapp-handler)' "$file" 2>/dev/null; then
            app_name="$(basename "$file" .desktop)"
            web_files+=("$file")
            web_names+=("$app_name")
            choices+=("$app_name")
        fi
    done < <(find "$app_dir" -maxdepth 1 -type f -name '*.desktop' -print0 2>/dev/null)

    (( ${#choices[@]} > 0 )) || {
        msg_warning "No web apps found"
        return 0
    }

    local selected
    selected="$(select_multiple "${NF_GEAR}  Select WebApps to remove" "${choices[@]}")" || {
        msg_warning "Selection cancelled"
        return 0
    }

    local -a to_remove=()
    while IFS= read -r name; do
        [[ -n "$name" ]] || continue
        to_remove+=("$name")
    done <<< "$selected"

    (( ${#to_remove[@]} > 0 )) || {
        msg_warning "No WebApps selected"
        return 0
    }

    local i icon_name
    for name in "${to_remove[@]}"; do
        for i in "${!web_names[@]}"; do
            [[ "${web_names[$i]}" == "$name" ]] || continue
            icon_name="$(slugify "$name")"
            rm -f -- "${web_files[$i]}" "$icon_dir/${icon_name}.png" "$old_icon_dir/${icon_name}.png" 2>/dev/null || true
            msg_success "Removed WebApp: $name"
            break
        done
    done
}

remove_mise() {
    section "Replace MISE Config & Remove Binaries ${NF_BOLT}"
    confirm "Replace MISE config with repo config and remove specified binaries?" true || {
        msg_warning "MISE cleanup skipped"
        return 0
    }

    local mise_config="$HOME/.config/mise/config.toml"
    ensure_dir "$(dirname -- "$mise_config")"

    if [[ -e "$mise_config" || -L "$mise_config" ]]; then
        backup_path "$mise_config" || return 1
        msg_info "Backed up existing mise config"
    fi

    symlink_or_backup "$PROJECT_DIR/config/mise.toml" "$mise_config" || return 1

    if (( ${#MISE[@]} == 0 )); then
        msg_warning "No MISE binaries listed"
        return 0
    fi

    shopt -s nullglob
    local removed=0
    for b in "${MISE[@]}"; do
        if [[ -e "$b" || -L "$b" ]]; then
            rm -rf -- "$b" 2>/dev/null && ((removed++)) && msg_debug "Removed: $b"
        fi
    done
    shopt -u nullglob
    msg_success "MISE binaries processed ($removed removed)"

    if confirm "Update mise now?" true; then
        if command -v mise >/dev/null 2>&1; then
            mise update 2>/dev/null && msg_success "mise updated" || msg_warning "mise update failed"
        else
            msg_warning "mise not found in PATH"
        fi
    fi
}

# ======================================================= #
# Installers
# ======================================================= #

install_pacman_packages() {
    section "Install Pacman Packages ${NF_PACKAGE}"
    confirm "Install missing Pacman packages?" true || {
        msg_warning "Pacman install skipped"
        return 0
    }

    require_cmd pacman "pacman" || return 1
    local -a cmd=()
    if is_root; then
        cmd=(pacman -S --noconfirm)
    elif has_sudo; then
        cmd=(sudo pacman -S --noconfirm)
    else
        msg_error "Root/sudo required for pacman"
        return 1
    fi

    local pkg
    for pkg in "${PACMAN_PACKAGES[@]}"; do
        if pacman -Qq "$pkg" >/dev/null 2>&1; then
            msg_debug "Already installed: $pkg"
            continue
        fi
        confirm "Install '$pkg'?" true || {
            msg_warning "Skipped: $pkg"
            continue
        }
        if "${cmd[@]}" "$pkg" >/dev/null 2>&1; then
            msg_success "Installed: $pkg"
        else
            msg_error "Failed: $pkg"
        fi
    done
}

install_aur_packages() {
    section "Install AUR Packages ${NF_SPARKLE}"
    confirm "Install missing AUR packages?" true || {
        msg_warning "AUR install skipped"
        return 0
    }

    local helper=""
    for h in yay paru paccache aurman trizen; do
        if command -v "$h" >/dev/null 2>&1; then
            helper="$h"
            break
        fi
    done
    [[ -n "$helper" ]] || {
        msg_error "No AUR helper found (yay/paru/etc.)"
        return 1
    }

    local -a cmd=("$helper" -S --noconfirm)
    if is_root; then
        msg_warning "Running AUR helper as root is not recommended; proceeding if allowed"
    fi

    local pkg
    for pkg in "${AUR_PACKAGES[@]}"; do
        if pacman -Qq "$pkg" >/dev/null 2>&1; then
            msg_debug "Already installed: $pkg"
            continue
        fi
        confirm "Install AUR '$pkg'?" true || {
            msg_warning "Skipped: $pkg"
            continue
        }
        if "${cmd[@]}" "$pkg" >/dev/null 2>&1; then
            msg_success "Installed AUR: $pkg"
        else
            msg_error "Failed AUR: $pkg"
        fi
    done
}

# ======================================================= #
# WebApps
# ======================================================= #

install_webapps() {
    section "Install WebApps ${NF_DESKTOP}"
    local app_dir="$HOME/.local/share/applications"
    ensure_dir "$app_dir"

    confirm "Install all preconfigured WebApps?" true || {
        msg_warning "WebApp install skipped"
        return 0
    }

    require_cmd omarchy-webapp-install "omarchy-webapp-install" || return 1

    local failed=0 entry app_name app_url icon_file icon_path
    for entry in "${WEBAPPS[@]}"; do
        IFS='|' read -r app_name app_url icon_file <<< "$entry"
        [[ -n "$app_name" && -n "$app_url" ]] || {
            msg_warning "Invalid WebApp entry: $entry"
            ((failed++))
            continue
        }

        msg_info "Installing: $app_name"
        if [[ "$app_name" == "CyberChef" ]]; then
            local cyberchef_desktop="$PROJECT_DIR/config/cyberchef.desktop"
            if [[ ! -f "$cyberchef_desktop" ]]; then
                msg_error "Missing: $cyberchef_desktop"
                ((failed++))
                continue
            fi
            symlink_or_backup "$cyberchef_desktop" "$app_dir/cyberchef.desktop" || ((failed++))
            continue
        fi

        icon_path=""
        if [[ -n "$icon_file" ]]; then
            icon_path="$PROJECT_DIR/assets/$icon_file"
            if [[ ! -f "$icon_path" ]]; then
                msg_error "Icon missing for $app_name: $icon_path"
                ((failed++))
                continue
            fi
        fi

        local out
        if out="$(omarchy-webapp-install "$app_name" "$app_url" "$icon_path" 2>&1)"; then
            msg_success "Installed: $app_name"
        else
            msg_error "Failed: $app_name"
            printf '%s\n' "$out" >&2
            ((failed++))
        fi
    done

    (( failed == 0 )) || {
        msg_warning "Some WebApps failed ($failed)"
        return 1
    }
    msg_success "All WebApps installed"
}

# ======================================================= #
# Omarchy Plugins
# ======================================================= #

install_plugins() {
    section "Install Omarchy Plugins ${NF_STAR}"
    local total=${#OMARCHY_PLUGINS[@]}
    (( total > 0 )) || { msg_warning "No plugins defined"; return 0; }

    msg_info "${total} plugins available"
    confirm "Install all Omarchy plugins?" true || {
        msg_warning "Plugin install skipped"
        return 0
    }

    require_cmd omarchy-plugin-add "omarchy-plugin-add" || return 1

    local idx=0 ok=0 fail=0
    local plugin_name plugin_url plugin_desc
    for p in "${OMARCHY_PLUGINS[@]}"; do
        IFS='|' read -r plugin_name plugin_url plugin_desc <<< "$p"
        [[ -n "$plugin_name" && -n "$plugin_url" ]] || continue
        ((idx++))

        local title="${idx}/${total}  ${plugin_name}"
        [[ -n "$plugin_desc" ]] && title+=" — ${plugin_desc}"

        if run_spinner "$title" omarchy-plugin-add "$plugin_url"; then
            ((ok++))
            gum style --foreground "#a6e3a1" --bold --padding "0 2" "✓  ${plugin_name}"
        else
            ((fail++))
            gum style --foreground "#f38ba8" --bold --padding "0 2" "✗  ${plugin_name}"
        fi
    done

    printf '\n'
    if (( fail == 0 )); then
        gum style --foreground "#a6e3a1" --bold --border rounded --border-foreground "#a6e3a1" --padding "1 2" "✓  All ${total} plugins installed"
    elif (( ok == 0 )); then
        gum style --foreground "#f38ba8" --bold --border rounded --border-foreground "#f38ba8" --padding "1 2" "✗  All failed"
    else
        gum style --foreground "#f9e2af" --bold --border rounded --border-foreground "#f9e2af" --padding "1 2" "✓  ${ok} · ✗  ${fail} · ${total} total"
    fi
    printf '\n'
    (( fail == 0 ))
}

# ======================================================= #
# Ollama
# ======================================================= #

install_ollama_models() {
    section "Ollama & Models ${NF_FIRE}"
    confirm "Install Ollama (if missing) and download models?" true || {
        msg_warning "Ollama setup skipped"
        return 0
    }

    if ! command -v ollama >/dev/null 2>&1; then
        confirm "ollama not found. Install via official script?" true || {
            msg_warning "Ollama install skipped"
            return 1
        }
        if run_spinner "${NF_SERVER}  Installing Ollama..." bash -c 'curl -fsSL https://ollama.com/install.sh | sh'; then
            msg_success "Ollama installed"
        else
            msg_error "Ollama install failed"
            return 1
        fi
    else
        msg_info "ollama already present"
    fi

    local model
    for model in "${OLLAMA_MODELS[@]}"; do
        confirm "Download model '$model'?" true || {
            msg_warning "Skipped: $model"
            continue
        }
        if run_spinner "${NF_DATABASE}  Pulling $model..." ollama pull "$model"; then
            msg_success "Downloaded: $model"
        else
            msg_error "Failed: $model"
        fi
    done
}

# ======================================================= #
# AI Configs (Claude/OpenCode/Codex)
# ======================================================= #

setup_claude() {
    section "Claude Code Setup ${NF_CODE}"
    confirm "Setup Claude Code config + omniroute?" true || {
        msg_warning "Claude setup skipped"
        return 0
    }

    local dst="$HOME/.claude"
    local src_cfg="$PROJECT_DIR/config/claude/settings.json"
    ensure_dir "$dst"

    if [[ -s "$dst/settings.json" ]]; then
        backup_path "$dst/settings.json" || return 1
    fi
    if [[ -s "$src_cfg" ]]; then
        symlink_or_backup "$src_cfg" "$dst/settings.json" || return 1
        require_cmd omniroute "omniroute" || return 1
        if run_spinner "${NF_LINK}  Running omniroute setup-claude..." omniroute setup-claude; then
            msg_success "omniroute setup-claude done"
        else
            msg_error "omniroute setup-claude failed"
            return 1
        fi
    else
        msg_warning "Missing: $src_cfg"
    fi
}

setup_opencode() {
    section "OpenCode Setup ${NF_CODE}"
    confirm "Setup OpenCode config + omniroute?" true || {
        msg_warning "OpenCode setup skipped"
        return 0
    }

    local dst="$HOME/.config/opencode"
    local src_cfg="$PROJECT_DIR/config/opencode/opencode.json"
    ensure_dir "$dst"

    if [[ -s "$dst/opencode.json" ]]; then
        backup_path "$dst/opencode.json" || return 1
    fi
    if [[ -s "$src_cfg" ]]; then
        symlink_or_backup "$src_cfg" "$dst/opencode.json" || return 1
        require_cmd omniroute "omniroute" || return 1
        if run_spinner "${NF_LINK}  Running omniroute setup-opencode..." omniroute setup-opencode; then
            msg_success "omniroute setup-opencode done"
        else
            msg_error "omniroute setup-opencode failed"
            return 1
        fi
    else
        msg_warning "Missing: $src_cfg"
    fi
}

setup_codex() {
    section "Codex Setup ${NF_CODE}"
    confirm "Setup Codex config + omniroute?" true || {
        msg_warning "Codex setup skipped"
        return 0
    }

    local dst="$HOME/.codex"
    local src_cfg="$PROJECT_DIR/config/codex/config.toml"
    ensure_dir "$dst"

    if [[ -s "$dst/config.toml" ]]; then
        backup_path "$dst/config.toml" || return 1
    fi
    if [[ -s "$src_cfg" ]]; then
        symlink_or_backup "$src_cfg" "$dst/config.toml" || return 1
        require_cmd omniroute "omniroute" || return 1
        if run_spinner "${NF_LINK}  Running omniroute setup-codex..." omniroute setup-codex; then
            msg_success "omniroute setup-codex done"
        else
            msg_error "omniroute setup-codex failed"
            return 1
        fi
    else
        msg_warning "Missing: $src_cfg"
    fi
}

install_omniroute() {
    section "Omniroute ${NF_LAUNCH}"
    confirm "Install omniroute globally (npm)?" true || {
        msg_warning "Omniroute install skipped"
        return 0
    }
    require_cmd npm "npm" || return 1
    if run_spinner "${NF_BOX}  Installing omniroute..." npm install -g omniroute; then
        msg_success "omniroute installed"
    else
        msg_error "omniroute install failed"
        return 1
    fi
}

# ======================================================= #
# Docker Containers
# ======================================================= #

setup_docker_containers() {
    section "Docker Containers ${NF_SERVER}"
    require_cmd docker "docker" || return 1

    local dc=""
    if command -v docker-compose >/dev/null 2>&1; then
        dc="docker-compose"
    elif docker compose version >/dev/null 2>&1; then
        dc="docker compose"
    else
        msg_error "docker-compose or 'docker compose' not found"
        return 1
    fi
    msg_debug "Using: $dc"

    local atuin_ai="$PROJECT_DIR/containers/atuin"
    local open_webui="$PROJECT_DIR/containers/open-webui"
    local outline="$PROJECT_DIR/containers/outline"
    local snapotter="$PROJECT_DIR/containers/snapotter"

    # Atuin
    confirm "Setup Atuin-AI container?" true || { msg_warning "Atuin-AI skipped"; }
    if confirm "Setup Atuin-AI container?" true 2>/dev/null; then
        true
    fi
    # simpler: run if confirmed
    if confirm "Setup Atuin-AI container?" true; then
        [[ -d "$atuin_ai" ]] || { msg_error "Missing: $atuin_ai"; return 1; }
        local cfg="$HOME/.config/atuin-ai-server"
        ensure_dir "$cfg"
        [[ -s "$cfg/config.toml" ]] && backup_path "$cfg/config.toml"
        symlink_or_backup "$PROJECT_DIR/config/atuin-ai-server.toml" "$cfg/config.toml" || return 1
        if run_spinner "${NF_SERVER}  Starting atuin-ai..." $dc -f "$atuin_ai/docker-compose.yml" up -d; then
            msg_success "Atuin-AI up"
        else
            msg_error "Atuin-AI failed"
            return 1
        fi
    fi

    if confirm "Setup Open-WebUI container?" true; then
        [[ -d "$open_webui" ]] || { msg_error "Missing: $open_webui"; return 1; }
        if run_spinner "${NF_SERVER}  Starting open-webui..." $dc -f "$open_webui/docker-compose.yml" up -d; then
            msg_success "Open-WebUI up"
        else
            msg_error "Open-WebUI failed"
            return 1
        fi
    fi

    if confirm "Setup Outline container?" false; then
        [[ -d "$outline" ]] || { msg_error "Missing: $outline"; return 1; }
        if run_spinner "${NF_SERVER}  Starting outline..." $dc -f "$outline/docker-compose.yml" up -d; then
            msg_success "Outline up"
        else
            msg_error "Outline failed"
            return 1
        fi
    fi

    if confirm "Setup Snapotter container?" false; then
        [[ -d "$snapotter" ]] || { msg_error "Missing: $snapotter"; return 1; }
        if run_spinner "${NF_SERVER}  Starting snapotter..." $dc -f "$snapotter/docker-compose.yml" up -d; then
            msg_success "Snapotter up"
        else
            msg_error "Snapotter failed"
            return 1
        fi
    fi
}

# ======================================================= #
# Directories & Bins & Scripts
# ======================================================= #

create_dirs() {
    section "Create Directories ${NF_FOLDER}"
    local dirs=("$HOME_DIR/Github" "$HOME_DIR/Projects" "$HOME_DIR/.ISO" "$HOME_DIR/.VM")
    local d
    for d in "${dirs[@]}"; do
        if [[ -d "$d" ]]; then
            msg_info "Exists: $d"
            continue
        fi
        confirm "Create '$d'?" true || {
            msg_warning "Skipped: $d"
            continue
        }
        ensure_dir "$d" && msg_success "Created: $d" || msg_error "Failed: $d"
    done
}

setup_custom_bin() {
    section "Custom Bin Symlinks ${NF_TERMINAL}"
    local custom_bin="$PROJECT_DIR/bin"
    [[ -d "$custom_bin" ]] || { msg_error "Missing: $custom_bin"; return 1; }
    ensure_dir "$HOME_DIR/.local/bin"

    confirm "Symlink all files from bin/ to ~/.local/bin/?" true || {
        msg_warning "Custom bin skipped"
        return 0
    }

    shopt -s nullglob
    local f linked=0
    for f in "$custom_bin"/*; do
        [[ -f "$f" ]] || continue
        local base
        base="$(basename -- "$f")"
        local dst="$HOME_DIR/.local/bin/$base"
        if [[ -e "$dst" || -L "$dst" ]]; then
            backup_path "$dst" || continue
        fi
        if ln -sf -- "$f" "$dst"; then
            ((linked++))
            msg_debug "Linked: $base"
        else
            msg_error "Failed: $base"
        fi
    done
    shopt -u nullglob
    chmod +x "$HOME_DIR/.local/bin"/* 2>/dev/null || true
    msg_success "Custom bin linked ($linked files)"
}

setup_omarchy_overwrites() {
    section "Omarchy Script Overwrites ${NF_SETTINGS}"
    local custom_scripts="$PROJECT_DIR/scripts"
    [[ -d "$custom_scripts" ]] || { msg_error "Missing: $custom_scripts"; return 1; }

    ensure_dir "$OMARCHY_BIN"

    confirm "Overwrite Omarchy system scripts with custom versions?" true || {
        msg_warning "Omarchy overwrites skipped"
        return 0
    }

    local sudo_arr=()
    if ! is_root && has_sudo; then
        sudo_arr=(sudo)
    elif ! is_root; then
        msg_error "Root/sudo required to write to $OMARCHY_BIN"
        return 1
    fi

    local pairs=(
        "omarchy-snapshot|omarchy-snapshot|ln"
        "omarchy-windows-vm|omarchy-windows-vm|install"
        "omarchy-macos-vm|omarchy-macos-vm|install"
        "omarchy-setup-security-fingerprint|omarchy-fingerprint-setup|ln"
    )
    local p src dst mode
    for p in "${pairs[@]}"; do
        IFS='|' read -r src dst mode <<< "$p"
        local csrc="$custom_scripts/$src"
        local cdst="$OMARCHY_BIN/$dst"
        [[ -f "$csrc" ]] || {
            msg_warning "Custom script missing: $csrc"
            continue
        }
        if [[ -e "$cdst" || -L "$cdst" ]]; then
            if is_root || has_sudo; then
                "${sudo_arr[@]}" /usr/bin/mv -- "$cdst" "${cdst}.bak" 2>/dev/null || true
            else
                backup_path "$cdst" 2>/dev/null || true
            fi
        fi
        if [[ "$mode" == "install" ]]; then
            if "${sudo_arr[@]}" install -Dm755 -- "$csrc" "$cdst"; then
                msg_success "Installed: $dst"
            else
                msg_error "Failed install: $dst"
            fi
        else
            if "${sudo_arr[@]}" ln -sf -- "$csrc" "$cdst"; then
                msg_success "Symlinked: $dst"
            else
                msg_error "Failed symlink: $dst"
            fi
        fi
    done
}


# ======================================================= #
# Dotfiles (Git, global hooks, etc.)
# ======================================================= #

setup_dotfiles() {
    section "Dotfiles Setup ${NF_SETTINGS}"
    local dotfiles_dir="$PROJECT_DIR/dotfiles"
    [[ -d "$dotfiles_dir" ]] || {
        msg_warning "Dotfiles directory not found: $dotfiles_dir"
        return 0
    }

    # Git config
    if confirm "Setup global git config (~/.config/git/config)?" false; then
        local src="$dotfiles_dir/git/config"
        local dst="$HOME/.config/git/config"

        # Check missing dependencies
        command_exists delta || msg_warning "Missing: delta (git diff pager)"
        command_exists gpg || msg_warning "Missing: gpg (for signing commits)"
        command_exists code || msg_warning "Missing: code (VSCode editor)"
        command_exists nvim || msg_warning "Missing: nvim (Neovim editor)"
        command_exists git-lfs || msg_warning "Missing: git-lfs (for large files)"

        [[ -f "$src" ]] || { msg_warning "Missing: $src"; return 0; }
        ensure_dir "$(dirname -- "$dst")"
        [[ -e "$dst" || -L "$dst" ]] && backup_path "$dst"
        if symlink_or_backup "$src" "$dst"; then
            msg_success "Git config linked"
        else
            msg_error "Failed to link git config"
        fi
    else
        msg_warning "Git config setup skipped"
    fi

    msg_info "Dotfiles setup complete (only items you confirmed were applied)"
}

# ======================================================= #
# Menu
# ======================================================= #

show_menu() {
    clear
    banner

    gum style \
        --foreground "#cba6f7" \
        --bold \
        --border rounded \
        --border-foreground "#cba6f7" \
        --padding "1 2" \
        "${NF_LIST}  INTERACTIVE MENU"

    printf '\n'

    local choice
    choice="$(gum choose \
        --header "${NF_GEAR}  Select action (Enter to run)" \
        --cursor="${NF_ARROW} " \
        --selected-prefix="${NF_CHECK} " \
        --unselected-prefix="  " \
        "1. Full Bootstrap (All)" \
        "2. System Snapshot" \
        "3. Cleanup: Bloat/TUIs/WebApps/MISE" \
        "4. Packages: Pacman + AUR" \
        "5. Install: WebApps" \
        "6. Install: Omarchy Plugins" \
        "7. Ollama: Install + Models" \
        "8. AI: Claude Setup" \
        "9. AI: OpenCode Setup" \
        "10. AI: Codex Setup" \
        "11. Omniroute: Install" \
        "12. Containers: Setup (Atuin/OpenWebUI/Outline/SnapOtter)" \
        "13. Directories: Create (Github/Projects/.ISO/.VM)" \
        "14. Bins: Symlink custom bin/" \
        "15. Dotfiles: Setup (Git/config/hooks)" \
        "16. Omarchy: Overwrite system scripts" \
        "17. View bootstrap.log" \
        "18. Show Version" \
        "19. Toggle Debug (current: ${DEBUG})" \
        "0. Exit")" || return 1

    case "$choice" in
        *"1. Full"*) run_full ;;
        *"2. System"*) snapshot; pause ;;
        *"3. Cleanup"*)
            remove_packages; remove_tui; remove_webapps; remove_mise; pause
            ;;
        *"4. Packages"*)
            install_pacman_packages; install_aur_packages; pause
            ;;
        *"5. Install: WebApps"*) install_webapps; pause ;;
        *"6. Install: Omarchy Plugins"*) install_plugins; pause ;;
        *"7. Ollama"*) install_ollama_models; pause ;;
        *"8. AI: Claude"*) setup_claude; pause ;;
        *"9. AI: OpenCode"*) setup_opencode; pause ;;
        *"10. AI: Codex"*) setup_codex; pause ;;
        *"11. Omniroute"*) install_omniroute; pause ;;
        *"12. Containers"*) setup_docker_containers; pause ;;
        *"13. Directories"*) create_dirs; pause ;;
        *"14. Bins"*) setup_custom_bin; pause ;;
        *"15. Dotfiles"*) setup_dotfiles; pause ;;
        *"16. Omarchy"*) setup_omarchy_overwrites; pause ;;
        *"17. View"*)
            if [[ -f "$LOG_FILE" ]]; then
                less -R "$LOG_FILE" 2>/dev/null || cat "$LOG_FILE"
            else
                msg_warning "Log file not found: $LOG_FILE"
            fi
            pause
            ;;
        *"18. Show"*)
            printf '\n%s %s\n' "$SCRIPT_NAME" "$VERSION"
            pause
            ;;
        *"19. Toggle"*)
            if (( DEBUG == 0 )); then
                DEBUG=1
                trap '__debug_trace' DEBUG
                msg_success "Debug enabled"
            else
                DEBUG=0
                trap - DEBUG
                msg_info "Debug disabled"
            fi
            pause
            ;;
        *"0. Exit"*) exit 0 ;;
        *) msg_warning "Invalid choice" ;;
    esac

    show_menu
}

main_menu() {
    while true; do
        show_menu || break
    done
}

# ======================================================= #
# Full Bootstrap Flow
# ======================================================= #

run_full() {
    banner
    init_logger || { msg_error "Logger init failed"; return 1; }
    check_dependencies || return 1

    snapshot || { msg_error "Snapshot step failed"; return 1; }

    section "Cleanup"
    remove_packages
    remove_tui
    remove_webapps
    remove_mise
    pause "Continue to directories?" || return 1

    banner
    section "Directories"
    create_dirs
    pause "Continue to package installs?" || return 1

    banner
    section "Packages"
    install_pacman_packages || msg_warning "Some pacman packages had issues"
    install_aur_packages || msg_warning "Some AUR packages had issues"
    pause "Continue to WebApps?" || return 1

    banner
    section "WebApps & Plugins"
    install_webapps || msg_warning "Some WebApps had issues"
    install_plugins || msg_warning "Some plugins had issues"
    pause "Continue to AI tools?" || return 1

    banner
    section "AI Tools"
    install_ollama_models || msg_warning "Ollama/models had issues"
    install_omniroute || msg_warning "Omniroute had issues"
    setup_claude || msg_warning "Claude setup had issues"
    setup_opencode || msg_warning "OpenCode setup had issues"
    setup_codex || msg_warning "Codex setup had issues"
    pause "Continue to containers?" || return 1

    banner
    section "Containers & Customizations"
    setup_docker_containers || msg_warning "Containers had issues"
    setup_custom_bin || msg_warning "Custom bin had issues"
    setup_omarchy_overwrites || msg_warning "Omarchy overwrites had issues"

    banner
    printf '\n'
    gum style \
        --foreground "#a6e3a1" \
        --bold \
        --border double \
        --border-foreground "#a6e3a1" \
        --padding "1 2" \
        "${NF_CHECK}  BOOTSTRAP COMPLETE"
    printf '\n'
    msg_info "Logs: $LOG_FILE"
    msg_info "Project: $PROJECT_DIR"
    pause "Done"
}

# ======================================================= #
# Main
# ======================================================= #

main() {
    shopt -s nullglob extglob
    parse_arguments "$@"

    if [[ "${BOOTSTRAP_SHOW_MENU:-0}" == "1" ]]; then
        main_menu
        exit 0
    fi

    run_full
}

main "$@"
