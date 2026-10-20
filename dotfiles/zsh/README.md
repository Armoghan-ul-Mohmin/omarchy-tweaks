# Zsh Dotfiles

Modular zsh configuration managed by [plug.zsh](https://github.com/Armoghan-ul-Mohmin/plug).

**Documentation** (devhints-style, in [`docs/`](../../docs/index.html)):

| Page | Contents |
|------|----------|
| [Zsh Cheatsheet](../../docs/zsh-cheatsheet.html) | expansions, globbing, redirection, history, line editing |
| [My Aliases](../../docs/aliases.html) | every alias in `40-aliases.zsh` |
| [My Zsh Config](../../docs/zsh-config.html) | modules, env vars, plugins, fzf-tab, keybindings |
| [Git Cheatsheet](../../docs/git-cheatsheet.html) | git reference + `g…` aliases and widgets |
| [Functions](../../docs/functions.html) | every function in `50-functions.zsh` |

Open `docs/index.html` in a browser (the pages are plain HTML).

## Layout

```
dotfiles/zsh/
├── .zshrc                # entry point: guard, ZSHRC_DIR, loads lib/*.zsh, then ~/.secrets.zsh
└── lib/
    ├── 00-env.zsh        # environment (EDITOR, FZF_*, PLUG_*, PATH, starship)
    ├── 10-options.zsh    # setopts; Atuin owns history (no local HISTFILE)
    ├── 20-plugins.zsh    # plug manager, plugins, starship/fzf/zoxide/atuin inits, YSU
    ├── 30-fzf-tab.zsh    # fzf-tab previews/styles + fzf ZLE widgets
    ├── 40-aliases.zsh    # aliases only
    ├── 50-functions.zsh  # gum-powered functions
    └── 60-keybindings.zsh# bindkey -e, run-tui, widgets, bindings
```

Numbered prefixes control load order. To add a module, drop a new
`NN-name.zsh` file in `lib/` — no other edits needed.

The loader only runs in interactive shells, resolves its own directory
symlink-safe (`ZSHRC_DIR`), and sources `~/.secrets.zsh` last for
machine-specific values.

## Testing without installing

Never source this directory or `exec zsh -i` after a source — a fresh
`zsh -i` re-reads `~/.zshrc`, so your edits would not load. Use `ZDOTDIR`:

```sh
ZDOTDIR=/path/to/omarchy-tweaks/dotfiles/zsh zsh -i
# or, if ~/.local/bin is in PATH:
zsh-dev
```

`ZDOTDIR` makes zsh read `.zshrc` from this directory instead of `$HOME`.
It is exported by the config, so `reload` / `zshrc` (the interactive
module editor) keep working after a reload.

## Installing for real

Symlink (do not copy — modules are resolved relative to `.zshrc`):

```sh
ln -sf /path/to/omarchy-tweaks/dotfiles/zsh/.zshrc ~/.zshrc
```

The loader resolves its own location through symlinks, so this works
from any clone path.

## Conventions

- Aliases in `40-aliases.zsh`, functions in `50-functions.zsh`.
- Function naming: implementation is `_name`, exposed through a public
  alias (`alias ports="_ports"`) so the public command behaves like a
  normal command with arguments.
- Anything interactive/prompty uses `gum` (input, choose, confirm,
  filter, table). Tables fed from a pipe need `gum table --print`.
- Inside functions, call `command git`, `command du`, … to bypass
  aliases like `du='_du'`.
- Plugins are declared with `plug` only — see `20-plugins.zsh`.
- Keybindings go in `60-keybindings.zsh` (`zle -N` + `bindkey`); add an
  entry to `bin/keybind-help` when you add one.
- Keep secrets out of the repo — they belong in `~/.secrets.zsh`.

## Everyday commands

| Command | What it does |
|---------|--------------|
| `reload` | restart the shell (`exec zsh`) |
| `zshrc` | pick a module in a gum filter, edit it, optionally reload |
| `keybind-help` (`Alt+?` / `Alt+/`) | show all keybindings in a TUI |
| `zsh-dev` | launch a shell on this config without installing it |

Full keybinding tables: [docs/zsh-config.html](../../docs/zsh-config.html#keybindings).
