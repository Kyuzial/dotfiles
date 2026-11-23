-- WINDOW RULES
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Float common dialog/notification windows
hl.window_rule({ match = { class = "file_progress" },         float = true })
hl.window_rule({ match = { class = "confirm" },               float = true })
hl.window_rule({ match = { class = "dialog" },                float = true })
hl.window_rule({ match = { class = "download" },              float = true })
hl.window_rule({ match = { class = "notification" },          float = true })
hl.window_rule({ match = { class = "error" },                 float = true })
hl.window_rule({ match = { class = "splash" },                float = true })
hl.window_rule({ match = { class = "confirmreset" },          float = true })
hl.window_rule({ match = { class = "hyprpolkitagent" },       float = true })
hl.window_rule({
    name   = "file-picker-open-dialog",
    match  = { title = "^(Open|Save|Choose) (File|Folder|Directory|Files)$" },
    float  = true,
    size   = { 900, 600 },
    center = true,
})
hl.window_rule({
    name   = "file-picker-portal",
    match  = { class = "xdg-desktop-portal-gtk" },
    float  = true,
    size   = { 900, 600 },
    center = true,
})
hl.window_rule({ match = { title = "branchdialog" },          float = true })
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^Picture[- ]in[- ]picture$" },
    float = true,
    pin   = true,
})
hl.window_rule({ match = { title = "^Media viewer$" },        float = true })
hl.window_rule({ match = { title = "^File Operation Progress$" }, float = true })

-- Apply float to windows tagged as floating-window (e.g. desktop Bitwarden)
hl.window_rule({
    name  = "floating-window-tagged",
    match = { tag = "floating-window" },
    float = true,
})

-- Pinentry (GPG/passwords)
hl.window_rule({
    name         = "gpg-pinentry",
    match        = { class = "^pinentry-" },
    float        = true,
    center       = true,
    stay_focused = true,
})

-- Polkit Agents (Authentication dialogs)
hl.window_rule({
    name         = "polkit-gnome",
    match        = { class = "polkit-gnome-authentication-agent-1" },
    float        = true,
    center       = true,
    stay_focused = true,
})
hl.window_rule({
    name         = "polkit-kde",
    match        = { class = "org.kde.polkit-kde-authentication-agent-1" },
    float        = true,
    center       = true,
    stay_focused = true,
})

-- Global Modal Windows handling
hl.window_rule({
    name         = "global-modals",
    match        = { modal = true },
    float        = true,
    center       = true,
    stay_focused = true,
})

-- Bitwarden browser extension popups (matches Firefox, Vivaldi, Chrome, etc.)
hl.window_rule({
    name         = "bitwarden-extension-popup",
    match        = { title = "^Extension: \\(Bitwarden.*" },
    float        = true,
    size         = { 650, 650 },
    center       = true,
    no_anim      = true,
})
hl.window_rule({
    name         = "bitwarden-extension-popup-initial",
    match        = { initial_title = "^Extension: \\(Bitwarden.*" },
    float        = true,
    size         = { 650, 650 },
    center       = true,
    no_anim      = true,
})

-- Bitwarden extension popup in Helium / Chromium-based browsers
hl.window_rule({
    name         = "bitwarden-chromium-popup",
    match        = { class = "^chrome%-", title = "^Bitwarden$" },
    float        = true,
    size         = { 650, 650 },
    center       = true,
    no_anim      = true,
})

-- Vivaldi: prevent compositor from treating it as fullscreen (client state = 0)
-- fullscreen_state sets the window's internal/client fullscreen state.
-- Dispatcher-style: hl.dsp.window.fullscreen_state({ internal = -1, client = 0 })
-- As a window rule effect the value is a two-element table: { internal, client }
-- -1 / "*" means "leave unchanged"
hl.window_rule({
    match            = { class = "vivaldi-stable" },
    fullscreen_state = "0 0",
})

-- Bitwarden: no screen sharing, tag as floating
hl.window_rule({ match = { class = "^Bitwarden$" }, no_screen_share = true })
hl.window_rule({ match = { class = "^Bitwarden$" }, tag = "+floating-window" })

-- XWayland video bridge — completely invisible helper window
hl.window_rule({
    match            = { class = "^xwaylandvideobridge$" },
    opacity          = "0.0 override 0.0 override",
    no_anim          = true,
    no_initial_focus = true,
    max_size         = {1, 1},
    no_blur          = true,
})

-- JetBrains: splash screen — tag first, then apply rules by tag
hl.window_rule({
    name  = "jetbrains-splash-tagging",
    match = { class = "^jetbrains-.*$", title = "^splash$", float = true },
    tag   = "+jetbrains-splash",
})

hl.window_rule({ match = { tag = "jetbrains-splash" }, center = true })
hl.window_rule({ match = { tag = "jetbrains-splash" }, no_focus = true })
hl.window_rule({ match = { tag = "jetbrains-splash" }, border_size = 0 })

-- JetBrains: popup windows (search, new file, etc.) — tag first, then apply rules by tag
hl.window_rule({
    name  = "jetbrains-popup-tagging",
    match = { class = "^jetbrains-.*$", title = "^$", float = true },
    tag   = "+jetbrains",
})

hl.window_rule({ match = { tag = "jetbrains" }, center = true })
hl.window_rule({ match = { tag = "jetbrains" }, stay_focused = true })
hl.window_rule({ match = { tag = "jetbrains" }, border_size = 0 })

-- For some reason tag:jetbrains does not work for size rule, keep class/title/float match
hl.window_rule({
    name     = "jetbrains-popup-min-size",
    match    = { class = "^jetbrains-.*$", title = "^$", float = true },
    min_size = {"monitor_w*0.5", "monitor_h*0.5"},
})

-- JetBrains: suppress initial focus for tooltip/autocomplete windows
hl.window_rule({
    name             = "jetbrains-tooltips",
    match            = { class = "^jetbrains-.*$", title = "^win.*$", float = true },
    no_initial_focus = true,
})

-- JetBrains: disable mouse focus stealing
hl.window_rule({
    name            = "jetbrains-no-mouse-focus",
    match           = { class = "^jetbrains-.*$" },
    no_follow_mouse = true,
})

-- LAYER RULES

-- Layer rules for blur
hl.layer_rule({
    match        = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0.5,
})
