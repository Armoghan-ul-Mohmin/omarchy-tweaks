#! /usr/bin/env bash

# ======================================================= #
#          Bootstrap Script for Project Setup             #
# ======================================================= #
#   Author:  Armoghan-ul-Mohmin                           #
#   Version: 1.0.0                                        #
#   Date:    2026-10-09                                   #
# ======================================================= #
#                                                         #
#   Usage:                                                #
#     chmod +x ~/.omarchy-tweaks/bootstrap.sh             #
#     ~/.omarchy-tweaks/bootstrap.sh                      #
#     ~/.omarchy-tweaks/bootstrap.sh --help               #
#     ~/.omarchy-tweaks/bootstrap.sh --version            #
#                                                         #
# ======================================================= #

set -Eeuo pipefail
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR
trap on_interrupt INT

# ======================================================= #
#  Global Variables
# ======================================================= #

# Metadata
AUTHOR="Armoghan-ul-Mohmin"
VERSION="1.0.0"
URL="https://github.com/Armoghan-ul-Mohmin/omarchy-tweaks.git"
OMARCHY_VERSION=$(omarchy-version)
readonly LOG_DATE_FORMAT="+%Y-%m-%d %H:%M:%S"
readonly SCRIPT_NAME="bootstrap.sh"
DEBUG=0

# Path
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# readonly PROJECT_DIR="$HOME/.omarchy-tweaks"
readonly PROJECT_DIR="/home/armoghan/Documents/Github/Armoghan-ul-Mohmin/omarchy-tweaks"  # Just for developement
readonly CONFIG_DIR="$HOME/.config"
readonly LOG_DIR="$PROJECT_DIR/logs"
readonly HOME_DIR="$HOME"

# Files
readonly LOG_FILE="$LOG_DIR/bootstrap.log"
readonly BANNER_FILE="$PROJECT_DIR/banner.txt"

# Log levels
readonly LOG_LEVEL_INFO="INFO"
readonly LOG_LEVEL_SUCCESS="SUCCESS"
readonly LOG_LEVEL_WARNING="WARN"
readonly LOG_LEVEL_ERROR="ERROR"
readonly LOG_LEVEL_DEBUG="DEBUG"

# Icons
readonly NF_CHECK=""
readonly NF_CROSS=""
readonly NF_WARNING=""
readonly NF_INFO=""
readonly NF_DEBUG=""
readonly NF_ARROW=""
readonly NF_ROCKET="󰓅"
readonly NF_GEAR=""

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
    ~/.local/bin/gemini
    ~/.local/bin/pi
    ~/.local/bin/omp
    ~/.local/bin/grok
    ~/.local/bin/crush
    ~/.local/bin/ghui
    ~/.local/bin/hunk
    ~/.local/bin/cursor-agent
    ~/.local/bin/hermes
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
    "Spotlight|https://github.com/maajix/omarchy-spotlight.git|A Raycast-style launcher for Omarchy."
    "Tray|https://github.com/TyRichards/omarchy-tray.git|A better system tray"
    "Yet Another Notification Center|https://github.com/Loafer19/omarchy-yet-another-notification-center.git|Notification history"
)

# Ollama Models
readonly OLLAMA_MODELS=(
    "qwen3:1.7b"                        # Size: 1.7GB
    "qwen2.5-coder:1.5b"                # Size: 986MB
    "qwen2.5-coder:0.5b"                # Size: 398MB
    "qwen:0.5b"                         # Size: 395MB
    "tinyllama:latest"                  # Size: 638MB
    "tinyllama:1.1b"                    # Size: 638MB
    "dolphin-phi:2.7b-v2.6-q3_K_S"      # Size: 1.3GB  (Unfiltered)
)

# ======================================================= #
# Error Handling
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
    msg_error "Setup interrupted by user."
    exit 130
}

# Debug command tracer (replaces noisier `set -x`).
__debug_trace() {
    local cmd="${BASH_COMMAND%% *}"
    case "$cmd" in
        msg_*)
            # msg_* functions already print their own formatted output.
            return
            ;;
        main | parse_arguments | init_logger | check_dependencies | banner)
            printf '+ %s\n' "$BASH_COMMAND" >&2
            ;;
    esac
}

# ======================================================= #
# Logger
# ======================================================= #

# Write a message to the log file only.
# Terminal output is handled by the msg_* helpers, so nothing is printed twice.
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp log_line

    timestamp=$(date "$LOG_DATE_FORMAT") || timestamp="unknown-time"
    log_line="[$timestamp] [$level] $message"

    printf '%s\n' "$log_line" >> "$LOG_FILE" 2>/dev/null || {
        printf 'WARNING: Unable to write to log file\n' >&2
    }
}

# Initialize Logger
init_logger() {
    if ! mkdir -p -- "$LOG_DIR"; then
        printf 'ERROR: Cannot create log directory: %s\n' "$LOG_DIR" >&2
        return 1
    fi

    if ! touch -- "$LOG_FILE"; then
        printf 'ERROR: Cannot create log file: %s\n' "$LOG_FILE" >&2
        return 1
    fi

    log "$LOG_LEVEL_DEBUG" "Logger initialized: $LOG_FILE"
}

