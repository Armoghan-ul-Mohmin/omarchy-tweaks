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
VERSION="1.0.1"
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
NF_PATCH="󰁨"

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
    "rclone"
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
    "Omarchy Key Prompter |https://github.com/ForrestKnight/omarchy-key-promoter.git|Shows the keyboard shortcut whenever you reach for the menu instead."
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
            if rm -rf -- "$b" 2>/dev/null; then
                ((++removed))
                msg_debug "Removed: $b"
            fi
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
            ((++failed))
            continue
        }

        msg_info "Installing: $app_name"
        if [[ "$app_name" == "CyberChef" ]]; then
            local cyberchef_desktop="$PROJECT_DIR/config/cyberchef.desktop"
            if [[ ! -f "$cyberchef_desktop" ]]; then
                msg_error "Missing: $cyberchef_desktop"
                ((++failed))
                continue
            fi
            symlink_or_backup "$cyberchef_desktop" "$app_dir/cyberchef.desktop" || ((++failed))
            continue
        fi

        icon_path=""
        if [[ -n "$icon_file" ]]; then
            icon_path="$PROJECT_DIR/assets/$icon_file"
            if [[ ! -f "$icon_path" ]]; then
                msg_error "Icon missing for $app_name: $icon_path"
                ((++failed))
                continue
            fi
        fi

        local out
        if out="$(omarchy-webapp-install "$app_name" "$app_url" "$icon_path" 2>&1)"; then
            msg_success "Installed: $app_name"
        else
            msg_error "Failed: $app_name"
            printf '%s\n' "$out" >&2
            ((++failed))
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
        ((++idx))

        local title="${idx}/${total}  ${plugin_name}"
        [[ -n "$plugin_desc" ]] && title+=" — ${plugin_desc}"

        if run_spinner "$title" omarchy-plugin-add "$plugin_url"; then
            ((++ok))
            gum style --foreground "#a6e3a1" --bold --padding "0 2" "✓  ${plugin_name}"
        else
            ((++fail))
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
        require_cmd curl "curl" || return 1
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

    local -a dc=()
    if command -v docker-compose >/dev/null 2>&1; then
        dc=(docker-compose)
    elif docker compose version >/dev/null 2>&1; then
        dc=(docker compose)
    else
        msg_error "docker-compose or 'docker compose' not found"
        return 1
    fi
    msg_debug "Using: ${dc[*]}"

    local atuin_ai="$PROJECT_DIR/containers/atuin"
    local open_webui="$PROJECT_DIR/containers/open-webui"
    local outline="$PROJECT_DIR/containers/outline"
    local snapotter="$PROJECT_DIR/containers/snapotter"

    # Atuin-AI
    if confirm "Setup Atuin-AI container?" true; then
        if [[ ! -d "$atuin_ai" ]]; then
            msg_warning "Missing: $atuin_ai (skipped)"
        else
            local cfg="$HOME/.config/atuin-ai-server"
            ensure_dir "$cfg"
            [[ -s "$cfg/config.toml" ]] && backup_path "$cfg/config.toml"
            if symlink_or_backup "$PROJECT_DIR/config/atuin-ai-server.toml" "$cfg/config.toml"; then
                if run_spinner "${NF_SERVER}  Starting atuin-ai..." "${dc[@]}" -f "$atuin_ai/docker-compose.yml" up -d; then
                    msg_success "Atuin-AI up"
                else
                    msg_error "Atuin-AI failed"
                fi
            fi
        fi
    fi

    # Open-WebUI
    if confirm "Setup Open-WebUI container?" true; then
        if [[ ! -d "$open_webui" ]]; then
            msg_warning "Missing: $open_webui (skipped)"
        elif run_spinner "${NF_SERVER}  Starting open-webui..." "${dc[@]}" -f "$open_webui/docker-compose.yml" up -d; then
            msg_success "Open-WebUI up"
        else
            msg_error "Open-WebUI failed"
        fi
    fi

    # Outline
    if confirm "Setup Outline container?" false; then
        if [[ ! -d "$outline" ]]; then
            msg_warning "Missing: $outline (skipped)"
        elif run_spinner "${NF_SERVER}  Starting outline..." "${dc[@]}" -f "$outline/docker-compose.yml" up -d; then
            msg_success "Outline up"
        else
            msg_error "Outline failed"
        fi
    fi

    # SnapOtter
    if confirm "Setup Snapotter container?" false; then
        if [[ ! -d "$snapotter" ]]; then
            msg_warning "Missing: $snapotter (skipped)"
        elif run_spinner "${NF_SERVER}  Starting snapotter..." "${dc[@]}" -f "$snapotter/docker-compose.yml" up -d; then
            msg_success "Snapotter up"
        else
            msg_error "Snapotter failed"
        fi
    fi

    # Start Docker at boot
    if confirm "Enable Docker service to start at boot?" true; then
        if run_spinner "${NF_SERVER}  Enabling Docker service..." sudo systemctl enable docker; then
            msg_success "Docker service enabled"
        else
            msg_error "Failed to enable Docker service"
        fi
    fi
}

# ======================================================= #
# Directories & Bins & Scripts
# ======================================================= #

