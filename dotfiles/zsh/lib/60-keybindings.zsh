# =============================================================================
#                                 Keybindings
# ============================================================================= #

# Set default keybindings to emacs mode (for consistency across systems)
bindkey -e

# Generic TUI runner
run-tui() {
    zle -I

    local tty="/dev/tty"

    # Give the TUI direct access to the real terminal
    echo
    "$@" <"$tty" >"$tty" 2>&1
    echo
    echo
    echo
    # Make sure the terminal is sane after the TUI exits
    stty sane <"$tty" 2>/dev/null

    zle reset-prompt
    zle redisplay
}

# Zellij Session Manager
zij-widget() { run-tui zij }

# Tmux Session Manager
tij-widget() { run-tui tij }

# Hastebin
hb-widget() { run-tui hastebin }

# Lazygit
lazygit-widget() { run-tui lazygit }

# SPF
spf-widget() { run-tui spf }

# Neovim
nvim-widget() { run-tui nvim }

# VS Code
code-widget() { run-tui code }

# keybind-help
keybind-widget() { run-tui keybind-help }

# Run Local Server
server-widget() { run-tui server }

# Atuin Ai
atuin-ai() { run-tui atuin ai inline }

# Find File
fzf-widget() {
    local selected

    selected=$(fd --type f --hidden --exclude .git |
        fzf \
            --height 85% \
            --layout=reverse \
            --border=rounded \
            --prompt='  Files ❯ ' \
            --preview='bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null') || return

    LBUFFER+="${(q)selected}"
    zle redisplay
}

zle -N zij-widget
zle -N tij-widget
zle -N hb-widget
zle -N lazygit-widget
zle -N spf-widget
zle -N nvim-widget
zle -N code-widget
zle -N keybind-widget
zle -N fzf-widget
zle -N server-widget
zle -N atuin-ai
zle -N fzf_file_dir_picker
zle -N fzf_git_log_search
zle -N fzf_shell_variables
zle -N fzf_git_branch
zle -N fzf_zoxide_jump

# Alt + H → Hastebin
bindkey -M emacs '^[h' hb-widget

# Alt + G → Lazygit
bindkey -M emacs '^[g' lazygit-widget

# Alt + K → VS Code
bindkey -M emacs '^[k' code-widget

# Alt + N → Neovim
bindkey -M emacs '^[n' nvim-widget

# Alt + S → SPF
bindkey -M emacs '^[s' spf-widget

# Alt + T → Tmux Session Manager
bindkey -M emacs '^[t' tij-widget

# Alt + Z → Zellij Session Manager
bindkey -M emacs '^[z' zij-widget

# ALT + F → Find File (fzf)
bindkey -M emacs '^[f' fzf-widget

# ALT + Q → Run Local Server
bindkey -M emacs '^[q' server-widget

# Ctrl + R → Atuin Search
bindkey -M emacs '^R' atuin-search
bindkey -M viins '^R' atuin-search-viins

# ALT + ? or ALT + / → KEYBINDINGS Helper TUI
bindkey -M emacs '^[?' keybind-widget
bindkey -M emacs '^[/' keybind-widget

# ? → Atuin Ai Inline
bindkey -M emacs '?' atuin-ai

# Ctrl + Alt + F → File / Directory Picker
bindkey '^[^F' fzf_file_dir_picker

# Ctrl + Alt + L → Git Log Search
bindkey '^[^L' fzf_git_log_search

# Ctrl + Alt + V → Shell Variables
bindkey '^[^V' fzf_shell_variables

# Ctrl + Alt + B → Git Branches
bindkey '^[^B' fzf_git_branch

# Ctrl + Z → Zoxide Jump
bindkey '^Z' fzf_zoxide_jump
