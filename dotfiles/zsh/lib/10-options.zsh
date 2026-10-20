# =============================================================================
#                                ZSH Options
# ============================================================================= #

# --- Navigation & Globbing ---
setopt autocd             # Automatically cd into a directory if typed as a command
setopt glob_dots          # Include hidden files (dotfiles) in filename expansion
setopt numericglobsort    # Sort numeric filenames numerically rather than alphabetically

# --- Command Interaction ---
setopt correct            # Suggest corrections for misspelled command names
setopt auto_menu          # Show completion menu on a successive tab press
setopt complete_in_word   # Allow completion from the middle of a word
setopt interactive_comments # Allow comments starting with '#' in interactive shell

# --- Job Control & Notifications ---
setopt notify             # Report status of background jobs immediately

# --- History & Atuin Compatibility ---
unset HISTFILE            # Prevent Zsh from saving history to a local file
unsetopt share_history    # Stop sharing history between active terminal sessions
unsetopt append_history   # Disable appending commands to the Zsh history file
unsetopt inc_append_history # Stop writing commands to history as they are typed
unsetopt extended_history # Do not save timestamps or durations for commands
unsetopt bang_hist        # Disable legacy '!' history expansions (e.g., !!)
unsetopt hist_verify      # Turn off command verification before execution

# --- Plugin Configuration Variables ---
# Fallback to completion engine suggestions since local history file is empty
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