# ======================================================= #
# Argument Parsing/ Help Menu
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
  -h, --help       Show help
  -v, --version    Show version
  -d, --debug      Enable debug output
EOF
}

# ======================================================= #
#  Helper Functions
# ======================================================= #

# Success Message
msg_success() {
    gum style \
        --foreground 2 \
        --bold \
        "${NF_CHECK} SUCCESS: $*"
    log SUCCESS "$*"
}

# Error Message
msg_error() {
    gum style \
        --foreground 1 \
        --bold \
        "${NF_CROSS} ERROR: $*" >&2
    log ERROR "$*"
}

# Warning Message
msg_warning() {
    gum style \
        --foreground 3 \
        --bold \
        "${NF_WARNING} WARNING: $*" >&2
    log WARN "$*"
}

# Info Message
msg_info() {
    gum style \
        --foreground 4 \
        "${NF_INFO} INFO: $*"
    log INFO "$*"
}

# Debug Message
msg_debug() {
    [[ "${DEBUG:-0}" == "1" ]] || return 0

    gum style \
        --foreground 8 \
        "${NF_DEBUG} DEBUG: $*" >&2
    log DEBUG "$*"
}

# Check if command exists
command_exists() {
    local cmd="$1"

    if command -v "$cmd" >/dev/null 2>&1; then
        msg_debug "Command found: $cmd"
        return 0
    fi
    msg_error "Command not found: $cmd"
    return 1
}

# Check Dependencies
check_dependencies() {
    local cmd
    # gum is required for formatted messages.
    if ! command -v gum >/dev/null 2>&1; then
        printf 'ERROR: Required command not found: gum\n' >&2
        exit 1
    fi

    for cmd in git omarchy-version snapper; do
        if ! command_exists "$cmd"; then
            return 1
        fi
    done
    msg_success "All required dependencies are installed"
}

# Confirm to make directories if they don't exist
confirm_create_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        gum confirm \
            "Directory '$dir' does not exist. Do you want to create it?" \
            --default=true \
            --affirmative="Yes" \
            --negative="No" || {
                msg_error "Directory creation skipped."
                return 1
            }
    fi
}

# ======================================================= #
# Functions
# ======================================================= #

# Display project banner if available
banner() {
    clear
    printf '\n\n'

    local title="OMARCHY TWEAKS"
    local subtitle="Bootstrap & Configuration Setup"

    # Main banner
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
            "$NF_ROCKET  $title
            $subtitle"
    fi

    printf '\n'

    # Project metadata
    gum style \
        --foreground 5 \
        --align center \
        --width 130 \
        --padding "1 1" \
        "${NF_GEAR}  Author: ${AUTHOR}     ${NF_CHECK}  Version: ${VERSION}"

    # Git URL on the next line
    gum style \
        --foreground 5 \
        --align center \
        --width 130 \
        --padding "0 1" \
        "${NF_ARROW}  Git: ${URL}"

    printf '\n'

    # Environment information
    gum style \
        --border rounded \
        --border-foreground 8 \
        --foreground 8 \
        --align center \
        --width 130\
        --padding "0 1" \
        "Omarchy Version: ${OMARCHY_VERSION}"

    printf '\n'
}

# Create Snapshot of the Current System State
snapshot() {
    local NAME=""
    local DESCRIPTION=""
    local SNAPSHOT_ID
    local SNAPSHOT_DESCRIPTION

    SNAPSHOT_ID="$(date +%Y-%m-%d_%H:%M:%S)"

    printf '\n'
    msg_info "Creating a snapshot of the current system state..."

    gum confirm \
        "Do you want to create a snapshot before proceeding?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Snapshot creation skipped."
            return 0
        }

    if gum confirm \
        "Do you want to provide a custom name for the snapshot?" \
        --default=false \
        --affirmative="Yes" \
        --negative="No"; then
        NAME="$(gum input --placeholder "Enter snapshot name (optional)")"
    fi

    if gum confirm \
        "Do you want to provide a description for the snapshot?" \
        --default=false \
        --affirmative="Yes" \
        --negative="No"; then
        DESCRIPTION="$(gum input --placeholder "Enter snapshot description (optional)")"
    fi

    # Build snapshot description from supplied values.
    SNAPSHOT_DESCRIPTION="$SNAPSHOT_ID"

    if [[ -n "$NAME" && -n "$DESCRIPTION" ]]; then
        SNAPSHOT_DESCRIPTION="$SNAPSHOT_ID - $NAME: $DESCRIPTION"
    elif [[ -n "$NAME" ]]; then
        SNAPSHOT_DESCRIPTION="$SNAPSHOT_ID - $NAME"
    elif [[ -n "$DESCRIPTION" ]]; then
        SNAPSHOT_DESCRIPTION="$SNAPSHOT_ID - $DESCRIPTION"
    elif [[ -z "$NAME" && -z "$DESCRIPTION" ]]; then
        SNAPSHOT_DESCRIPTION="$SNAPSHOT_ID"
    fi

    if snapper create --description "$SNAPSHOT_DESCRIPTION"; then
        msg_success "Snapshot created successfully: $SNAPSHOT_DESCRIPTION"
    else
        msg_error "Failed to create snapshot."
        return 1
    fi
}

