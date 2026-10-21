-- ============================================================================
-- Personal keybinding overrides
--
-- This file is loaded AFTER Omarchy's defaults, so anything here wins.
-- Rules of thumb:
--   * Rebinding an existing key? Call hl.unbind() FIRST, then o.bind().
--   * Removing a default you never use? hl.unbind() alone is enough.
--
-- Inspect the live bindings at any time with:
--   omarchy menu keybindings --print
--
-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false
--
-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false
--
-- Binding syntax reference:
--   o.bind(keys, description, command)  -- add a binding
--   hl.unbind(keys)                     -- remove a default binding
--
-- Example: move SUPER+SPACE from the launcher to the Omarchy root menu.
--   hl.unbind("SUPER + SPACE")
--   o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")
--
-- Logitech MX Keys examples (these keys are awkward on that layout):
--   o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
--   o.bind("SUPER + H", nil, "voxtype record toggle")
--   o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
-- ============================================================================



-- ============================================================================
-- UNBINDING PREINSTALLED DEFAULTS
--
-- Stock Omarchy app/webapp shortcuts I do not use. Each one is freed here so
-- it can be repurposed further down in this file (or simply left dead).
-- Keys with a "->" note below are reassigned later in this file.
-- ============================================================================


-- Screenshot key: Omarchy's PRINT capture is replaced by Omashot further below.
hl.unbind("PRINT")

-- SUPER+ALT+SPACE: Omarchy app menu -> replaced by the App Grid further below.
hl.unbind("SUPER + ALT + SPACE")

-- Webapps.
hl.unbind("SUPER + SHIFT + E")        -- HEY
hl.unbind("SUPER + SHIFT + C")        -- HEY (duplicate slot) -> Claude
hl.unbind("SUPER + SHIFT + M")        -- Spotify -> YouTube Music
hl.unbind("SUPER + SHIFT + P")        -- Google Photos
hl.unbind("SUPER + SHIFT + SLASH")    -- 1Password
hl.unbind("SUPER + SHIFT + S")        -- Google Maps
hl.unbind("SUPER + SHIFT + O")        -- Obsidian -> Notion
hl.unbind("SUPER + SHIFT + G")        -- Signal
hl.unbind("SUPER + SHIFT + B")        -- default browser -> Brave
hl.unbind("SUPER + SHIFT + ALT + B")  -- Browser (private) -> Chromium
hl.unbind("SUPER + SHIFT + CTRL + G") -- Google Messages

-- Apps and terminals.
hl.unbind("SUPER + SHIFT + ALT + M") -- Music TUI
hl.unbind("SUPER + SHIFT + ALT + E") -- Email -> Thunderbird
hl.unbind("SUPER + SHIFT + ALT + A") -- Grok
hl.unbind("SUPER + SHIFT + ALT + X") -- X (Twitter)
hl.unbind("SUPER + ALT + SHIFT + F") -- file manager -> Superfile
hl.unbind("SUPER + CTRL + RETURN")   -- Herdr
hl.unbind("SUPER + CTRL + K")        -- Herdr keybindings
hl.unbind("SUPER + SHIFT + W")       -- Omawrite
hl.unbind("SUPER + CTRL + Q")        -- Calculator
hl.unbind("SUPER + SHIFT + F")       -- File manager

-- Miscellaneous
hl.unbind("SHIFT + ALT + D")            -- Download Video from Web App
hl.unbind("SHIFT + ALT + L")            -- Copy URL from Web App
hl.unbind("SUPER + ALT + BRACKETLEFT")  -- Make webcam overlay smaller
hl.unbind("SUPER + ALT + BRACKETRIGHT") -- Make webcam overlay larger
hl.unbind("SUPER + CTRL + ALT + D")     -- Calendar
hl.unbind("SUPER + CTRL + ALT + T")     -- Show time
hl.unbind("SUPER + CTRL + ALT + W")     -- Toggle weather
hl.unbind("SUPER + CTRL + B")           -- Bluetooth
hl.unbind("SUPER + CTRL + D")           -- Display
hl.unbind("SUPER + CTRL + P")           -- Power
hl.unbind("SUPER + CTRL + W")           -- Network

-- ============================================================================
-- LAUNCHERS AND OVERLAYS
-- ============================================================================


-- Spotlight: quick app/file search. Bound to ALT+SPACE so it does not fight
-- with SUPER+SPACE (Omarchy menu).
o.bind("ALT + SPACE", "Spotlight",
    "omarchy-shell shell toggle io.github.maajix.spotlight '{}'")

