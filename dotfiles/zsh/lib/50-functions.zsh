# =============================================================================
#                              Custom Functions
# ============================================================================= #

# ----------------------- Gum UI Helpers -----------------------

_gum_ok() {
    gum style --foreground 2 "󰄬  $*"
}

_gum_info() {
    gum style --foreground 6 "$*"
}

_gum_warn() {
    gum style --foreground 3 "󰀦  $*"
}

_gum_error() {
    gum style --foreground 1 --bold "󰅚  $*" >&2
}

# ----------------------- Open & Edit -----------------------

# Open files in $EDITOR (was an alias using $1, which aliases cannot expand)
edit_file() {
    $EDITOR -- "$@"
}

# Open files/directories with the default application
_open() {
    [[ $# -ge 1 ]] || { gum style --foreground 1 --bold "Usage: open <PATH>..."; return 1 }
    xdg-open -- "$@" >/dev/null 2>&1 &!
}

# Open current directory with the default application
_here() {
    xdg-open . >/dev/null 2>&1 &!
}

# Open current directory in VS Code
_edit-here() {
    code .
}

# ----------------------- Git (gum-powered) -----------------------

# Fetch from remote
_gfetch() {
    emulate -L zsh
    print
    _gum_info "󰊢  Fetching from remote..."
    command git fetch "$@"
    local git_status=$?

    if (( git_status == 0 )); then
        _gum_ok "Fetch complete"
    else
        _gum_error "Fetch failed (exit $git_status)"
    fi

    return $git_status
}

# Pull from remote
_gpull() {
    emulate -L zsh
    print
    _gum_info "󰊢  Pulling from remote..."
    command git pull "$@"
    local git_status=$?

    if (( git_status == 0 )); then
        _gum_ok "Pull complete"
    else
        _gum_error "Pull failed (exit $git_status)"
    fi

    return $git_status
}

# Push to remote
_gpush() {
    emulate -L zsh
    print
    _gum_info "󰊢  Pushing to remote..."
    command git push "$@"
    local git_status=$?

    if (( git_status == 0 )); then
        _gum_ok "Push complete"
    else
        _gum_error "Push failed (exit $git_status)"
    fi

    return $git_status
}

# Commit with an optional interactive message
_gcommit() {
    local msg="${*:-}"
    echo

    [ -n "$msg" ] || msg="$(gum input \
        --header="Enter commit message" \
        --prompt="> " \
        --placeholder="Initial commit")" || return 1

    [ -n "$msg" ] || return 1
    git commit -m "$msg"
}

# Clone a repository interactively
_gclone() {
    local repo="${*:-}"
    echo

    [ -n "$repo" ] || repo="$(gum input \
        --header="Enter repository URL" \
        --prompt="> " \
        --placeholder="https://github.com/user/repo.git")" || return 1

    [ -n "$repo" ] || return 1
    git clone "$repo"
}

# Checkout a branch
_gcheckout() {
    local branch="${*:-}"
    echo

    [ -n "$branch" ] || branch="$(gum input \
        --header="Enter branch name" \
        --prompt="> " \
        --placeholder="feature-branch")" || return 1

    [ -n "$branch" ] || return 1
    git checkout "$branch"
}

# Interactive branch switching
_gbranch() {
    echo
    local branch

    branch="$(git branch --format='%(refname:short)' |
        gum choose --header="Git Branches")" || return 1

    [ -n "$branch" ] && git switch "$branch"
}

# Conventional commit helper
_gcomit() {
    local type scope msg body
    echo

    type="$(gum choose --header="Commit Type" \
        fix feat docs style refactor test chore revert)" || return 1

    scope="$(gum input --header="Scope" --placeholder="optional")" || return 1
    [ -n "$scope" ] && scope="($scope)"

    msg="$(gum input --header="Commit Message" \
        --placeholder="summary" --value="${type}${scope}: ")" || return 1

    [ -n "$msg" ] || {
        gum style --foreground 1 --bold "Error: commit message cannot be empty."
        return 1
    }

    body="$(gum write --header="Commit Body" \
        --placeholder="optional long description")" || return 1

    if [ -n "$body" ]; then
        git commit -m "$msg" -m "$body"
    else
        git commit -m "$msg"
    fi
}

# Amend the latest commit
_gamend() {
    local msg body
    echo

    msg="$(gum input --header="Amend Commit Message" \
        --placeholder="summary" \
        --value="$(git log -1 --pretty=%s)")" || return 1

    [ -n "$msg" ] || {
        gum style --foreground 1 --bold "Error: commit message cannot be empty."
        return 1
    }

    body="$(gum write --header="Commit Body" \
        --placeholder="optional long description" \
        --value="$(git log -1 --pretty=%b)")" || return 1

    if [ -n "$body" ]; then
        git commit --amend -m "$msg" -m "$body"
    else
        git commit --amend -m "$msg"
    fi
}

# ----------------------- Interactive File Operations -----------------------

# Delete with confirmation
remove() {
    if [[ $# -eq 0 ]]; then
        gum style --foreground 1 --bold "Usage: rm <FILE>"
        return 1
    fi
    echo
    gum confirm "Delete: $*?" || return 1
    command rm -v "$@"
}

# Create empty files with confirmation
new_file() {
    if [[ $# -eq 0 ]]; then
        gum style --foreground 1 --bold "Usage: new <FILE>"
        return 1
    fi
    echo
    gum confirm "Create: $*?" || return 1
    command touch -- "$@" && echo "Created: $*"
}

# Rename with confirmation
rename() {
    [ "$#" -eq 2 ] || {
        gum style --foreground 1 --bold "Usage: rn <SOURCE> <DEST>"
        return 1
    }

    echo
    gum confirm "Rename '$1' to '$2'?" || return 1
    command mv -v -- "$1" "$2"
}

# Copy with confirmation
copy() {
    if [[ $# -lt 2 ]]; then
        gum style --foreground 1 --bold "Usage: cp <SOURCE>... <DEST>"
        return 1
    fi
    echo
    gum confirm "Copy: $*?" || return 1
    command cp -v -- "$@"
}

# Move with confirmation
move() {
    if [[ $# -lt 2 ]]; then
        gum style --foreground 1 --bold "Usage: mv <SOURCE> <DEST>"
        return 1
    fi
    echo
    gum confirm "Move: $*?" || return 1
    command mv -v -- "$@"
}

# Backup a file with a timestamp (no confirmation, no wrapping)
backup() {
    [ "$#" -ge 1 ] || {
        gum style --foreground 1 --bold "Usage: bak <FILE>..."
        return 1
    }

    local f dst
    for f in "$@"; do
        if [[ ! -e "$f" ]]; then
            gum style --foreground 1 --bold "No such file: $f"
            continue
        fi
        dst="${f}.bak-$(date +%Y%m%d-%H%M%S)"
        if command cp -p -- "$f" "$dst"; then
            gum style --foreground 2 "Backed up: $f → $dst"
        else
            gum style --foreground 1 --bold "Failed to back up: $f"
        fi
    done
}

# Create a directory and enter it
_mkcd() {
    local dir="${1:-}"
    echo

    [ -n "$dir" ] || dir="$(gum input \
        --prompt="Enter directory name: ")" || return 1

    [ -n "$dir" ] || {
        gum style --foreground 1 --bold "Error: directory name cannot be empty."
        return 1
    }

    mkdir -p -- "$dir" &&
        cd -- "$dir" &&
        gum style --foreground 2 "Created and moved into: $PWD"
}

# Create a temp directory and enter it
_tmpdir() {
    local dir
    dir="$(mktemp -d)" || return 1

    (
        cd "$dir" || exit 1
        gum style --foreground 2 "Temp dir: $PWD"
        gum style --foreground 245 "Press Ctrl+D to exit and delete the temp directory."
        zsh
    )

    command rm -rf -- "$dir"
}

# ----------------------- Network -----------------------

# Beautiful listening-ports viewer
_ports() {
    local filter="${1:-}" rows

    rows="$(ss -tulwnpH 2>/dev/null | awk '
        {
            proto=$1; state=$2; local_addr=$5; peer=$6; proc="-";
            if (match($0, /users:\(\("[^"]+"/)) {
                proc=substr($0, RSTART+9, RLENGTH-10);
                gsub(/"/, "", proc);
            }
            printf "%s\t%s\t%s\t%s\t%s\n", proto, state, local_addr, peer, proc;
        }
    ')"

    if [ -z "$rows" ]; then
        gum style --foreground 2 "No listening sockets."
        return 0
    fi

    if [ -n "$filter" ]; then
        rows="$(print -r -- "$rows" | grep -i -- "$filter")"
        [ -n "$rows" ] || {
            gum style --foreground 1 --bold "No sockets matching: $filter"
            return 1
        }
    fi

    print -r -- "$rows" |
        gum table --print --separator=$'\t' \
            --columns "PROTO","STATE","LOCAL","PEER","PROCESS" \
            --widths 6,9,26,26,24

    local count=${#${(f)rows}}
    gum style --foreground 245 "$count socket(s)${filter:+ matching '$filter'}"
}

# Kill whatever is listening on a port (interactive picker if no arg)
_portkill() {
    local port="${1:-}" pids line local_addr

    echo

    if [ -z "$port" ]; then
        line="$(ss -tulwnpH 2>/dev/null |
            gum filter --header="Kill whatever listens on a port (Esc to cancel)")" || return 1
        [ -n "$line" ] || return 1
        local_addr="${${(z)line}[5]}"
        port="${local_addr##*:}"
    fi

    [[ "$port" == <-> ]] || {
        gum style --foreground 1 --bold "Invalid port: $port"
        return 1
    }

    pids="$(ss -tlnpH "sport = :$port" 2>/dev/null |
        grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u)"

    [ -n "$pids" ] || {
        gum style --foreground 1 --bold "Nothing is listening on port $port"
        return 1
    }

    echo
    gum confirm "Kill process on port $port (PID(s): ${(j:, :)pids})?" || return 1

    local pid
    for pid in ${(f)pids}; do
        if kill "$pid" 2>/dev/null; then
            gum style --foreground 2 "Killed PID $pid"
        else
            gum style --foreground 1 --bold "Failed to kill PID $pid (need sudo?)"
        fi
    done
}

# ----------------------- Network -----------------------

# Show network addresses nicely
#   ips         LAN + gateway + public IP
#   ips -a      every interface, plus gateway
_ips() {
    local lan gw pub rows

    gw="$(ip route show default 2>/dev/null | awk '/default/{print $3; exit}')"

    if [[ "${1:-}" == (-a|--all) ]]; then
        rows="$(ip -4 -o addr show 2>/dev/null | awk '{
            split($4, a, "/"); printf "%s\t%s\n", $2, a[1]
        }')"
        [ -n "$rows" ] || {
            gum style --foreground 1 --bold "No interfaces found"
            return 1
        }

        echo
        print -r -- "$rows" |
            gum table --print --separator=$'\t' \
                --columns "󰆍 INTERFACE","󰩟 ADDRESS" --widths 12,44
        gum style --foreground 245 "Gateway: ${gw:-?}"
        return 0
    fi

    lan="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')"
    pub="$(curl -fsS --max-time 5 https://ipinfo.io/ip 2>/dev/null)" || pub="unreachable"

    echo
    printf 'LAN\t%s\nGATEWAY\t%s\nPUBLIC\t%s\n' \
        "${lan:-?}" "${gw:-?}" "${pub:-?}" |
        gum table --print --separator=$'\t' \
            --columns "󰀂 NETWORK","󰩟 ADDRESS" --widths 10,44
}

# LAN IP — Local network address
_lanip() {
    local ip
    ip="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')"

    if [[ -z "$ip" ]]; then
        gum style --border rounded --border-foreground  red \
            --foreground  red --padding "0 2" \
            "󰌘  Unable to detect LAN IP"
        return 1
    fi

    echo
    gum style \
        --border rounded \
        --border-foreground 75 \
        --padding "1 3" \
        --margin "0 1" \
        "$(gum style --foreground 75 --bold '󰩟  LAN IP')"$'\n'"$(gum style --foreground 114 --bold "$ip")"
}

# Show the public IP address
_wanip() {
    local ip
    ip="$(curl -4 -fsS --max-time 5 https://ipinfo.io/ip 2>/dev/null)" || {
        gum style --border rounded --border-foreground  red \
            --foreground  red --padding "0 2" \
            "󰖟  Unable to fetch public IP"
        return 1
    }

    ip="${ip//$'\n'/}"

    echo
    gum style \
        --border rounded \
        --border-foreground 141 \
        --padding "1 3" \
        --margin "0 1" \
        "$(gum style --foreground 141 --bold '󰖟  WAN IP')"$'\n'"$(gum style --foreground 114 --bold "$ip")"
}
# ----------------------- Disk Usage -----------------------

# Largest items in a directory with % of the total (default: current)
_du() {
    local dir="${1:-.}" out total total_human dir_name

    # Resolve directory name for display
    dir_name="${dir:A:t}"
    [[ -n "$dir_name" ]] || dir_name="/"

    out="$(command du -B1 -d 1 -- "$dir" 2>/dev/null |
        sort -nr | tail -n +2 | head -30)"

    total="$(command du -B1 -s -- "$dir" 2>/dev/null |
        awk '{print $1}')"

    if [[ -z "$out" ]]; then
        gum style --foreground 2 "No disk usage to show for: $dir_name"
        return 0
    fi

    total_human="$(awk -v b="${total:-0}" '
        BEGIN {
            split("B KiB MiB GiB TiB", u, " ")
            i = 1
            while (b >= 1024 && i < 5) { b /= 1024; i++ }
            if (i == 1) printf "%d %s", b, u[i]
            else printf "%.1f %s", b, u[i]
        }
    ')"

    echo
    gum style --bold --foreground 6 " 󰋊 Disk Usage"

    gum style --foreground 7 "  Directory: $dir_name  •  Total: $total_human"
    echo

    print -r -- "$out" | awk -F '\t' -v total="${total:-0}" '
        function human(b, u, i) {
            split("B KiB MiB GiB TiB", u, " ")
            i = 1
            while (b >= 1024 && i < 5) { b /= 1024; i++ }
            return (i == 1) ? sprintf("%d %s", b, u[i]) : sprintf("%.1f %s", b, u[i])
        }
        {
            pct = (total > 0) ? $1 * 100 / total : 0
            path = $2
            sub(/^\.\//, "", path)
            printf "%s\t%.1f%%\t%s\n", human($1), pct, path
        }
    ' | gum table --print --separator=$'\t' \
        --columns "󰁹 SIZE","󰓅 USED","󰉋 DIRECTORY" \
        --widths 16,10,48
}

# Disk space usage of mounted filesystems
_df() {
    local out

    out="$(command df -h --output=source,size,used,avail,pcent,target 2>/dev/null)" || {
        gum style --foreground 1 "Failed to read disk space"
        return 1
    }

    echo
    gum style --bold --foreground 6 " 󰋊 Disk Space"
    gum style --foreground 7 "  Mounted filesystems and available storage"
    echo

    print -r -- "$out" | awk '
        NR == 1 { next }
        {
            source = $1
            size = $2
            used = $3
            avail = $4
            pct = $5
            mount = $6

            # Reassemble mount points containing spaces
            for (i = 7; i <= NF; i++)
                mount = mount " " $i

            printf "%s\t%s\t%s\t%s\t%s\t%s\n",
                source, size, used, avail, pct, mount
        }
    ' | gum table --print --separator=$'\t' \
        --columns "󰋊 FILESYSTEM","󰁹 SIZE","󰓅 USED","󰁹 FREE","󰊚 USE%","󰉋 MOUNT" \
        --widths 28,10,10,10,8,32
}

# Largest files under a directory
_bigfiles() {
    local dir="${1:-.}" out dir_name count total

    dir_name="${dir:A:t}"
    [[ -n "$dir_name" ]] || dir_name="/"

    # Find the largest files, preserving filenames safely
    out="$(
        fd --type f --hidden --follow \
            --exclude .git \
            --exclude node_modules \
            --exclude .venv \
            --exclude target \
            --print0 . "$dir" 2>/dev/null |
        xargs -0 -r du -b 2>/dev/null |
        sort -nr |
        head -20 |
        awk '
            function human(b, u, i) {
                split("B KiB MiB GiB TiB", u, " ")
                i = 1
                while (b >= 1024 && i < 5) { b /= 1024; i++ }
                return (i == 1) ? sprintf("%d %s", b, u[i]) : sprintf("%.1f %s", b, u[i])
            }
            {
                size = $1
                $1 = ""
                sub(/^[[:space:]]+/, "")
                path = $0
                sub(/^\.\//, "", path)
                printf "%s\t%s\t%s\n", human(size), size, path
            }
        '
    )"

    if [[ -z "$out" ]]; then
        gum style --foreground 2 "No files found in: $dir_name"
        return 0
    fi

    count="$(print -r -- "$out" | wc -l | tr -d ' ')"
    total="$(print -r -- "$out" | awk -F '\t' '{sum += $2} END {print sum+0}')"

    local total_human
    total_human="$(awk -v b="$total" '
        BEGIN {
            split("B KiB MiB GiB TiB", u, " ")
            i = 1
            while (b >= 1024 && i < 5) { b /= 1024; i++ }
            if (i == 1) printf "%d %s", b, u[i]
            else printf "%.1f %s", b, u[i]
        }
    ')"

    echo
    gum style --bold --foreground 6 " 󰈙 Largest Files"
    gum style --foreground 7 "  Directory: $dir_name  •  Showing: $count files  •  Combined size: $total_human"
    echo

    print -r -- "$out" |
        awk -F '\t' 'BEGIN { OFS="\t" } { print $1, $3 }' |
        gum table --print --separator=$'\t' \
            --columns "󰁹 SIZE","󰈙 FILE" \
            --widths 16,72
}

# ----------------------- Memory -----------------------
_mem() {
    local out

    out="$(command free -m 2>/dev/null)" || {
        gum style --foreground 1 "Failed to read memory usage"
        return 1
    }

    print
    gum style --bold --foreground 6 " 󰍛 Memory Usage"
    gum style --foreground 7 "   RAM and swap statistics"
    print

    print -r -- "$out" | awk '
        BEGIN {
            OFS = "\t"
        }

        /^Mem:/ {
            printf "RAM\t%s MiB\t%s MiB\t%s MiB\t%s MiB\t%s MiB\t%s MiB\n",
                $2, $3, $4, $5, $6, $7
        }

        /^Swap:/ {
            printf "SWAP\t%s MiB\t%s MiB\tN/A\tN/A\tN/A\tN/A\n",
                $2, $3, $4
        }
    ' | gum table --print --separator=$'\t' \
        --columns "󰉺 TYPE","󰪚 TOTAL","󰄉 USED","󰁹 FREE","󰍛 SHARED","󰆼 BUFF/CACHE","󰒋 AVAILABLE" \
        --widths 12,16,16,16,16,16,18
}

# ----------------------- Notes & Hashing -----------------------

# Quick capture, search, recent notes & management
_note() {
    emulate -L zsh

    local file="${NOTES_FILE:-$HOME/Documents/notes.md}"
    local action title body tags query selected line preview_cmd
    local stamp
    local -a matches

    (( $+commands[gum] )) || {
        print -u2 "󰅚  Error: gum is required."
        return 1
    }

    command mkdir -p -- "${file:h}" || return 1
    [[ -e "$file" ]] || : > "$file" || return 1

    # ── Dashboard ────────────────────────────────────────────────
    if [[ -n "${1:-}" ]]; then
        action="$1"
    else
        gum style \
            --border rounded \
            --border-foreground 6 \
            --padding "1 2" \
            --margin "0 0 1 0" \
            "$(gum style --bold --foreground 6 '󰠮  NOTES')"$'\n'\
            "$(gum style --foreground 7 "󰈙  ${file:t}  ·  $(wc -l < "$file" | tr -d ' ') lines")"$'\n'\
            "$(gum style --foreground 8 "${file:h}")"

        action=$(gum choose \
            --cursor="➜ " \
            --cursor.foreground 6 \
            --selected.foreground 6 \
            --header="What would you like to do?" \
            "󰏫  New note" \
            "󰍉  Search notes" \
            "󰄉  Recent notes" \
            "󰈔  Open notes file") || return 0
    fi

    case "$action" in
        "󰏫  New note"|"New note"|new)
            title=$(gum input \
                --header="󰏫  New note" \
                --prompt="Title  " \
                --placeholder="What is this note about?") || return 0

            # Trim surrounding whitespace.
            title="${title##[[:space:]]#}"
            title="${title%%[[:space:]]#}"

            [[ -n "$title" ]] || {
                gum style --foreground 1 "󰅚  A title is required."
                return 1
            }

            body=$(gum write \
                --width 80 \
                --char-limit 0 \
                --placeholder="Write something worth remembering..." \
                --header="󰓝  $title · Ctrl+D saves · Esc cancels") ||
                return 0

            [[ -n "${body//[[:space:]]/}" ]] || {
                gum style --foreground 3 "󰋔  Empty note discarded."
                return 0
            }

            tags=$(gum input \
                --header="󰓹  Add tags (optional)" \
                --prompt="Tags  " \
                --placeholder="work, ideas, personal") || tags=""

            stamp=$(date '+%Y-%m-%d %H:%M')

            {
                print -r -- "## $title"
                print -r -- "<!-- $stamp -->"
                [[ -z "$tags" ]] || print -r -- "**Tags:** $tags"
                print
                print -r -- "$body"
                print
                print
            } >> "$file" || {
                gum style --foreground 1 "󰅚  Failed to save note."
                return 1
            }

            gum style \
                --border rounded \
                --border-foreground 2 \
                --padding "1 2" \
                "$(gum style --bold --foreground 2 '󰄬  Note saved successfully')"$'\n'\
                "$(gum style --foreground 7 "$title")"$'\n'\
                "$(gum style --foreground 8 "󰥔  $stamp")"
            ;;

        "󰍉  Search notes"|"Search notes"|search)
            (( $+commands[rg] )) || {
                gum style --foreground 1 "󰅚  Install ripgrep (rg) to search notes."
                return 1
            }

            query=$(gum input \
                --header="󰍉  Search your notes" \
                --prompt="Search  " \
                --placeholder="Type keywords to find...") || return 0

            [[ -n "$query" ]] || return 0

            if (( $+commands[bat] )); then
                preview_cmd="bat --color=always --style=numbers --language=markdown --highlight-line {1} ${(q)file}"
            else
                preview_cmd="awk 'NR >= {1}-8 && NR <= {1}+12 {printf \"%5d  %s\\n\", NR, \$0}' ${(q)file}"
            fi

            selected=$(
                command rg -n -i -F -- "$query" "$file" |
                    fzf \
                        --delimiter=: \
                        --with-nth=2.. \
                        --prompt='󰍉  Search > ' \
                        --header='↑↓ Navigate · Enter View · Esc Back' \
                        --height=85% \
                        --layout=reverse \
                        --border=rounded \
                        --preview="$preview_cmd" \
                        --preview-window='right,60%,border-left' \
                        --preview-label=' 󰈙  Note Preview '
            ) || return 0

            line="${selected%%:*}"

            if [[ "$line" == <-> ]]; then
                if (( $+commands[bat] )); then
                    bat --paging=always --style=numbers \
                        --language=markdown \
                        --highlight-line "$line" "$file"
                else
                    sed -n "$(( line > 5 ? line - 5 : 1 )),$(( line + 12 ))p" "$file" |
                        gum pager
                fi
            fi
            ;;

        "󰄉  Recent notes"|"Recent notes"|recent)
            local recent

            if (( $+commands[rg] )); then
                recent=$(rg -n '^## ' "$file" | tail -20)
            else
                recent=$(grep -n '^## ' "$file" | tail -20)
            fi

            if [[ -z "$recent" ]]; then
                gum style --foreground 3 "󰋔  No notes found yet."
                return 0
            fi

            gum style \
                --border rounded \
                --border-foreground 6 \
                --padding "0 2" \
                --bold "󰄉  Recent Notes"

            print -r -- "$recent" |
                gum pager --show-line-numbers
            ;;

        "󰈔  Open notes file"|"Open notes file"|open)
            _notes
            ;;

        *)
            gum style --foreground 1 "󰅚  Unknown action: $action"
            return 1
            ;;
    esac
}

# Open the notes file in $EDITOR
_notes() {
    emulate -L zsh

    local file="${NOTES_FILE:-$HOME/Documents/notes.md}"
    local editor="${VISUAL:-${EDITOR:-nvim}}"
    local -a editor_cmd

    command mkdir -p -- "${file:h}" || return 1

    if [[ ! -f "$file" ]]; then
        : > "$file" || return 1
        gum style --foreground 2 "󰄬  Created ${file:t}"
    fi

    # Allow EDITOR values containing arguments, e.g. "code --wait".
    editor_cmd=("${(@z)editor}")

    (( ${#editor_cmd} )) || editor_cmd=(vi)

    if (( $+commands[gum] )); then
        gum style \
            --border rounded \
            --border-foreground 6 \
            --padding "1 2" \
            "$(gum style --bold --foreground 6 '󰈔  NOTES EDITOR')"$'\n'\
            "$(gum style --foreground 7 "󰈙  ${file:t}")"$'\n'\
            "$(gum style --foreground 8 "󰉋  ${file:h} · $(wc -l < "$file" | tr -d ' ') lines")"
    fi

    "${editor_cmd[@]}" "$file"
}

# Hash files and folders
_hash() {
    emulate -L zsh
    setopt pipefail

    local target algo file sum_cmd
    local -a algorithms

    # Pick a file or folder with fzf
    if (( $# == 0 )); then
        target="$(
            find . -mindepth 1 -maxdepth 1 -print 2>/dev/null |
                sort |
                fzf --prompt="󰊢 Hash > " \
                    --header="󰈔 Select a file or directory" \
                    --height=40% \
                    --reverse \
                    --border \
                    --preview='
                        if [[ -d {} ]]; then
                            eza -lah --tree --level=2 \
                                --group-directories-first \
                                --icons=always --color=always \
                                --git --git-ignore \
                                --time-style=long-iso --header {}
                        elif [[ -f {} ]]; then
                            bat --color=always --paging=never \
                                --style=numbers,changes \
                                --line-range=:200 {}
                        fi
                    ' \
                    --preview-window=right:60%
        )" || return 0

        [[ -n "$target" ]] || return 0
    else
        target="$1"
    fi

    # Validate target
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        print -u2 -- "󰅚 Path not found: $target"
        return 1
    fi

    if [[ ! -f "$target" && ! -d "$target" ]]; then
        print -u2 -- "󰅚 Unsupported file type: $target"
        return 1
    fi

    # Select hash algorithm with gum
    if (( $# >= 2 )); then
        algo="${2:l}"
    else
        algo="$(
            gum choose \
                --header="󰕥 Choose Hash Algorithm" \
                "󰒋 md5" \
                "󰒋 sha1" \
                "󰒋 sha256" \
                "󰒋 sha512" \
                "󰓆 all"
        )" || return 0

        [[ -n "$algo" ]] || return 0

        # Strip the decorative icon from the selection
        algo="${algo#* }"
    fi

    case "$algo" in
        md5|sha1|sha256|sha512)
            algorithms=("$algo")
            ;;
        all)
            algorithms=(md5 sha1 sha256 sha512)
            ;;
        *)
            print -u2 -- "󰅚 Unsupported algorithm: $algo"
            print -u2 -- "󰋼 Choose: md5, sha1, sha256, sha512, all"
            return 1
            ;;
    esac

    # Calculate requested hashes
    for algo in "${algorithms[@]}"; do
        case "$algo" in
            md5)    sum_cmd=md5sum ;;
            sha1)   sum_cmd=sha1sum ;;
            sha256) sum_cmd=sha256sum ;;
            sha512) sum_cmd=sha512sum ;;
        esac

        # Fall back to shasum/md5 on systems without GNU checksum tools
        if ! command -v "$sum_cmd" >/dev/null 2>&1; then
            case "$algo" in
                md5)
                    if command -v md5 >/dev/null 2>&1; then
                        sum_cmd=md5
                    else
                        print -u2 -- "󰅚 No MD5 utility found."
                        return 1
                    fi
                    ;;
                *)
                    if command -v shasum >/dev/null 2>&1; then
                        sum_cmd=shasum
                    else
                        print -u2 -- "󰅚 No checksum utility found for $algo."
                        return 1
                    fi
                    ;;
            esac
        fi

        print
        gum style --bold --foreground 6 " 󰒋  ${algo:u} HASH"

        if [[ -f "$target" ]]; then
            case "$sum_cmd" in
                md5)    md5 -q "$target" ;;
                shasum)
                    case "$algo" in
                        sha1)   shasum -a 1 -- "$target" ;;
                        sha256) shasum -a 256 -- "$target" ;;
                        sha512) shasum -a 512 -- "$target" ;;
                    esac
                    ;;
                *) "$sum_cmd" -- "$target" ;;
            esac || return 1

        elif [[ -d "$target" ]]; then
            (
                cd -- "$target" || exit 1

                find . -type f -print0 |
                    sort -z |
                    while IFS= read -r -d '' file; do
                        case "$sum_cmd" in
                            md5)
                                md5 -q "$file" || exit 1
                                ;;
                            shasum)
                                case "$algo" in
                                    sha1)   shasum -a 1 -- "$file" ;;
                                    sha256) shasum -a 256 -- "$file" ;;
                                    sha512) shasum -a 512 -- "$file" ;;
                                esac || exit 1
                                ;;
                            *)
                                "$sum_cmd" -- "$file" || exit 1
                                ;;
                        esac
                    done |
                    case "$sum_cmd" in
                        md5)    md5sum ;;
                        shasum)
                            case "$algo" in
                                sha1)   shasum -a 1 ;;
                                sha256) shasum -a 256 ;;
                                sha512) shasum -a 512 ;;
                            esac
                            ;;
                        *) "$sum_cmd" ;;
                    esac
            ) || return 1
        fi
    done
}