# Remove Packages (bloatware)
remove_packages() {
    printf '\n'
    msg_info "Remove Preinstalled Bloatware Packages"
    printf '\n'
    gum confirm \
        "Do you want to remove preinstalled bloatware packages?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Package removal skipped."
            return 0
        }

    local -a remove_cmd=(pacman -Rns --noconfirm)
    if [[ "$EUID" -ne 0 ]]; then
        if ! command -v sudo >/dev/null 2>&1 || ! sudo -v; then
            msg_error "Root privileges are required to remove packages."
            return 1
        fi
        remove_cmd=(sudo "${remove_cmd[@]}")
    fi

    # Filter the list down to packages that are actually installed.
    local -a installed=()
    local package
    for package in "${PACKAGES_TO_REMOVE[@]}"; do
        if pacman -Qq "$package" >/dev/null 2>&1; then
            installed+=("$package")
        fi
    done

    if (( ${#installed[@]} == 0 )); then
        msg_warning "No bloatware packages found to remove."
        return 0
    fi

    local selected_packages
    selected_packages="$(gum choose \
        --no-limit \
        --cursor="${NF_ARROW} " \
        --selected-prefix="${NF_CHECK} " \
        --unselected-prefix="  " \
        --header "Select packages to remove (use space to select, enter to confirm)" \
        "${installed[@]}")" || {
            msg_warning "Package removal skipped."
            return 0
        }

    local -a to_remove=()
    while read -r package; do
        [[ -n "$package" ]] || continue
        to_remove+=("$package")
    done <<< "$selected_packages"

    if (( ${#to_remove[@]} == 0 )); then
        msg_warning "No packages selected."
        return 0
    fi

    # Remove everything in a single pacman transaction.
    local output
    if output="$("${remove_cmd[@]}" "${to_remove[@]}" 2>&1)"; then
        msg_success "Removed packages: ${to_remove[*]}"
    else
        msg_error "Failed to remove packages: ${to_remove[*]}"
        printf '%s\n' "$output" >&2
        return 1
    fi
}

# Remove TUI packages (preinstalled)
remove_tui() {
    local APP_DIR="${1:-$HOME/.local/share/applications}"
    local ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
    local OLD_ICON_DIR="$HOME/.local/share/applications/icons"

    printf '\n'
    msg_info "Remove Preinstalled TUI Applications"
    printf '\n'

    gum confirm \
        "Do you want to remove preinstalled TUI applications?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "TUI removal skipped."
            return 0
        }

    # Find installed TUI desktop entries.
    local -a tui_desktop_files=()
    local -a tui_names=()
    local -a choices=()
    local file app_name icon_name

    while IFS= read -r -d '' file; do
        if grep -qF 'Exec=xdg-terminal-exec --app-id=TUI.' "$file" 2>/dev/null; then
            app_name="$(basename "$file" .desktop)"
            tui_desktop_files+=("$file")
            tui_names+=("$app_name")
            choices+=("$app_name")
        fi
    done < <(find "$APP_DIR" -maxdepth 1 -type f -name '*.desktop' -print0 2>/dev/null)

    if (( ${#choices[@]} == 0 )); then
        msg_warning "No TUIs found."
        return 0
    fi

    # Select TUIs using the same styled multi-select menu.
    local selected_tuis
    selected_tuis="$(gum choose \
        --no-limit \
        --cursor="${NF_ARROW} " \
        --selected-prefix="${NF_CHECK} " \
        --unselected-prefix="  " \
        --header "${NF_GEAR}  Select TUIs to remove (space to select, enter to confirm)" \
        "${choices[@]}")" || {
            msg_warning "TUI removal skipped."
            return 0
        }

    local -a to_remove=()
    while IFS= read -r app_name; do
        [[ -n "$app_name" ]] || continue
        to_remove+=("$app_name")
    done <<< "$selected_tuis"

    if (( ${#to_remove[@]} == 0 )); then
        msg_warning "No TUIs selected."
        return 0
    fi

    # Remove selected desktop files and their icons.
    local i output
    for app_name in "${to_remove[@]}"; do
        for i in "${!tui_names[@]}"; do
            [[ "${tui_names[$i]}" == "$app_name" ]] || continue

            icon_name="$(printf '%s\n' "$app_name" |
                tr '[:upper:]' '[:lower:]' |
                sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//')"

            if output="$(rm -f -- \
                "${tui_desktop_files[$i]}" \
                "$ICON_DIR/$icon_name.png" \
                "$OLD_ICON_DIR/$icon_name.png" 2>&1)"; then
                msg_success "Removed TUI: $app_name"
            else
                msg_error "Failed to remove TUI: $app_name"
                printf '%s\n' "$output" >&2
            fi
            break
        done
    done
}

# Remove WebApps (preinstalled)
remove_webapps() {
    local APP_DIR="${1:-$HOME/.local/share/applications}"
    local ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
    local OLD_ICON_DIR="$HOME/.local/share/applications/icons"

    printf '\n'
    msg_info "Remove Preinstalled Web Applications"
    printf '\n'

    gum confirm \
        "Do you want to remove preinstalled web applications?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "WebApp removal skipped."
            return 0
        }

    # Find installed WebApp desktop entries.
    local -a webapp_desktop_files=()
    local -a webapp_names=()
    local -a choices=()
    local file app_name

    while IFS= read -r -d '' file; do
        if grep -Eq 'Exec=(omarchy-launch-webapp|omarchy-webapp-handler)' "$file" 2>/dev/null; then
            app_name="$(basename "$file" .desktop)"
            webapp_desktop_files+=("$file")
            webapp_names+=("$app_name")
            choices+=("$app_name")
        fi
    done < <(find "$APP_DIR" -maxdepth 1 -type f -name '*.desktop' -print0 2>/dev/null)

    if (( ${#choices[@]} == 0 )); then
        msg_warning "No web apps found."
        return 0
    fi

    # Select WebApps using a styled multi-select menu.
    local selected_webapps
    selected_webapps="$(gum choose \
        --no-limit \
        --cursor="${NF_ARROW} " \
        --selected-prefix="${NF_CHECK} " \
        --unselected-prefix="  " \
        --header "${NF_GEAR}  Select WebApps to remove (space to select, enter to confirm)" \
        "${choices[@]}")" || {
            msg_warning "WebApp removal skipped."
            return 0
        }

    local -a to_remove=()
    local name
    while IFS= read -r name; do
        [[ -n "$name" ]] || continue
        to_remove+=("$name")
    done <<< "$selected_webapps"

    if (( ${#to_remove[@]} == 0 )); then
        msg_warning "No WebApps selected."
        return 0
    fi

    # Remove selected desktop files and their icons.
    local i icon_name output
    for name in "${to_remove[@]}"; do
        for i in "${!webapp_names[@]}"; do
            [[ "${webapp_names[$i]}" == "$name" ]] || continue

            icon_name="$(printf '%s\n' "$name" |
                tr '[:upper:]' '[:lower:]' |
                sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//')"

            if output="$(rm -f -- \
                "${webapp_desktop_files[$i]}" \
                "$ICON_DIR/$icon_name.png" \
                "$OLD_ICON_DIR/$icon_name.png" 2>&1)"; then
                msg_success "Removed WebApp: $name"
            else
                msg_error "Failed to remove WebApp: $name"
                printf '%s\n' "$output" >&2
            fi
            break
        done
    done
}

# Remove MISE (preinstalled)
remove_mise() {
    local mise_config="$HOME/.config/mise/config.toml"

    printf '\n'
    msg_info "Remove Preinstalled MISE Configuration and Binaries"
    printf '\n'

    gum confirm \
        "Do you want to remove the preinstalled MISE configuration and binaries?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "MISE removal skipped."
            return 0
        }

    if [[ ! -f "$mise_config" ]]; then
        msg_warning "MISE config not found. Skipping config backup."
    else
        if /usr/bin/mv -- "$mise_config" "$mise_config.bak"; then
            msg_success "MISE config backed up."
        else
            msg_error "Failed to back up MISE config."
            return 1
        fi
    fi

    if ln -sf -- "$PROJECT_DIR/config/mise.toml" "$mise_config"; then
        msg_success "MISE config symlink created."
    else
        msg_error "Failed to create MISE config symlink."
        return 1
    fi

    if (( ${#MISE[@]} == 0 )); then
        msg_warning "No MISE binaries specified for removal."
        return 0
    fi

    if /usr/bin/rm -rf -- "${MISE[@]}" > /dev/null 2>&1; then
        msg_success "Removed MISE binaries."
    else
        msg_error "Failed to remove MISE binaries."
        return 1
    fi

    gum confirm \
        "Do you want to update mise" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "MISE update skipped."
            return 0
        }
    mise update || {
        msg_error "Failed to update MISE."
        return 1
    }
}

# Check and install Pacman packages if not installed
install_pacman_packages() {
    local package
    for package in "${PACMAN_PACKAGES[@]}"; do
        if ! pacman -Qq "$package" >/dev/null 2>&1; then
            gum confirm \
                "Package '$package' is not installed. Do you want to install it?" \
                --default=true \
                --affirmative="Yes" \
                --negative="No" || {
                    msg_warning "Installation of package '$package' skipped."
                    continue
                }
            pacman -S --noconfirm "$package" > /dev/null 2>&1 && msg_success "Installed package: $package" || msg_error "Failed to install package: $package"
        fi
    done
}

# Check and install AUR packages if not installed
install_aur_packages() {
    local package
    for package in "${AUR_PACKAGES[@]}"; do
        if ! pacman -Qq "$package" >/dev/null 2>&1; then
            gum confirm \
                "AUR package '$package' is not installed. Do you want to install it?" \
                --default=true \
                --affirmative="Yes" \
                --negative="No" || {
                    msg_warning "Installation of AUR package '$package' skipped."
                    continue
                }
            # Assuming an AUR helper like yay is installed
            yay -S --noconfirm "$package" > /dev/null 2>&1 && msg_success "Installed AUR package: $package" || msg_error "Failed to install AUR package: $package"
        fi
    done
}

# Install WebApps
install_webapps() {
    local APP_DIR="$HOME/.local/share/applications"
    local entry app_name app_url icon_file icon_path output
    local failed=0

    printf '\n'
    msg_info "Install Preconfigured Web Applications"
    printf '\n'

    gum confirm \
        "Do you want to install all preconfigured web applications?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "WebApp installation skipped."
            return 0
        }

    if ! command -v omarchy-webapp-install >/dev/null 2>&1; then
        msg_error "omarchy-webapp-install command not found."
        return 1
    fi

    mkdir -p "$APP_DIR" || {
        msg_error "Failed to create applications directory."
        return 1
    }

    for entry in "${WEBAPPS[@]}"; do
        IFS='|' read -r app_name app_url icon_file <<< "$entry"

        if [[ -z "$app_name" || -z "$app_url" ]]; then
            msg_warning "Invalid WebApp entry: $entry"
            failed=1
            continue
        fi

        printf '\n'
        msg_info "Installing WebApp: $app_name"

        # CyberChef uses a preconfigured desktop entry for its local file URL.
        if [[ "$app_name" == "CyberChef" ]]; then
            local cyberchef_desktop="$PROJECT_DIR/config/cyberchef.desktop"

            if [[ ! -f "$cyberchef_desktop" ]]; then
                msg_error "CyberChef desktop file not found: $cyberchef_desktop"
                failed=1
                continue
            fi

            if ln -sf -- "$cyberchef_desktop" "$APP_DIR/cyberchef.desktop"; then
                msg_success "Installed CyberChef desktop entry."
            else
                msg_error "Failed to install CyberChef desktop entry."
                failed=1
            fi

            continue
        fi

        # Resolve optional custom icons from project assets.
        icon_path=""
        if [[ -n "$icon_file" ]]; then
            icon_path="$PROJECT_DIR/assets/$icon_file"

            if [[ ! -f "$icon_path" ]]; then
                msg_error "Icon not found for $app_name: $icon_path"
                failed=1
                continue
            fi
        fi

        if output="$(omarchy-webapp-install "$app_name" "$app_url" "$icon_path" 2>&1)"; then
            msg_success "Installed WebApp: $app_name"
        else
            msg_error "Failed to install WebApp: $app_name"
            printf '%s\n' "$output" >&2
            failed=1
        fi
    done

    if (( failed != 0 )); then
        msg_warning "Some WebApps could not be installed."
        return 1
    fi

    msg_success "All WebApps installed successfully."
}

# Install Omarchy plugins
install_plugins() {
    local total="${#OMARCHY_PLUGINS[@]}"
    local idx=0 ok=0 fail=0
    local plugin_name plugin_url plugin_description

    printf '\n'
    gum style \
        --foreground "#cba6f7" --bold \
        --border-foreground "#cba6f7" --border rounded \
        --padding "1 2" \
        "Omarchy Plugins  ·  ${total} available"
    printf '\n'

    gum confirm \
        "Install all ${total} Omarchy plugins?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Plugin installation skipped."
            return 0
        }

    if ! command -v omarchy-plugin-add >/dev/null 2>&1; then
        msg_error "omarchy-plugin-add command not found."
        return 1
    fi

    for plugins in "${OMARCHY_PLUGINS[@]}"; do
        IFS='|' read -r plugin_name plugin_url plugin_description <<< "$plugins"

        if [[ -z "$plugin_name" || -z "$plugin_url" ]]; then
            msg_warning "Invalid plugin entry: $plugins"
            continue
        fi

        idx=$((idx + 1))

        # ── Spinner title: name + description ──
        local spin_title="${idx}/${total}  ${plugin_name}"
        [[ -n "$plugin_description" ]] && spin_title+=" — ${plugin_description}"

        if gum spin \
            --spinner dot \
            --title "$spin_title" \
            -- omarchy-plugin-add "$plugin_url"; then

            ok=$((ok + 1))
            gum style \
                --foreground "#a6e3a1" --bold \
                --padding "0 2" \
                "✓  ${plugin_name}"
        else
            fail=$((fail + 1))
            gum style \
                --foreground "#f38ba8" --bold \
                --padding "0 2" \
                "✗  ${plugin_name}"
        fi
    done

    # ── Summary ──
    printf '\n'
    if (( fail == 0 )); then
        gum style \
            --foreground "#a6e3a1" --bold \
            --border-foreground "#a6e3a1" --border rounded \
            --padding "1 2" \
            "✓  All ${total} Omarchy plugins installed"
    elif (( ok == 0 )); then
        gum style \
            --foreground "#f38ba8" --bold \
            --border-foreground "#f38ba8" --border rounded \
            --padding "1 2" \
            "✗  All ${total} installations failed"
    else
        gum style \
            --foreground "#f9e2af" --bold \
            --border-foreground "#f9e2af" --border rounded \
            --padding "1 2" \
            "✓  ${ok} installed   ·   ✗  ${fail} failed   ·   ${total} total"
    fi
    printf '\n'

    (( fail == 0 ))
}

# Install Ollama ans download models
install_ollama_models() {
    local model

    gum confirm \
        "Do you want to install Ollama and download the preconfigured models?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Ollama installation skipped."
            return 0
        }

    command_exists ollama || {
        msg_error "ollama command not found. Please install Ollama first."
        return 1
    }

    /usr/bin/curl -fsSL https://ollama.com/install.sh | sh

    for model in "${OLLAMA_MODELS[@]}"; do
        gum confirm \
            "Do you want to download Ollama model '$model'?" \
            --default=true \
            --affirmative="Yes" \
            --negative="No" || {
                msg_warning "Download of Ollama model '$model' skipped."
                continue
            }
        if ollama pull "$model"; then
            msg_success "Downloaded Ollama model: $model"
        else
            msg_error "Failed to download Ollama model: $model"
        fi
    done
}

# Setup Custom Docker Containers
setup_docker_containers() {

    local atuin_ai="$PROJECT_DIR/containers/atuin"
    local open_webui="$PROJECT_DIR/containers/open-webui"
    local outline="$PROJECT_DIR/containers/outline"
    local snapotter="$PROJECT_DIR/containers/snapotter"

    command_exists docker || {
        msg_error "docker command not found. Please install Docker first."
        return 1
    }

    command_exists docker-compose || {
        msg_error "docker-compose command not found. Please install Docker Compose first."
        return 1
    }

    # Atuin Ai Container
    gum confirm \
        "Do you want to set up Atuin-Ai container?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Atuin-Ai container setup skipped."
            return 0
        }

    if [[ ! -d $HOME_DIR/.config/atuin-ai-server ]]; then
        msg_error "Atuin-Ai config directory not found: $HOME_DIR/.config/atuin-ai-server"
        /usr/bin/mkdir -p "$HOME_DIR/.config/atuin-ai-server"
        ln -sf "$PROJECT_DIR/config/atuin-ai-server.toml" "$HOME_DIR/.config/atuin-ai-server/config.toml"
    else
        msg_info "Atuin-Ai config directory already exists: $HOME_DIR/.config/atuin-ai-server"
        /usr/bin/mv -- "$HOME_DIR/.config/atuin-ai-server/config.toml" "$HOME_DIR/.config/atuin-ai-server/config.toml.bak" || {
            msg_error "Failed to backup existing Atuin-Ai config."
            return 1
        }
        ln -sf "$PROJECT_DIR/config/atuin-ai-server.toml" "$HOME_DIR/.config/atuin-ai-server/config.toml"
        msg_success "Atuin-Ai config symlink created: $HOME_DIR/.config/atuin-ai-server/config.toml"
    fi


    if [[ ! -d "$atuin_ai" ]]; then
        msg_error "Atuin-Ai container directory not found: $atuin_ai"
        return 1
    fi

    docker-compose -f "$atuin_ai/docker-compose.yml" up -d || {
        msg_error "Failed to set up Atuin-Ai container."
        return 1
    }

    #  Open WebUI Container
    gum confirm \
        "Do you want to set up Open-WebUI container?" \
        --default=true \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Open-WebUI container setup skipped."
            return 0
        }

    if [[ ! -d "$open_webui" ]]; then
        msg_error "Open-WebUI container directory not found: $open_webui"
        return 1
    fi

    docker-compose -f "$open_webui/docker-compose.yml" up -d || {
        msg_error "Failed to set up Open-WebUI container."
        return 1
    }

    # Outline Container
    gum confirm \
        "Do you want to set up Outline container?" \
        --default=false \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Outline container setup skipped."
            return 0
        }

    if [[ ! -d "$outline" ]]; then
        msg_error "Outline container directory not found: $outline"
        return 1
    fi

    docker-container -f "$outline/docker-compose.yml" up -d || {
        msg_error "Failed to set up Outline container."
        return 1
    }

    #  Snapotter Container
    gum confirm \
        "Do you want to set up Snapotter container?" \
        --default=false \
        --affirmative="Yes" \
        --negative="No" || {
            msg_warning "Snapotter container setup skipped."
            return 0
        }

    if [[ ! -d "$snapotter" ]]; then
        msg_error "Snapotter container directory not found: $snapotter"
        return 1
    fi

    docker-compose -f "$snapotter/docker-compose.yml" up -d || {
        msg_error "Failed to set up Snapotter container."
        return 1
    }
}

# ======================================================= #
# Main Script
# ======================================================= #

main() {
    parse_arguments "$@"
    #  Display the project banner.
    banner
    # Innitialize logger before any logging occurs.
    init_logger
    # Check dependencies before using gum or Omarchy commands.
    check_dependencies || exit 1
    # Create a snapshot of the current system state before proceeding.
    snapshot || exit 1
    # Remove preinstalled bloatware packages.
    remove_packages
    # Remove preinstalled TUIs.
    remove_tui
    # Remove preinstalled WebApps.
    remove_webapps
    # Remove preinstalled Mise
    remove_mise

    # press any key to continue
    printf '\n'
    gum confirm \
        "Press any key to continue..." \
        --default=true \
        --affirmative="Continue" \
        --negative="Exit" || {
            msg_warning "Setup exited by user."
            exit 0
        }

    # Display banner again after all operations are complete.
    banner

    # Create Github directory
    confirm_create_dir $HOME_DIR/Github || {
        msg_warning "Github directory creation skipped."
    }

    # Create Projects directory
    confirm_create_dir $HOME_DIR/Projects || {
        msg_warning "Projects directory creation skipped."
    }

    #  Create .ISO directory
    confirm_create_dir $HOME_DIR/.ISO || {
        msg_warning ".ISO directory creation skipped."
    }

    #  Create .VM directory
    confirm_create_dir $HOME_DIR/.VM || {
        msg_warning ".VM directory creation skipped."
    }

    # press any key to continue
    printf '\n'
    gum confirm \
        "Press any key to continue..." \
        --default=true \
        --affirmative="Continue" \
        --negative="Exit" || {
            msg_warning "Setup exited by user."
            exit 0
        }

    # Display banner again after all operations are complete.
    banner

    # Install Pacman packages
    install_pacman_packages || {
        msg_error "Failed to install some Pacman packages."
        exit 1
    }

    # Install AUR packages
    install_aur_packages || {
        msg_error "Failed to install some AUR packages."
        exit 1
    }

    # Install Webapps
    install_webapps || {
        msg_error "Failed to install some WebApps."
        exit 1
    }

    # press any key to continue
    printf '\n'
    gum confirm \
        "Press any key to continue..." \
        --default=true \
        --affirmative="Continue" \
        --negative="Exit" || {
            msg_warning "Setup exited by user."
            exit 0
        }

    # Display banner again after all operations are complete.
    banner

    # Install Omarchy plugins
    install_plugins || {
        msg_error "Failed to install some Omarchy plugins."
        exit 1
    }

    # press any key to continue
    printf '\n'
    gum confirm \
        "Press any key to continue..." \
        --default=true \
        --affirmative="Continue" \
        --negative="Exit" || {
            msg_warning "Setup exited by user."
            exit 0
        }

    # Display banner again after all operations are complete.
    banner

    # Install Ollama and download models
    install_ollama_models || {
        msg_error "Failed to install Ollama or download some models."
        exit 1
    }

    # press any key to continue
    printf '\n'
    gum confirm \
        "Press any key to continue..." \
        --default=true \
        --affirmative="Continue" \
        --negative="Exit" || {
            msg_warning "Setup exited by user."
            exit 0
        }

    # Display banner again after all operations are complete.
    banner

    # Install Omniroute
    gum confirm \
    "Do you want to install omniroute?" \
    --default=true \
    --affirmative="Yes" \
    --negative="No" || {
        msg_warning "Omniroute installation skipped."
        return 0
    }

    command_exists npm || {
        msg_error "npm command not found. Please install Node.js and npm first."
        exit 1
    }

    npm install -g omniroute || {
        msg_error "Failed to install omniroute."
        exit 1
    }

    # Setup Claude code
    gum confirm \
    "Do you want to setup Claude code?" \
    --default=true \
    --affirmative="Yes" \
    --negative="No" || {
        msg_warning "Claude code setup skipped."
        return 0
    }

    if [[ -s $HOME_DIR/.claude/settings.json ]]; then
        /usr/bin/mv -- "$HOME_DIR/.claude/settings.json" "$HOME_DIR/.claude/settings.json.bak" || {
            msg_error "Failed to backup existing Claude settings."
            exit 1
        }
        msg_success "Existing Claude settings backed up."
    fi

    if [[ -s $PROJECT_DIR/config/claude/settings.json ]]; then
        ln -sf -- "$PROJECT_DIR/config/claude/settings.json" "$HOME_DIR/.claude/settings.json" || {
            msg_error "Failed to create symlink for Claude settings."
            exit 1
        }
        msg_success "Claude settings symlink created."

        #  Run Omniroute Claude Setup
        if  omniroute setup-claude ; then
            msg_success "Omniroute Claude setup completed successfully."
        else
            msg_error "Omniroute Claude setup failed."
            exit 1
        fi
    else
        msg_warning "Claude settings file not found in project config."
    fi

    # Setup Open code
    gum confirm \
    "Do you want to setup Open code?" \
    --default=true \
    --affirmative="Yes" \
    --negative="No" || {
        msg_warning "Open code setup skipped."
        return 0
    }

    if [[ -s $HOME_DIR/.config/opencode/opencode.json ]]; then
        /usr/bin/mv -- "$HOME_DIR/.config/opencode/opencode.json" "$HOME_DIR/.config/opencode/opencode.json.bak" || {
            msg_error "Failed to backup existing Open Code settings."
            exit 1
        }
        msg_success "Existing Open Code settings backed up."
    fi

    if [[ -s $PROJECT_DIR/config/opencode/opencode.json ]]; then
        ln -sf -- "$PROJECT_DIR/config/opencode/opencode.json" "$HOME_DIR/.config/opencode/opencode.json" || {
            msg_error "Failed to create symlink for Open code settings."
            exit 1
        }
        msg_success "Open code settings symlink created."

        #  Run Omniroute Opencode Setup
        if  omniroute setup-opencode ; then
            msg_success "Omniroute Opencode setup completed successfully."
        else
            msg_error "Omniroute Opencode setup failed."
            exit 1
        fi
    else
        msg_warning "Open code settings file not found in project config."
    fi

    # Setup Codex
    gum confirm \
    "Do you want to setup Codex?" \
    --default=true \
    --affirmative="Yes" \
    --negative="No" || {
        msg_warning "Codex setup skipped."
        return 0
    }

    if [[ -s $HOME_DIR/.codex/config.toml ]]; then
        /usr/bin/mv -- "$HOME_DIR/.codex/config.toml" "$HOME_DIR/.codex/config.toml.bak" || {
            msg_error "Failed to backup existing Codex settings."
            exit 1
        }
        msg_success "Existing Codex settings backed up."
    fi

    if [[ -s $PROJECT_DIR/config/codex/config.toml ]]; then
        ln -sf -- "$PROJECT_DIR/config/codex/config.toml" "$HOME_DIR/.codex/config.toml" || {
            msg_error "Failed to create symlink for Codex settings."
            exit 1
        }
        msg_success "Codex settings symlink created."

        #  Run Omniroute Codex Setup
        if  omniroute setup-codex ; then
            msg_success "Omniroute Codex setup completed successfully."
        else
            msg_error "Omniroute Codex setup failed."
            exit 1
        fi
    else
        msg_warning "Codex settings file not found in project config."
    fi


    # Display banner again after all operations are complete.
    banner

    # Setup Docker Containers
    gum confirm \
    "Do you want to setup Docker containers?" \
    --default=true \
    --affirmative="Yes" \
    --negative="No" || {
        msg_warning "Docker containers setup skipped."
        return 0
    }

    setup_docker_containers || {
        msg_error "Failed to setup Docker containers."
        exit 1
    }

    # Display banner again after all operations are complete.
    banner

    # Setup Custom Bin Folder
    gum confirm \
    "Do you want to setup Custom Bin Folder?" \
    --default=true \
    --affirmative="Yes" \
    --negative="No" || {
        msg_warning "Custom Bin Folder setup skipped."
        return 0
    }

    local CUSTOM_BIN="$PROJECT_DIR/bin"
    if [[ ! -d "$CUSTOM_BIN" ]]; then
        msg_error "Custom bin directory not found: $CUSTOM_BIN"
        return 1
    fi

    ln -sf -- "$CUSTOM_BIN"/* "$HOME_DIR/.local/bin/" || {
        msg_error "Failed to create symlink for Custom Bin Folder."
        exit 1
    }

    # Display banner again after all operations are complete.
    banner

    # Setup Custom Omarchy Scripts Overwrites
    gum confirm \
    "Do you want to setup Custom Omarchy Scripts Overwrites?" \
    --default=true \
    --affirmative="Yes" \
    --negative="No" || {
        msg_warning "Custom Omarchy Scripts Overwrites setup skipped."
        return 0
    }

    local CUSTOM_SCRIPTS="$PROJECT_DIR/scripts"
    local OMARCHY_BIN="/usr/share/omarchy/bin"
    if [[ ! -d "$CUSTOM_SCRIPTS" ]]; then
        msg_error "Custom scripts directory not found: $CUSTOM_SCRIPTS"
        return 1
    fi

    # Omarchy Snapshot Script
    if [[ "$OMARCHY_BIN/omarchy-snapshot" ]]; then
        /usr/bin/mv -- "$OMARCHY_BIN/omarchy-snapshot" "$OMARCHY_BIN/omarchy-snapshot.bak"
        ln -sf -- "$CUSTOM_SCRIPTS/omarchy-snapshot" "$OMARCHY_BIN/omarchy-snapshot" || {
            msg_error "Failed to overwrite omarchy-snapshot script."
            exit 1
        }
    fi

    # Omarchy Windows Vm  Script
    if [[ "$OMARCHY_BIN/omarchy-windows-vm" ]]; then
        /usr/bin/mv -- "$OMARCHY_BIN/omarchy-windows-vm" "$OMARCHY_BIN/omarchy-windows-vm.bak"
        sudo install -m 755 "$CUSTOM_SCRIPTS/omarchy-windows-vm" "$OMARCHY_BIN/omarchy-windows-vm" || {
            msg_error "Failed to overwrite omarchy-windows-vm script."
            exit 1
        }
    fi

    # Custom Omarchy MacOs Vm Script
    if [[ "$OMARCHY_BIN/omarchy-macos-vm" ]]; then
        /usr/bin/mv -- "$OMARCHY_BIN/omarchy-macos-vm" "$OMARCHY_BIN/omarchy-macos-vm.bak"
        sudo install -Dm755 "$CUSTOM_SCRIPTS/omarchy-macos-vm" "$OMARCHY_BIN/omarchy-macos-vm" || {
            msg_error "Failed to overwrite omarchy-macos-vm script."
            exit 1
        }
    fi

    # Omarchy Fingerprint Setup
    if [[ "$OMARCHY_BIN/omarchy-fingerprint-setup" ]]; then
        /usr/bin/mv -- "$OMARCHY_BIN/omarchy-fingerprint-setup" "$OMARCHY_BIN/omarchy-fingerprint-setup.bak"
        ln -sf "$CUSTOM_SCRIPTS/omarchy-fingerprint-setup" "$OMARCHY_BIN/omarchy-fingerprint-setup" || {
            msg_error "Failed to overwrite omarchy-fingerprint-setup script."
            exit 1
        }
    fi
}

main "$@"