-- App Grid: full-screen app launcher, reusing the freed SUPER+ALT+SPACE.
o.bind("SUPER + ALT + SPACE", "App grid",
    "omarchy-shell shell toggle matthewjaybarr.app-grid '{}'")

-- Omashot: screenshot / screen-recording menu on the Print key.
o.bind("PRINT", "Omashot", "omarchy-shell b.omashot show")


-- ============================================================================
-- KEYBINDINGS HINT (Nejcc)
--
-- Hold the SUPER key to reveal the hint overlay; releasing it hides the
-- overlay again. This uses a raw hl.bind() because it needs modifier handling
-- and long-press options that o.bind() does not expose.
-- ============================================================================

-- Open Keybindings Popup
hl.bind("SUPER_L", hl.dsp.exec_cmd("omarchy-shell shell summon nejcc.keybindings-hint"),
    { long_press = true, ignore_mods = true })

-- Close Keybindings Popup
o.bind("HOME", "Close Keybindings Hints", "omarchy-shell shell hide nejcc.keybindings-hint")

-- Turn the hint overlay on or off.
o.bind("SUPER + SHIFT + K", "Toggle keybindings hint",
    "omarchy-shell shell summon nejcc.keybindings-hint '{\"enabled\":\"toggle\"}'")

-- Turn learning mode on or off (shows every binding, not just hints).
o.bind("SUPER + CTRL + SHIFT + K", "Toggle keybindings hint learning",
    "omarchy-shell shell summon nejcc.keybindings-hint '{\"learning\":\"toggle\"}'")

-- ============================================================================
-- FATHOM (window navigation helper)
--
-- Fathom ships its bindings in its own Lua file. Loading it manually keeps the
-- setup working while the plugin is installed and failing gracefully (via
-- pcall) when it is not.
-- ============================================================================

do
    local fathom = os.getenv("HOME")
        .. "/.config/omarchy/plugins/io.github.mtolhuys.fathom/hypr/fathom.lua"
    local file = io.open(fathom, "r")
    if file then
        file:close()
        pcall(dofile, fathom)
    end
end

-- ============================================================================
-- Close Guard
--
-- Close Guard ships with its bindings in its own Lua file. Loading it manually keeps the
-- setup working while the plugin is installed and failing gracefully (via
-- pcall) when it is not.
-- ============================================================================

do
    local guard = os.getenv("HOME") .. "/.config/omarchy/plugins/io.github.ayandexyz.close-guard/hypr/close-guard.lua"
    local file = io.open(guard, "r")
    if file then
        file:close()
        pcall(dofile, guard)
    end
end

-- ============================================================================
-- WEBAPPS
--
-- Reuses the freed webapp shortcuts from the unbind section above.
-- ============================================================================

o.bind("SUPER + SHIFT + C", "Claude",
    "omarchy-launch-webapp https://claude.ai/")

o.bind("SUPER + SHIFT + M", "YouTube Music",
    "omarchy-launch-webapp https://music.youtube.com/")

o.bind("SUPER + SHIFT + O", "Notion",
    "omarchy-launch-webapp https://app.notion.com/login")

o.bind("SUPER + SHIFT + L", "OpwnWebUI",
    "omarchy-launch-webapp http://127.0.0.1:8080")

-- ============================================================================
-- APPS
--
-- Native applications bound to the freed stock shortcuts.
-- ============================================================================

-- Launch Thunderbird Client
o.bind("SUPER + SHIFT + ALT + E", "Thunderbird", "/usr/bin/thunderbird")

-- Launch Brave Browser
o.bind("SUPER + SHIFT + B", "Brave Browser", "/usr/bin/brave-origin")

-- Launch Chromium Browser
o.bind("SUPER + SHIFT + ALT + B", "Chromium Browser", "/usr/bin/chromium")

-- Superfile: terminal file manager, launched inside foot.
o.bind("SUPER + ALT + SHIFT + F", "Superfile", "foot -e /usr/bin/spf")

-- Radial Menu
o.bind("SUPER + R", "Radial menu", "omarchy-shell radial open")

-- File Manager: Nautilus
o.bind("SUPER + E", "File Manager", "/usr/bin/nautilus")
o.bind("SUPER + SHIFT + E", "File Manager (Admin)", "/usr/bin/nautilus admin:///")

-- System Monitor (Btop)
o.bind("SUPER + SHIFT + ESCAPE", "System Monitor", "foot -e btop")
