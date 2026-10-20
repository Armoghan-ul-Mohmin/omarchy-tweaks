# =============================================================================
#                           Environment Variables
# ============================================================================= #

export EDITOR='nvim'
export VISUAL='nvim'
export SUDO_EDITOR='nvim'

# PAGER settings
export PAGER='less'
export LESS='-FRX'
export LESSHISTFILE='-'

# GPG Settigs
export GPG_TTY=$(tty)

# Bat/Manpage settings
export BAT_THEME='Catppuccin Macchiato'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Fzf settings
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .venv --exclude target'
export FZF_CTRL_T_OPTS="--preview-window=right:65%:border-rounded,wrap"
export FZF_ALT_C_OPTS="
    --preview='printf \"\n\n\"; eza -lah --group-directories-first --icons=always --color=always --git --tree -- {}'
    --preview-window=right,60%,border-rounded,wrap
"
export FZF_DEFAULT_OPTS="
    --height 75%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt='❯ '
    --marker='✓'
    --pointer='▶'
    --separator='─'
    --scrollbar='┃'
    --info=inline
    --preview='printf \"\n\n\"; bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || ls -lah -- {}'
    --preview-window=right,65%,border-rounded,wrap
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5c2e7
    --color=marker:#a6e3a1,fg+:#cdd6f4,prompt:#89b4fa,hl+:#f38ba8
"

# Plug.zsh settings
export PLUG_JOBS=4
export PLUG_QUIET=1
export PLUG_COMPINIT=1
export PLUG_MAX_LOG_SIZE=1048576
export PLUG_OMZ_LIB='functions clipboard'

# path
export PATH="$HOME/.omarchy-tweaks/bin:$PATH"

# Starship — config lives next to these dotfiles (For Developement Only)
export STARSHIP_CONFIG="${ZSHRC_DIR:h}/starship/starship.toml"
