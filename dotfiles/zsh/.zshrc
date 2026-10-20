# ============================================================ #
#                        Zsh Configuration                      #
# ============================================================ #
# Entry point. All real config lives in lib/*.zsh, sourced in  #
# alphabetical order. Keep this file tiny.                     #
#                                                              #
# Launch without installing (dev/testing):                     #
#   ZDOTDIR=/path/to/dotfiles/zsh zsh -i                       #
#   or simply: zsh-dev                                        #
# ============================================================ #

# Never run in non-interactive shells
[[ $- != *i* ]] && return

# Zsh hook for certine actions on certain events (e.g., chpwd, precmd, preexec)
autoload -U add-zsh-hook

# Set up zsh hooks
add-zsh-hook chpwd run_onefetch_on_cd
add-zsh-hook chpwd load_node_version

# Directory of this file — absolute and symlink-safe, so it
# works via ZDOTDIR, a symlink in ~/.zshrc, or a direct source.
typeset -g ZSHRC_DIR="${${(%):-%x}:A:h}"

if [[ ! -d "$ZSHRC_DIR/lib" ]]; then
    print -u2 -r -- "zshrc: lib/ not found next to .zshrc (expected: $ZSHRC_DIR/lib)"
    print -u2 -r -- "       If ~/.zshrc is a copy, replace it with a symlink to this file."
    return 1
fi
export ZSHRC_DIR

# Load modules in order
for _zshrc_module in "$ZSHRC_DIR"/lib/*.zsh(N); do
    source "$_zshrc_module"
done
unset _zshrc_module

# Load Secrets if available
if [[ -f "$HOME/.secrets.zsh" ]]; then
    source "$HOME/.secrets.zsh"
fi

# Run onefetch on directory change and load node version if applicable
run_onefetch_on_cd
load_node_version
