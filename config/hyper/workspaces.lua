-- ============================================================================
-- Workspaces configuration
-- ============================================================================

-- This file is used to configure the layout of workspaces and also put apps in specific workspaces.


-- Workspace 1: Empty (no apps assigned)

-- Workspace 2: Terminal
o.window("foot", { workspace = "2" })
o.window("alacritty", { workspace = "2" })
o.window("kitty", { workspace = "2" })

-- Workspace 3: File Management
o.window("thunar", { workspace = "3" })
o.window("org.gnome.Nautilus", { workspace = "3" })
o.window("org.kde.dolphin", { workspace = "3" })

-- Workspace 4: Code Editors
o.window("com.microsoft.VSCode", { workspace = "4" })
o.window("[Scratch] - nvim", { workspace = "4" })
o.window("sublime_text", { workspace = "4" })

-- Workspace 5: Browsers
o.window("zen", { workspace = "5" })
o.window("chromium", { workspace = "5" })
o.window("brave", { workspace = "5" })

-- Workspace 6: AI
o.window("chrome-chatgpt.com__-Default", { workspace = "6" })
o.window("chrome-claude.ai__-Default", { workspace = "6" })
o.window( "chrome-127.0.0.1__-Default", { workspace = "6" })

-- Workspace 7: Music
o.window("chrome-youtube.com__-Default", { workspace = "7" })
o.window("chrome-music.youtube.com__-Default", { workspace = "7" })
o.window("mpv", { workspace = "7" })

-- Workspace 8: Communication
o.window("chrome-web.whatsapp.com__-Default", { workspace = "8" })
o.window("chrome-discord.com__channels_@me-Default", { workspace = "8" })
o.window("org.mozilla.Thunderbird", { workspace = "8" })
o.window("chrome-www.linkedin.com__-Default", { workspace = "8" })