# ----------------------- Zsh Configuration & Environment -----------------------

# Edit this zsh configuration (module picker) and optionally reload
edit_zshrc() {
    local file

    file="$(print -rl -- "$ZSHRC_DIR/.zshrc" "$ZSHRC_DIR"/lib/*.zsh(N) |
        gum filter --header="Edit zsh config")" || return 1
    [ -n "$file" ] || return 1

    $EDITOR -- "$file" || return 1
    echo
    gum confirm "Reload zsh?" && exec zsh
}

# Display PATH entries with line numbers
_path() {
    local i=1 p out

    out="$(
        for p in "${(@)path}"; do
            printf '\033[38;5;75m%02d\033[0m\t\033[38;5;114m%s\033[0m\n' \
                "$i" "$p"
            (( i++ ))
        done
    )"

    if [[ -z "$out" ]]; then
        gum style --foreground 2 "No PATH entries found."
        return 0
    fi

    echo
    gum style --bold --foreground 6 " 󰆍 PATH Directories"
    gum style --foreground 7 "  ${#path} entries in execution search order"
    echo

    print -r -- "$out" |
        gum table --print --separator=$'\t' \
            --columns "N","DIRECTORY" \
            --widths 6,76
}

# Display aliases with line numbers
_alias() {
    local i=1 name value out

    out="$(
        for name value in "${(@kv)aliases}"; do
            printf '\033[38;5;75m%02d\033[0m\t\033[38;5;114m%s\033[0m\t\033[38;5;221m%s\033[0m\n' \
                "$i" "$name" "$value"
            (( i++ ))
        done
    )"

    if [[ -z "$out" ]]; then
        gum style --foreground 2 "No aliases found."
        return 0
    fi

    echo
    gum style --bold --foreground 6 " 󰌌 Shell Aliases"
    gum style --foreground 7 "  ${#aliases} aliases defined"
    echo

    print -r -- "$out" |
        gum table --print --separator=$'\t' \
            --columns "N","ALIAS","COMMAND" \
            --widths 6,24,52
}

# ----------------------- Miscellaneous -----------------------

#  Load the Node.js version specified in .nvmrc or .node-version if present
function load_node_version() {
    local dir="$PWD"
    local version_file=""

    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.nvmrc" ]]; then
            version_file="$dir/.nvmrc"
            break
        elif [[ -f "$dir/.node-version" ]]; then
            version_file="$dir/.node-version"
            break
        fi

        dir="${dir:h}"
    done

    if [[ -n "$version_file" ]]; then
        eval "$(fnm env --shell zsh)"
        fnm use --install-if-missing "$(<"$version_file")"
    else
        export PATH="${PATH//\/run\/user\/1000\/fnm_multishells[^:]##:/}"
    fi
}

# Run onefetch if available and in a git repository
function run_onefetch_on_cd() {
    if ! command -v onefetch >/dev/null 2>&1; then
        return
    fi

    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null) || return

    # Run only at the root of the Git repository
    if [[ "$PWD" -ef "$git_root" ]]; then
        clear
        print
        print
        onefetch
    fi
}
