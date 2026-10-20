# =============================================================================
#                                   FZF-TAB
# ============================================================================= #

# Preview window layouts used by the fzf widgets below (--preview-window=...)
_fzf_preview_window='right:65%:wrap:border-rounded'
_fzf_custom_preview='right:50%:wrap:border-rounded'

# preview only for files and directories
zstyle ':fzf-tab:complete:*:*' fzf-preview '
    printf "\n\n"
    if [[ -d "${(Q)realpath}" ]]; then
        eza -lah \
            --tree \
            --level=2 \
            --group-directories-first \
            --icons=always \
            --color=always \
            --git \
            --git-ignore \
            --time-style=long-iso \
            --header \
            "${(Q)realpath}"
    elif [[ -f "${(Q)realpath}" ]]; then
        bat --color=always \
            --paging=never \
            --style=numbers,changes \
            --line-range=:200 \
            "${(Q)realpath}"
    fi
'

# no borders anywhere, preview on the right
_ftb_base=(--border=none --no-separator)
zstyle ':fzf-tab:*' fzf-flags $_ftb_base --preview-window=right:65%:wrap:noborder --height=98%

# Network/SSH: Preview connection configurations from your known hosts or ssh config
zstyle ':fzf-tab:complete:(ssh|ping|traceroute):*' fzf-preview 'getent hosts $word || grep -A 5 "Host $word" ~/.ssh/config'

# Env Variables: Show their active values in the preview window
zstyle ':fzf-tab:complete:(-parameter-|-set-|-export-):*' fzf-preview 'echo ${(P)word}'

# Show systemctl service unit statuses or logs dynamically
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'systemctl status --no-pager "$word" 2>/dev/null'

# View detailed network settings per interface (IP addresses, flags, state)
zstyle ':fzf-tab:complete:ip:*' fzf-preview 'ip addr show dev "$word" 2>/dev/null || ip route show'

# Git Objects: Show commit history logs or branch diffs
zstyle ':fzf-tab:complete:git-(log|diff|show|checkout):*' fzf-preview '
    case "$group" in
        "commit tag") git show --color=always $word ;;
        "branch") git log --color=always --oneline --graph -n 20 $word ;;
    esac'

# Peek inside zip files or tarballs without extracting them
zstyle ':fzf-tab:complete:*(tar|tgz|zip|unzip|gzip):*' fzf-preview '
    if [[ "$word" == *.zip ]]; then
        unzip -l "$word" 2>/dev/null
    elif [[ "$word" == *.tar.gz || "$word" == *.tgz ]]; then
        tar -tf "$word" 2>/dev/null
    fi'

# no preview pane for command names and for flags like --absolute
zstyle ':fzf-tab:complete:-command-:*' fzf-preview ''
zstyle ':fzf-tab:complete:-command-:*' fzf-flags $_ftb_base --preview-window=hidden
zstyle ':fzf-tab:complete:*:options' fzf-preview ''
zstyle ':fzf-tab:complete:*:options' fzf-flags $_ftb_base --preview-window=hidden

# Color completion entries using the same colors as eza/LS_COLORS
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Color the completion group descriptions
zstyle ':completion:*:descriptions' format '[%d]'

# tmux popup (only possible inside tmux), big enough for a side preview
if [[ -n $TMUX ]]; then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
    zstyle ':fzf-tab:*' popup-min-size 160 30
fi

# scroll the preview with Ctrl+D / Ctrl+U.
# NOTE: do NOT bind tab/shift-tab to "toggle" here — fzf-tab runs fzf with
# --multi, so a toggle binding marks every item you navigate past and Enter
# then inserts them all (random/multiple completions). Tab navigation and
# Ctrl+Space multi-select are provided by fzf-tab's default bindings.
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-d:preview-half-page-down' 'ctrl-u:preview-half-page-up'

# Ctrl+Alt+F — File / Directory Picker
fzf_file_dir_picker() {
    local selected
    selected=$(
        fd --hidden --follow \
            --exclude .git \
            --exclude node_modules \
            --exclude .venv \
            --exclude target \
            . 2>/dev/null |
        fzf \
            --prompt='󰈞 Files / Directories ❯ ' \
            --preview='printf "\n\n"; if [[ -d {} ]]; then eza -lah --group-directories-first --icons=always --color=always --git -- {}; else bat --color=always --paging=never --style=numbers --line-range=:300 -- {} 2>/dev/null || file -- {}; fi' \
            --preview-window="$_fzf_preview_window"
    ) || return

    [[ -n "$selected" ]] || return

    if [[ -d "$selected" ]]; then
        cd -- "$selected"
    else
        LBUFFER+="${(q)selected}"
    fi
    zle reset-prompt
}

# Ctrl+Alt+L — Git Log Search
fzf_git_log_search() {
    git rev-parse --is-inside-work-tree &>/dev/null || {
        zle -M "Not inside a Git repository"
        return 1
    }

    local commit
    commit=$(
        git log --color=always \
            --format='%C(auto)%h %C(cyan)%ad %C(auto)%s %C(green)(%an)%Creset' \
            --date=short |
        fzf --ansi \
            --prompt='󰊢 Git Log ❯ ' \
            --preview='printf "\n\n"; git show --color=always --stat --patch $(echo {} | awk "{print \$1}")' \
            --preview-window="$_fzf_preview_window"
    ) || return

    [[ -n "$commit" ]] || return

    local hash="${commit%% *}"
    LBUFFER+="git show ${(q)hash}"
    zle reset-prompt
}

# Ctrl+Alt+V — Shell Variables
fzf_shell_variables() {
    local selected name value
    selected=$(
        printenv |
        awk -F= '{print $1}' |
        sort -u |
        fzf \
            --prompt='󰘳 Variables ❯ ' \
            --preview='printf "\n\n"; printenv {} | bat --color=always --language=sh --style=plain 2>/dev/null || printenv {}' \
            --preview-window="$_fzf_preview_window"
    ) || return

    [[ -n "$selected" ]] || return

    value="${(P)selected}"
    LBUFFER+="${(q)value}"
    zle reset-prompt
}

# Ctrl+Alt+B — Git Branch Switcher
fzf_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || {
        zle -M "Not inside a Git repository"
        return 1
    }

    local branch
    branch=$(
        git branch --all --no-color |
        sed -E 's/^[* ]+//' |
        sed 's#^remotes/##' |
        awk '!seen[$0]++' |
        fzf --prompt='󰊢 Git Branch ❯ ' \
            --preview="printf '\n\n'; git log -8 --color=always --oneline --decorate {} 2>/dev/null || git show-branch {}" \
            --preview-window="$_fzf_custom_preview"
    ) || return

    [[ -n "$branch" ]] || return

    branch="${branch#remotes/}"
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git switch -- "$branch"
    elif git show-ref --verify --quiet "refs/remotes/$branch"; then
        git switch --track -c "${branch#*/}" "$branch"
    else
        zle -M "Branch not found: $branch"
        return 1
    fi

    zle reset-prompt
}

# Ctrl+Z — Zoxide Jump
fzf_zoxide_jump() {
    command -v zoxide &>/dev/null || {
        zle -M "Install zoxide first"
        return 1
    }

    local dir
    dir=$(zoxide query -i) || return
    [[ -n "$dir" && -d "$dir" ]] || return

    BUFFER="cd ${(q)dir}"
    zle accept-line
}
