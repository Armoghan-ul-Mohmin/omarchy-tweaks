-- ============================================================================
-- Workspaces configuration
-- ============================================================================

-- This file is used to configure the layout of workspaces and also put apps in specific workspaces.

-- Workspace 1: Terminal
o.window("foot", { workspace = "1" })
o.window("alacritty", { workspace = "1" })
o.window("kitty", { workspace = "1" })

-- Workspace 2: File Management
o.window("thunar", { workspace = "2" })
o.window("org.gnome.Nautilus", { workspace = "2" })
o.window("org.kde.dolphin", { workspace = "2" })

-- Workspace 3: Code Editors
o.window("com.microsoft.VSCode", { workspace = "3" })
o.window("[Scratch] - nvim", { workspace = "3" })
o.window("sublime_text", { workspace = "3" })

-- Workspace 4: Browsers
o.window("zen", { workspace = "4" })
o.window("chromium", { workspace = "4" })
o.window("brave", { workspace = "4" })

-- Workspace 5: AI
o.window("chrome-chatgpt.com__-Default", { workspace = "5" })
o.window("chrome-claude.ai__-Default", { workspace = "5" })
o.window( "chrome-116.0.0.1__-Default", { workspace = "5" })

-- Workspace 6: Music
o.window("chrome-youtube.com__-Default", { workspace = "6" })
o.window("chrome-music.youtube.com__-Default", { workspace = "6" })
o.window("mpv", { workspace = "6" })

-- Workspace 7: Communication
o.window("chrome-web.whatsapp.com__-Default", { workspace = "7" })
o.window("chrome-discord.com__channels_@me-Default", { workspace = "7" })
o.window("org.mozilla.Thunderbird", { workspace = "7" })
o.window("chrome-www.linkedin.com__-Default", { workspace = "7" })