create_dirs() {
    section "Create Directories ${NF_FOLDER}"
    local dirs=("$HOME_DIR/Github" "$HOME_DIR/Github/Clone" "$HOME_DIR/Projects" "$HOME_DIR/.ISO" "$HOME_DIR/.VM")
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
# Bins (symlink bin/* into ~/.local/bin)
# ======================================================= #

setup_bins() {
    section "Custom Bin Utilities ${NF_TERMINAL}"
    local src_dir="$PROJECT_DIR/bin"
    local dst_dir="$HOME/.local/bin"

    [[ -d "$src_dir" ]] || { msg_warning "Missing: $src_dir"; return 0; }

    confirm "Symlink custom utilities from bin/ into ~/.local/bin?" true || {
        msg_warning "Bin symlink skipped"
        return 0
    }

    ensure_dir "$dst_dir"

    shopt -s nullglob
    local -a scripts=("$src_dir"/*)
    shopt -u nullglob

    (( ${#scripts[@]} > 0 )) || { msg_warning "No utilities found in $src_dir"; return 0; }

    local f name linked=0
    for f in "${scripts[@]}"; do
        [[ -f "$f" ]] || continue
        name="$(basename -- "$f")"
        if symlink_or_backup "$f" "$dst_dir/$name"; then
            ((++linked))
        fi
    done
    msg_success "Symlinked $linked utility(ies) into $dst_dir"
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

    # Atuin config
    if confirm "Setup Atuin config (~/.config/atuin/config.toml)?" false; then
        local src="$dotfiles_dir/atuin/config.toml"
        local dst="$HOME/.config/atuin/config.toml"
        local theme_dir="$dotfiles_dir/atuin/themes"
        local dst_theme_dir="$HOME/.config/atuin/themes"
        # Check missing dependencies
        command_exists atuin || msg_warning "Missing: atuin (shell history manager)"
        [[ -f "$src" ]] || { msg_warning "Missing: $src"; return 0; }
        ensure_dir "$(dirname -- "$dst")"
        [[ -e "$dst" || -L "$dst" ]] && backup_path "$dst"
        if symlink_or_backup "$src" "$dst"; then
            msg_success "Atuin config linked"
        else
            msg_error "Failed to link Atuin config"
        fi
        if [[ -d "$theme_dir" ]]; then
            ensure_dir "$dst_theme_dir"
            for theme_file in "$theme_dir"/*; do
                local theme_name
                theme_name="$(basename -- "$theme_file")"
                local dst_theme_file="$dst_theme_dir/$theme_name"
                [[ -e "$dst_theme_file" || -L "$dst_theme_file" ]] && backup_path "$dst_theme_file"
                if symlink_or_backup "$theme_file" "$dst_theme_file"; then
                    msg_success "Atuin theme linked: $theme_name"
                else
                    msg_error "Failed to link Atuin theme: $theme_name"
                fi
            done
        fi
    else
        msg_warning "Atuin config setup skipped"
    fi

    # Starship Config
    if confirm "Setup Starship config (~/.config/starship.toml)?" false; then
        local src="$dotfiles_dir/starship/starship.toml"
        local dst="$HOME/.config/starship.toml"
        command_exists starship || msg_warning "Missing: starship (shell prompt)"
        [[ -f "$src" ]] || { msg_warning "Missing: $src"; return 0; }
        ensure_dir "$(dirname -- "$dst")"
        [[ -e "$dst" || -L "$dst" ]] && backup_path "$dst"
        if symlink_or_backup "$src" "$dst"; then
            msg_success "Starship config linked"
        else
            msg_error "Failed to link Starship config"
        fi
    else
        msg_warning "Starship config setup skipped"
    fi

    # Zsh Config
    if confirm "Setup Zsh config (~/.zshrc)?" false; then
        local src="$dotfiles_dir/zsh/.zshrc"
        local dst="$HOME/.zshrc"
        local docs="$dotfiles_dir/docs"
        local menu_file="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"

        command_exists zsh || msg_warning "Missing: zsh (shell)"
        [[ -f "$src" ]] || { msg_warning "Missing: $src"; return 0; }
        ensure_dir "$(dirname -- "$dst")"
        [[ -e "$dst" || -L "$dst" ]] && backup_path "$dst"
        if symlink_or_backup "$src" "$dst"; then
            msg_success "Zsh config linked"
        else
            msg_error "Failed to link Zsh config"
        fi

        # ~/.omarchy-tweaks -> repo (PATH entry in 00-env.zsh + menu/docs links)
        local omarchy_tweaks_link="$HOME/.omarchy-tweaks"
        if [[ "$PROJECT_DIR" != "$omarchy_tweaks_link" ]]; then
            if symlink_or_backup "$PROJECT_DIR" "$omarchy_tweaks_link"; then
                msg_success "Linked: $omarchy_tweaks_link -> $PROJECT_DIR"
            else
                msg_warning "Failed to link: $omarchy_tweaks_link"
            fi
        fi

        # ---- Private secrets file --------------------------------------
        # A template of personal API keys and tokens, sourced LAST by .zshrc
        # so it always wins over defaults. Created once (never overwritten),
        # because it holds real credentials the user fills in by hand.
        # File mode is locked to 600 so no other user on the system can read it.
        local secrets="$HOME/.secrets.zsh"
        if [[ ! -f "$secrets" ]]; then
            if cat > "$secrets" <<'SECRETS_EOF'
# ========================================================
#  Private environment — sourced last by .zshrc
#  File permissions are set to 600: only the owner can read it.
#  Fill in the values below, then open a new shell.
# ========================================================

# -- OpenRouter (gateway used by Omniroute / AI tools) ----
# API key:     https://openrouter.ai/keys
export OPENROUTER_API_KEY="<KEY>"
# Management key: https://openrouter.ai/settings/keys
export OPENROUTER_MANAGEMENT_KEY="<KEY>"

# -- Omniroute per-tool API keys --------------------------
# Same Omniroute Key can be used for multiple tools,
# but you can also use different keys for each tool if you want to track usage separately.

# Claude Code
export OMNIROUTE_CLAUDE_API_KEY="<KEY>"
# Codex
export OMNIROUTE_CODEX_API_KEY="<KEY>"
# OpenCode
export OMNIROUTE_OPENCODE_API_KEY="<KEY>"
# Atuin AI
export OMNIROUTE_ATUIN_API_KEY="<KEY>"
SECRETS_EOF
            then
                chmod 600 "$secrets"
                msg_success "Created: $secrets (mode 600)"
                msg_info "Edit it to add your API keys: $secrets"
            else
                msg_warning "Failed to create: $secrets"
            fi
        else
            msg_info "Exists: $secrets"
        fi

        # Auto-launch zsh from interactive bash (optional, own confirm)
        local bashrc="$HOME/.bashrc"
        if confirm "Make interactive bash auto-launch zsh (~/.bashrc)?" false; then
            if [[ -f "$bashrc" ]]; then
                backup_path "$bashrc" || msg_warning "Failed to backup: $bashrc"
            fi

            if cat > "$bashrc" <<'BASHRC_EOF'
# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Auto-launch zsh when bash is the interactive login shell
if command -v zsh &> /dev/null; then
    if [[ $(ps --no-header --pid=$PPID --format=comm) != "zsh" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
    then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
        exec zsh $LOGIN_OPTION
    fi
fi
BASHRC_EOF
            then
                msg_success "Updated: $bashrc to auto-launch zsh"
            else
                msg_error "Failed to update: $bashrc"
            fi
        fi

        # Add Learn Menu Entries
        if [[ -f "$menu_file" ]]; then
            # Create a temporary file next to the original
            tmp_file=$(mktemp "${menu_file}.XXXXXX") || {
                msg_error "Failed to create temporary file"
                return 1
            }

            # Merge entries into the existing JSON without overwriting existing keys
            if jq --arg home "$HOME" '
                def entries($home): {
                    "learn.Omarchy-Tweaks": {
                        "icon": "󰮯",
                        "label": "Omarchy Tweaks"
                    },
                    "learn.Omarchy-Tweaks.Tweaks": {
                        "icon": "󰮯",
                        "label": "Tweaks",
                        "action": "omarchy-launch-webapp file://\($home)/.omarchy-tweaks/docs/index.html"
                    },
                    "learn.Omarchy-Tweaks.Zsh": {
                        "icon": "󰆍",
                        "label": "Zsh",
                        "action": "omarchy-launch-webapp file://\($home)/.omarchy-tweaks/docs/zsh-cheatsheet.html"
                    },
                    "learn.Omarchy-Tweaks.aliases": {
                        "icon": "󰌌",
                        "label": "Aliases",
                        "action": "omarchy-launch-webapp file://\($home)/.omarchy-tweaks/docs/aliases.html"
                    },
                    "learn.Omarchy-Tweaks.config": {
                        "icon": "󰌌",
                        "label": "Zsh Config",
                        "action": "omarchy-launch-webapp file://\($home)/.omarchy-tweaks/docs/zsh-config.html"
                    },
                    "learn.Omarchy-Tweaks.git": {
                        "icon": "󰊢",
                        "label": "Git",
                        "action": "omarchy-launch-webapp file://\($home)/.omarchy-tweaks/docs/git-cheatsheet.html"
                    },
                    "learn.Omarchy-Tweaks.functions": {
                        "icon": "󰌌",
                        "label": "Zsh Functions",
                        "action": "omarchy-launch-webapp file://\($home)/.omarchy-tweaks/docs/functions.html"
                    }
                };

                entries($home) as $new
                | reduce ($new | to_entries[]) as $entry (
                    .;
                    if has($entry.key) then .
                    else . + {($entry.key): $entry.value}
                    end
                )
            ' "$menu_file" > "$tmp_file"; then
                # Replace the original only after successful JSON processing
                if mv -f -- "$tmp_file" "$menu_file"; then
                    msg_info "Omarchy Tweaks menu entries updated"
                else
                    msg_error "Failed to update menu file"
                    rm -f "$tmp_file"
                    return 1
                fi
            else
                msg_error "Invalid JSON or failed to process menu file"
                rm -f "$tmp_file"
                return 1
            fi
        else
            msg_warning "Menu file not found: $menu_file (menu entries skipped)"
        fi
    else
        msg_warning "Zsh config setup skipped"
    fi

    msg_info "Dotfiles setup complete (only items you confirmed were applied)"
}

# ======================================================= #
# Plugins Patches
# ======================================================= #
patch_plugins() {
    section "Patch Omarchy Plugins ${NF_PATCH}"
    confirm "Apply patches to Omarchy plugins?" true || {
        msg_warning "Plugin patching skipped"
        return 0
    }

    local patchdir="$PROJECT_DIR/patches"
    [[ -d "$patchdir" ]] || { msg_warning "No patches directory found: $patchdir"; return 0; }

    # Patch Spotlight Plugin
    if [[ -f "$patchdir/spotlight-plugin.patch" ]]; then
        if confirm "Patch Spotlight plugin?" true; then
            chmod +x "$patchdir/spotlight-plugin.patch"
            "$patchdir/spotlight-plugin.patch" || msg_error "Spotlight plugin patch failed"
        else
            msg_warning "Spotlight plugin patch skipped"
        fi
    fi

    # Patch Keybindings-helper Plugin
    if [[ -f "$patchdir/keybindings-helper-plugin.patch" ]]; then
        if confirm "Patch Keybindings-helper plugin?" true; then
            chmod +x "$patchdir/keybindings-helper-plugin.patch"
            "$patchdir/keybindings-helper-plugin.patch" || msg_error "Keybindings-helper plugin patch failed"
        else
            msg_warning "Keybindings-helper plugin patch skipped"
        fi
    fi

    # Patch Switcher Plugin
    if [[ -f "$patchdir/switcher-plugin.patch" ]]; then
        if confirm "Patch Switcher plugin?" true; then
            chmod +x "$patchdir/switcher-plugin.patch"
            "$patchdir/switcher-plugin.patch" || msg_error "Switcher plugin patch failed"
        else
            msg_warning "Switcher plugin patch skipped"
        fi
    fi
}

# ======================================================= #
# Rclone Cloud Storage
# ======================================================= #

setup_rclone() {
    section "Rclone Cloud Storage ${NF_CLOUD}"

    if ! command -v rclone >/dev/null 2>&1; then
        msg_warning "rclone is not installed"
        if confirm "Install rclone now (pacman)?" true; then
            if run_spinner "${NF_PACKAGE}  Installing rclone..." sudo pacman -S --noconfirm rclone; then
                msg_success "rclone installed"
            else
                msg_error "rclone install failed"
                return 1
            fi
        else
            msg_warning "Rclone setup skipped (not installed)"
            return 0
        fi
    fi

    command -v fusermount3 >/dev/null 2>&1 || \
        msg_warning "fuse3 missing — mounts may fail (sudo pacman -S fuse3)"

    confirm "Configure cloud storage accounts (rclone)?" true || {
        msg_warning "Rclone setup skipped"
        return 0
    }

    # Map a menu label to its rclone backend type.
    local -A backend_of=(
        ["Google Drive"]="drive"
        ["Microsoft OneDrive"]="onedrive"
        ["Dropbox"]="dropbox"
        ["Proton Drive"]="protondrive"
    )

    local -a configured_names=()

    while true; do
        printf '\n'
        local label
        label="$(gum choose \
            --header "${NF_CLOUD}  Add a cloud account (or finish)" \
            --cursor="${NF_ARROW} " \
            "Google Drive" \
            "Microsoft OneDrive" \
            "Dropbox" \
            "Proton Drive" \
            "Done")" || return 0

        [[ "$label" == "Done" ]] && break

        local backend="${backend_of[$label]}"
        [[ -n "$backend" ]] || { msg_error "Unknown provider"; continue; }

        # Account name -> remote name, used verbatim (e.g. "work", "me@gmail.com")
        local nick remote
        nick="$(gum input \
            --prompt "  Name for this ${label} account: " \
            --placeholder "personal")" || continue
        [[ -n "$nick" ]] || { msg_warning "Account name required"; continue; }

        remote="$(printf '%s' "$nick" \
            | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9._@+-')"

        if rclone listremotes 2>/dev/null | grep -qx "${remote}:"; then
            msg_warning "Remote '${remote}' already exists"
            confirm "Overwrite it?" false || continue
            rclone config delete "$remote" >/dev/null 2>&1 || true
        fi

        # ---- Authorize / collect credentials ----
        local ok=false
        if [[ "$backend" == "protondrive" ]]; then
            # Proton uses username/password (+ optional 2FA), not OAuth.
            local user pass twofa
            user="$(gum input --prompt "  Proton username (email): " --placeholder "you@proton.me")" || continue
            [[ -n "$user" ]] || { msg_warning "Username required"; continue; }
            pass="$(gum input --password --prompt "  Proton password: ")" || continue
            [[ -n "$pass" ]] || { msg_warning "Password required"; continue; }
            twofa="$(gum input --prompt "  2FA code (blank if none): " --placeholder "optional")" || twofa=""

            printf '  %s  Saving %s...\n' "${NF_CLOUD}" "$remote"
            if [[ -n "$twofa" ]]; then
                rclone config create --non-interactive "$remote" "$backend" \
                    username "$user" password "$pass" 2fa "$twofa" && ok=true
            else
                rclone config create --non-interactive "$remote" "$backend" \
                    username "$user" password "$pass" && ok=true
            fi
        else
            # OAuth backends: run `rclone authorize <backend>` on this machine.
            printf '  %s  Launching browser authorization...\n' "${NF_CLOUD}"
            printf '  %s\n' "Complete the login in your browser, then return here."

            local raw token
            raw="$(rclone authorize "$backend" 2>&1)" || {
                msg_error "Authorization failed for ${label}"
                continue
            }
            token="$(printf '%s\n' "$raw" | awk '
                /Paste the following into your remote machine --->/{grab=1;next}
                /<---End paste/{grab=0}
                grab{print}
            ')"
            [[ -n "$token" ]] || {
                msg_error "Could not read token from rclone authorize"
                continue
            }

            printf '  %s  Saving %s...\n' "${NF_CLOUD}" "$remote"
            local -a extra=()
            [[ "$backend" == "drive" ]] && extra=(config_shared_client_id true)
            if rclone config create --non-interactive "$remote" "$backend" \
                "${extra[@]}" token "$token"; then
                ok=true
            fi
        fi

        if [[ "$ok" == true ]]; then
            if rclone lsd "${remote}:" >/dev/null 2>&1; then
                msg_success "Account ready: ${remote}"
            else
                msg_warning "Remote saved but could not connect: ${remote}"
            fi
            configured_names+=("$remote")
        else
            msg_error "Failed to configure ${label}"
        fi
    done

    (( ${#configured_names[@]} > 0 )) || { msg_info "No accounts configured"; return 0; }

    # ---- Mounts & autostart ----
    printf '\n'
    confirm "Mount these accounts at login (systemd --user, offline cache)?" true || {
        msg_warning "Mount setup skipped"
        return 0
    }

    local mount_root="/mnt"
    local unit_dir="$HOME/.config/systemd/user"
    mkdir -p "$unit_dir"

    local name mountpoint unit enabled=0 failed=0
    for name in "${configured_names[@]}"; do
        mountpoint="$mount_root/$name"
        unit="$unit_dir/rclone-${name}.service"

        # /mnt is root-owned; create the mountpoint (and give it to us) once.
        if [[ ! -d "$mountpoint" ]]; then
            if ! run_spinner "${NF_PACKAGE}  Creating ${mountpoint}..." \
                sudo mkdir -p "$mountpoint"; then
                msg_error "Could not create $mountpoint"
                ((++failed))
                continue
            fi
        fi
        sudo chown "$USER" "$mountpoint" 2>/dev/null || true

        cat > "$unit" <<UNIT_EOF
[Unit]
Description=rclone mount ${name}: at ${mountpoint}
Documentation=https://rclone.org/commands/rclone_mount/
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStartPre=/usr/bin/mkdir -p ${mountpoint}
ExecStart=/usr/bin/rclone mount ${name}: ${mountpoint} \\
    --config ${HOME}/.config/rclone/rclone.conf \\
    --vfs-cache-mode full \\
    --vfs-cache-max-age 72h \\
    --vfs-cache-max-size 5G \\
    --dir-cache-time 1h \\
    --poll-interval 1m \\
    --umask 022 \\
    --log-level INFO
ExecStop=/bin/fusermount3 -u ${mountpoint}
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
UNIT_EOF

        systemctl --user daemon-reload 2>/dev/null || true
        if systemctl --user enable --now "rclone-${name}.service" >/dev/null 2>&1; then
            ((++enabled))
            msg_success "Mounted & enabled at login: $mountpoint"
        else
            ((++failed))
            msg_warning "Unit written but not started: rclone-${name}.service"
            msg_debug "Check: systemctl --user status rclone-${name}.service"
        fi
    done

    printf '\n'
    msg_info "Mounts appear at: $mount_root/<account>"
    msg_info "Manage: systemctl --user status rclone-<account>.service"
    msg_info "Offline: files you open are cached (VFS full, up to 5G / 72h)."
    if [[ "$failed" -eq 0 ]]; then
        msg_success "$enabled account(s) mounted and set to start at login"
    else
        msg_warning "$enabled mounted, $failed need attention"
    fi
}

# ---- Tear-down helper (handy as a menu entry) ----
remove_rclone() {
    section "Remove Rclone Setup ${NF_CLOUD}"
    confirm "Disable/remove all rclone mounts and units?" false || {
        msg_warning "Rclone removal skipped"
        return 0
    }

    local unit name
    shopt -s nullglob
    local -a units=("$HOME/.config/systemd/user"/rclone-*.service)
    shopt -u nullglob

    if (( ${#units[@]} == 0 )); then
        msg_info "No rclone mount units found"
    else
        for unit in "${units[@]}"; do
            name="$(basename "$unit" .service)"
            systemctl --user disable --now "$name" >/dev/null 2>&1 || true
            if rm -f -- "$unit"; then
                msg_success "Removed: $unit"
            fi
        done
    fi

    systemctl --user daemon-reload 2>/dev/null || true
    msg_info "Remotes kept in rclone.conf. Remove with: rclone config delete <name>"
}

# ======================================================= #
# Hyperland Config Overwrites
# ======================================================= #
hyper_overwrite(){
    confirm "Overwrite Hyperland config with custom version?" true || {
        msg_warning "Hyperland config overwrite skipped"
        return 0
    }
    local src="$PROJECT_DIR/configs/hyper"
    local dest="$HOME/.config/hyper"

    # backup existing autostart.lua, bindings.lua, looknfeel.lua, workspaces.lua and symlink new
    for file in autostart.lua bindings.lua looknfeel.lua workspaces.lua; do
        if [[ -f "$dest/$file" || -L "$dest/$file" ]]; then
            backup_path "$dest/$file" || msg_warning "Failed to backup: $dest/$file"
        fi
        if symlink_or_backup "$src/$file" "$dest/$file"; then
            msg_success "Symlinked: $file"
        else
            msg_error "Failed to symlink: $file"
        fi
        # Add require (hypr.workspaces) at the end of hyperland.lua file if not present
        if ! grep -q "require('hypr.workspaces')" "$dest/hyperland.lua"; then
            echo "require('hypr.workspaces')" >> "$dest/hyperland.lua"
            msg_success "Added require('hypr.workspaces') to hyperland.lua"
        else
            msg_info "require('hypr.workspaces') already present in hyperland.lua"
        fi
    done
}

# ======================================================= #
# DistroBox
# ======================================================= #
setup_distrobox() {
    confirm "Setup Distrobox container ?" true || {
        msg_warning "Distrobox setup skipped"
        return 0
    }

    if ! command -v distrobox >/dev/null 2>&1; then
        msg_warning "Distrobox is not installed"
        if confirm "Install Distrobox now (pacman)?" true; then
            if run_spinner "${NF_PACKAGE}  Installing distrobox..." sudo pacman -S --noconfirm distrobox; then
                msg_success "Distrobox installed"
            else
                msg_error "Distrobox install failed"
                return 1
            fi
        else
            msg_warning "Distrobox setup skipped (not installed)"
            return 0
        fi
    fi

    # Container name -> provisioning script. Each script lives in this repo at
    # scripts/distrobox/<name>.sh and installs the zsh/dotfiles runtime.
    local -A script_of=(
        ["Kali Linux"]="kali.sh"
        ["Ubuntu"]="ubuntu.sh"
        ["Debian"]="debian.sh"
        ["Fedora"]="fedora.sh"
        ["Arch Linux"]="arch.sh"
    )
    local -A image_of=(
        ["Kali Linux"]="docker.io/kalilinux/kali-rolling:latest"
        ["Ubuntu"]="docker.io/ubuntu:latest"
        ["Debian"]="docker.io/debian:latest"
        ["Fedora"]="docker.io/fedora:latest"
        ["Arch Linux"]="docker.io/archlinux:latest"
    )

    # Pick distro
    local distro
    distro="$(gum choose \
        --header "${NF_BOX}  Select a base distro for the container" \
        --cursor="${NF_ARROW} " \
        "Kali Linux" "Ubuntu" "Debian" "Fedora" "Arch Linux")" || return 0
    [[ -n "$distro" ]] || { msg_warning "No distro selected"; return 0; }

    local image="${image_of[$distro]}"
    local script="${script_of[$distro]}"
    local script_path="$PROJECT_DIR/scripts/distrobox/$script"

    # Container name (defaults to a slug of the distro)
    local default_name
    default_name="$(printf '%s' "$distro" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/linux//')"
    local name
    name="$(gum input \
        --prompt "  Container name: " \
        --placeholder "${default_name:-container}" \
        --value "$default_name")" || return 0
    [[ -n "$name" ]] || { msg_warning "No name provided"; return 0; }

    if distrobox list 2>/dev/null | awk '{print $3}' | grep -qx "$name"; then
        msg_warning "Container '${name}' already exists"
        confirm "Recreate it?" false || return 0
        distrobox rm --force "$name" >/dev/null 2>&1 || true
    fi

    # Create the container
    if run_spinner "${NF_BOX}  Creating ${name} from ${image}..." \
        distrobox create --name "$name" --image "$image" --yes; then
        msg_success "Container created: $name"
    else
        msg_error "Failed to create container: $name"
        return 1
    fi

    # ---- Instructions ------------------------------------------------------
    printf '\n'
    msg_info "Enter it with:   distrobox enter ${name}"
    msg_info "Then run:        bash ~/.omarchy-tweaks/scripts/distrobox/${script}"
    printf '\n'
    if [[ -f "$script_path" ]]; then
        msg_info "Or, run the provisioning script now (inside the container):"
        if confirm "Provision ${name} now (runs ${script} inside it)?" true; then
            if distrobox enter "$name" -- bash -lc "bash '$script_path' -v"; then
                msg_success "Provisioned ${name} with ${script}"
            else
                msg_warning "Provisioning had issues — see output above"
            fi
        fi
    else
        msg_warning "Provisioning script not found: $script_path"
    fi

    printf '\n'
    msg_info "The container shares your home; the shell config lives at ~/.omarchy-tweaks."
    msg_info "After provisioning, just run: distrobox enter ${name}  (then: zsh)"
}

# ======================================================= #
# Create Vm Script
# ======================================================= #
create_vm_setup(){
    confirm "Create VM Setup Script?" true || {
        msg_warning "VM setup skipped"
        return 0
    }

    local packages=(
        "qemu-desktop"
        "libvirt"
        "virt-manager"
        "dnsmasq"
        "virt-viewer"
    )

    if ! command -v $packages >/dev/null 2>&1; then
        msg_warning "Required packages are not installed: ${packages[*]}"
        if confirm "Install required packages now (pacman)?" true; then
            if run_spinner "${NF_PACKAGE}  Installing required packages..." sudo pacman -S --noconfirm "${packages[@]}"; then
                msg_success "Required packages installed"
            else
                msg_error "Failed to install required packages"
                return 1
            fi
        else
            msg_warning "VM setup skipped (required packages not installed)"
            return 0
        fi
    fi

    # sudo systemctl enable --now libvirtd.service
    if ! sudo systemctl is-active --quiet libvirtd.service; then
        msg_warning "libvirtd.service is not active"
        if confirm "Enable and start libvirtd.service now?" true; then
            if sudo systemctl enable --now libvirtd.service; then
                msg_success "libvirtd.service enabled and started"
            else
                msg_error "Failed to enable/start libvirtd.service"
                return 1
            fi
        else
            msg_warning "VM setup skipped (libvirtd.service not active)"
            return 0
        fi
    fi

    # sudo usermod -aG libvirt "$USER"
    if ! groups "$USER" | grep -q "\blibvirt\b"; then
        msg_warning "User $USER is not in the libvirt group"
        if confirm "Add $USER to libvirt group now?" true; then
            if sudo usermod -aG libvirt "$USER"; then
                msg_success "User $USER added to libvirt group"
                msg_info "You may need to log out and back in for this to take effect."
            else
                msg_error "Failed to add $USER to libvirt group"
                return 1
            fi
        else
            msg_warning "VM setup skipped (user not in libvirt group)"
            return 0
        fi
    fi

    # sudo virsh net-start default
    # sudo virsh net-autostart default
    if ! sudo virsh net-info default >/dev/null 2>&1; then
        msg_warning "Default virtual network is not active"
        if confirm "Start and autostart default virtual network now?" true; then
            if sudo virsh net-start default && sudo virsh net-autostart default; then
                msg_success "Default virtual network started and set to autostart"
            else
                msg_error "Failed to start/autostart default virtual network"
                return 1
            fi
        else
            msg_warning "VM setup skipped (default virtual network not active)"
            return 0
        fi
    fi

    # Symlink the script
    local src="$PROJECT_DIR/scripts/omarchy-create-vm"
    local dst="$HOME/.local/bin/omarchy-create-vm"
    ensure_dir "$(dirname -- "$dst")"
    [[ -e "$dst" || -L "$dst" ]] && backup_path "$dst"
    if symlink_or_backup "$src" "$dst"; then
        msg_success "Symlinked: $dst -> $src"
    else
        msg_error "Failed to symlink: $dst"
    fi
}

# ======================================================= #
# Patch Shutdown Problem
# ======================================================= #
patch_shutdown() {
    local dir="/etc/limine-entry-tool.d"
    local file="$dir/intel-iommu-off.conf"

    if [[ -f "$file" ]]; then
        msg_warning "Already applied: $file"
        confirm "Reapply anyway?" false || return 0
    fi

    confirm "Apply intel_iommu=off via limine-entry-tool.d?" true || {
        msg_warning "Shutdown patch skipped"
        return 0
    }

    sudo mkdir -p "$dir" || {
        msg_error "Failed to create directory: $dir"
        return 1
    }

    echo 'KERNEL_CMDLINE[default]+=" intel_iommu=off"' | sudo tee "$file" >/dev/null || {
        msg_error "Failed to write config: $file"
        return 1
    }
    msg_success "Created: $file"

    if command -v limine-mkinitcpio >/dev/null 2>&1; then
        msg_info "Regenerating initramfs with limine-mkinitcpio..."
        sudo limine-mkinitcpio || msg_warning "limine-mkinitcpio exited with an error"
    else
        msg_warning "limine-mkinitcpio not found - run it manually after updating"
    fi
}

# ======================================================= #
# Custom Wallpapers
# ======================================================= #
wallpapers(){
    confirm "Install custom wallpapers?" true || {
        msg_warning "Wallpaper installation skipped"
        return 0
    }

    local dest="$HOME/Pictures/Wallpapers"
    local url="https://github.com/Get-Winfig/winfig-wallpaper.git"
    local wallpaper="$dest/images"
    local BACK_DIR="$HOME/.config/omarchy/backgrounds"
    local random_="$PROJECT_DIR/scripts/omarchy-bg-random"
    local hook_dir="$HOME/.config/omarchy/hooks/post-boot.d"
    local hook="$hook_dir/random-wallpaper"


    # clone the Repo if not already exist
    if [[ ! -d "$dest" ]]; then
        if run_spinner "${NF_PACKAGE}  Cloning wallpapers..." git clone "$url" --depth 1 "$dest"; then
            msg_success "Wallpapers cloned to: $dest"
        else
            msg_error "Failed to clone wallpapers"
            return 1
        fi
    else
        msg_info "Wallpapers already exist at: $dest"
    fi

    # symlink the random wallpaper script
    ln -sf "$random_" "$HOME/.local/bin/omarchy-bg-random" 2>/dev/null || {
        msg_warning "Failed to symlink random wallpaper script"
    }

    # Symlink all available Wallpapers to all the themes
    if [[ ! -d "$wallpaper" ]]; then
        msg_warning "No wallpapers found in: $wallpaper"
        return 0
    fi

    # Discover theme directories without sorting.
    mapfile -d '' -t THEME_DIRS < <(
        find "$BACK_DIR" -mindepth 1 -maxdepth 1 -type d -print0
    )

    msg_info "Found theme directories: ${THEME_DIRS[*]}"

    # Collect images without sorting or deduplicating.
    mapfile -d '' -t IMGS < <(
        find "$wallpaper" -maxdepth 3 -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' \
            -o -iname '*.png' -o -iname '*.webp' \
            -o -iname '*.gif' \) -print0 2>/dev/null
    )
    msg_info "Found ${#IMGS[@]} image files"

    ((${#IMGS[@]})) || {
        msg_warning "No image files found in: $wallpaper"
        return 0
    }

    # Build a temporary work list and process symlinks in parallel.
    WORK="$(mktemp)"
    trap 'rm -f "$WORK"' EXIT

    for td in "${THEME_DIRS[@]}"; do
        for img in "${IMGS[@]}"; do
            printf '%s\0%s\0' "$img" "$td/${img##*/}" >> "$WORK"
        done
    done

    export WORK
    xargs -0 -n 2 -P "$(nproc)" sh -c '
        ln -sf "$1" "$2" 2>/dev/null || true
        ' _ < "$WORK"

    msg_success "Symlinked wallpapers to all themes in: $BACK_DIR"

    # Create Wallpaper Hook
    ensure_dir "$hook_dir"
    if [[ ! -f "$hook" ]]; then
        command cat > "$hook" <<'EOF'

#!/usr/bin/env bash
set -euo pipefail

config="$HOME/.omarchy-tweaks/config/wallpapers.json"
script="$HOME/.omarchy-tweaks/scripts/omarchy-bg-random"
state_dir="$HOME/.local/state/omarchy-tweaks"
pidfile="$state_dir/random-wallpaper.pid"

if [[ ! -f "$config" || ! -x "$script" ]]; then
    omarchy-notification-send -u critical \
        "Wallpaper config or randomizer script is missing."
    exit 1
fi

command -v jq >/dev/null 2>&1 || exit 1

enabled=$(jq -er '.enabled | select(type == "boolean")' "$config")
interval_seconds=$(jq -er \
    '.interval_seconds | select(type == "number" and . > 0 and floor == .)' \
    "$config")

if [[ "$enabled" != "true" ]]; then
    # Stop the existing loop if randomization has been disabled.
    if [[ -f "$pidfile" ]]; then
        kill "$(cat "$pidfile")" 2>/dev/null || true
        rm -f "$pidfile"
    fi
    exit 0
fi

mkdir -p "$state_dir"

# Avoid starting a second scheduler.
if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    exit 0
fi

# The hook owns the timer; the randomizer only changes the wallpaper.
nohup bash -c '
    set -u
    script=$1
    interval=$2
    pidfile=$3

    echo "$BASHPID" > "$pidfile"
    trap '\''rm -f "$pidfile"'\'' EXIT

    while true; do
        "$script" || omarchy-notification-send -u critical "Wallpaper change failed"
        sleep "$interval"
    done
' _ "$script" "$interval_seconds" "$pidfile" \
    >/dev/null 2>&1 </dev/null &

EOF
    chmod +x "$hook"
    msg_success "Wallpaper hook installed: $hook"
else
    msg_info "Wallpaper hook already exists: $hook"
fi
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

    # Prefix every entry with a stable numeric id so the case below never drifts.
    local choice id
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
        "15. Dotfiles: Setup (Git/Atuin/Starship/Zsh)" \
        "16. Omarchy: Overwrite system scripts" \
        "17. Patch Omarchy Plugins" \
        "18. Rclone: Configure cloud storage (mounts)" \
        "19. Rclone: Remove mounts" \
        "20. Hyperland: Overwrite config" \
        "21. Distrobox: Create + provision container" \
        "22. Create VM Setup" \
        "23. Setup Wallpapers" \
        "24. Patch Shutdown Problem (intel_iommu=off)" \
        "25. View bootstrap.log" \
        "26. Show Version" \
        "27. Toggle Debug (current: ${DEBUG})" \
        "0. Exit")" || return 1

    id="${choice%%.*}"
    if [[ ! "$id" =~ ^[0-9]+$ ]]; then
        msg_warning "Invalid choice"
        show_menu
        return
    fi

    case "$id" in
        1) run_full ;;
        2) snapshot; pause ;;
        3) remove_packages; remove_tui; remove_webapps; remove_mise; pause ;;
        4) install_pacman_packages; install_aur_packages; pause ;;
        5) install_webapps; pause ;;
        6) install_plugins; pause ;;
        7) install_ollama_models; pause ;;
        8) setup_claude; pause ;;
        9) setup_opencode; pause ;;
        10) setup_codex; pause ;;
        11) install_omniroute; pause ;;
        12) setup_docker_containers; pause ;;
        13) create_dirs; pause ;;
        14) setup_bins; pause ;;
        15) setup_dotfiles; pause ;;
        16) setup_omarchy_overwrites; pause ;;
        17) patch_plugins; pause ;;
        18) setup_rclone; pause ;;
        19) remove_rclone; pause ;;
        20) hyper_overwrite; pause ;;
        21) setup_distrobox; pause ;;
        22) create_vm_setup; pause;;
        23) wallpapers; pause;;
        24) patch_shutdown; pause ;;
        25)
            if [[ -f "$LOG_FILE" ]]; then
                less -R "$LOG_FILE" 2>/dev/null || cat "$LOG_FILE"
            else
                msg_warning "Log file not found: $LOG_FILE"
            fi
            pause
            ;;
        26)
            printf '\n%s %s\n' "$SCRIPT_NAME" "$VERSION"
            pause
            ;;
        27)
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
        0) exit 0 ;;
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
    setup_bins || msg_warning "Bin symlinks had issues"
    setup_omarchy_overwrites || msg_warning "Omarchy overwrites had issues"
    pause "Continue to dotfiles?" || return 1

    banner
    section "Dotfiles"
    setup_dotfiles || msg_warning "Dotfiles setup had issues"
    pause "Continue to Plugin patching?" || return 1

    banner
    section "Plugin Patching"
    patch_plugins || msg_warning "Plugin patching had issues"
    pause "Continue to Cloud Storage?" || return 1

    banner
    section "Cloud Storage"
    setup_rclone || msg_warning "Rclone setup had issues"
    pause "Continue to Hyperland Config?" || return 1

    banner
    section "Hyperland Config"
    hyper_overwrite || msg_warning "Hyperland config overwrite had issues"
    pause "Continue to Distrobox?" || return 1

    banner
    section "Setup Distrobox"
    setup_distrobox || msg_warning "Distrobox setup had issues"
    pause "Continue to VM Setup?" || return 1

    banner
    section "Setup Vm Setup Script"
    create_vm_setup || msg_warning "VM setup script had issues"

    banner
    section "Setup Custom Wallpapers"
    wallpapers || msg_warning "Custom wallpapers setup had issues"

    banner
    section "Shutdown Patch (intel_iommu=off)"
    msg_info "Intended for laptops like ThinkPad T460 with improper shutdown/reboot"
    printf '\n'
    msg_warning "WARNING: ADVANCED SYSTEM-LEVEL CHANGE"
    msg_warning "This patch modifies your boot configuration."
    msg_warning "It disables Intel IOMMU using: intel_iommu=off"
    msg_warning "This may affect virtualization, PCI passthrough, and device isolation."
    msg_warning "Only apply this if you are experiencing shutdown or power-off issues."
    msg_warning "Do not apply this as a general performance tweak."
    msg_warning "If this does not fix your shutdown issue, remove the patch and restore your previous configuration."
    printf '\n'
    patch_shutdown || msg_warning "Shutdown patch had issues"

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
