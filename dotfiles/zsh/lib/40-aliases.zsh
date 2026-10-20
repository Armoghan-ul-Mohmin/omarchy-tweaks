# =============================================================================
#                               Custom Aliases
# ============================================================================= #

# ----------------------- Navigation & Directory Shortcuts -----------------------

# Parent directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias root='cd /'
alias back='cd -'

# Zoxide navigation
alias cd='z'
alias j='zoxide query'
alias ji='zoxide query -i'

# Common directories
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'
alias pictures='cd ~/Pictures'
alias videos='cd ~/Videos'
alias music='cd ~/Music'
alias work='cd ~/Work'
alias github='cd ~/GitHub'
alias clone='cd ~/GitHub/Clone'
alias projects='cd ~/Projects'

# Optional shortcuts
alias '~'='home'
alias '/'='root'

# ----------------------- File & Directory Listing -----------------------

# Detailed listings
alias l='eza -lah --icons=auto --group-directories-first --git-ignore'
alias ll='eza -lah --icons=auto --group-directories-first'
alias la='eza -a --icons=auto --group-directories-first'
alias ls='eza --icons=auto --group-directories-first'

# Filtered listings
alias lf='eza -lh --icons=always --only-files'
alias lh='eza -ld --icons=always .*(N)'
alias lsd='eza -lh --icons=always --only-dirs'

# ----------------------- Editors & Command Replacements -----------------------
alias nano='nvim'
alias vim='nvim'
alias vi='nvim'
alias emacs='nvim'

alias cat='bat'
alias htop='btop'
alias top='btop'
alias neofetch='fastfetch'
alias gitfetch='onefetch'
alias grep='grep --color=auto'
alias df='_df'
alias du='_du'

# ----------------------- Typo Corrections & Help -----------------------
alias sl='ls'
alias please='sudo'
alias help='man'
alias where='which'
alias tl='tldr'

# ----------------------- System Information & Monitoring -----------------------
alias mem='_mem'
alias cpuinfo='lscpu'
alias dl='curl -fLO'
alias lanip="_lanip"
alias wanip="_wanip"
alias weather='curl -fsS wttr.in'
alias ports="_ports"
alias portkill="_portkill"
alias ips="_ips"
alias path="_path"
alias aliass="_alias"

# ----------------------- Hashing Utilities -----------------------
alias md5='md5sum'
alias sha1='sha1sum'
alias sha256='sha256sum'
alias sha512='sha512sum'
alias hash="_hash"

# ----------------------- Applications -----------------------
alias zj='zellij'
alias lg='lazygit'
alias tj='tmux'

# ----------------------- Git Shortcuts -----------------------
alias g='git'
alias gst='git status'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log'
alias glogp='git log --oneline --graph --decorate -20'
alias gadd='git add'
alias gdiff='git diff'
alias gco='_gcheckout'
alias gsh='git stash'
alias gshp='git stash pop'
alias gshl='git stash list'
alias gfetch="_gfetch"
alias gpull="_gpull"
alias gpush="_gpush"
alias gcommit="_gcommit"
alias gcomit="_gcomit"
alias gclone="_gclone"
alias gbranch="_gbranch"
alias gamend="_gamend"

# ----------------------- Shell -----------------------
alias reload='exec zsh'
alias cls='clear'
alias mkdir='mkdir -p'
alias dirs='dirs -v'
alias rm="remove"
alias new="new_file"
alias rn="rename"
alias cp="copy"
alias mv="move"
alias mkcd="_mkcd"

# ----------------------- History Exclusions -----------------------
# Commands prefixed with these aliases can be excluded from Atuin history
alias nh=' '
alias ,=' '

# ----------------------- Miscellaneous -----------------------
alias edit="edit_file"
alias open="_open"
alias here="_here"
alias edit-here="_edit-here"
alias bk="backup"
alias tmpdir="_tmpdir"
alias bigfiles="_bigfiles"
alias note="_note"
alias notes="_notes"
alias zshrc="edit_zshrc"
