# =============================================================================
#                              ZSH Plugin Manager
# ============================================================================= #

PLUG_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/plug/plug.git"
if [[ ! -d "$PLUG_HOME" ]]; then
    gum style --foreground 212 --border normal --padding "1 2" --margin "1 0" "Installing plug.zsh plugin manager..."
    if ! git clone --depth=1 https://github.com/Armoghan-ul-Mohmin/plug.git "$PLUG_HOME" > /dev/null 2>&1; then
        gum style --foreground 196 --border normal --padding "1 2" --margin "1 0" "Failed to install plug.zsh plugin manager. Please check your internet connection and try again."
    fi
fi
source "$PLUG_HOME/plug.zsh"

# =============================================================================
#                                ZSH Plugins
# ============================================================================= #

plug defer zsh-users/zsh-autosuggestions 100
plug defer Aloxaf/fzf-tab 500
plug defer zdharma-continuum/fast-syntax-highlighting 100
plug defer MichaelAquilina/zsh-you-should-use 500
plug omz command-not-found
plug omz copyfile

# =============================================================================
#                                 Plug Extra
# ============================================================================= #
# Order matters: fzf binds Ctrl+R first, atuin overrides it below.

plug eval add starship starship init zsh
plug eval add fzf fzf --zsh
plug eval add zoxide zoxide init zsh
plug eval add atuin atuin init zsh

plug completion gen atuin atuin gen-completions -s zsh
plug completion gen zellij zellij setup --generate-completion zsh

# =============================================================================
#                              Plugin Settings
# ============================================================================= #

export YSU_MESSAGE_POSITION="before"
if [[ -t 2 ]] && (( $+commands[tput] )); then
    YSU_MESSAGE_FORMAT="
$(tput bold)$(tput setaf 3)
Found existing %alias_type for \
$(tput setaf 5)\"%command\"$(tput setaf 3)
You should use: \
$(tput setaf 2)\"%alias\"$(tput sgr0)
"
fi
