-- Hyprland Lua Config
-- Migrated from hyprlang (.conf) to Lua (.lua) for Hyprland 0.55+
-- Original backups are in ~/.config/hypr/backup-pre-lua/
-- Wiki: https://wiki.hypr.land/Configuring/


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",        -- "" = all monitors
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XDG_CURRENT_DESKTOP",             "Hyprland")
hl.env("XDG_SESSION_TYPE",                "wayland")
hl.env("XDG_SESSION_DESKTOP",             "Hyprland")

hl.env("XCURSOR_SIZE",                    "24")
hl.env("_JAVA_AWT_WM_NONREPARENTING",     "1")
hl.env("_JAVA_OPTIONS",                   "-Dawt.useSystemAAFontSettings=lcd")

hl.env("QT_QPA_PLATFORMTHEME",            "qt5ct")
hl.env("QT_QPA_PLATFORM",                 "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.env("ELECTRON_OZONE_PLATFORM_HINT",    "auto")
hl.env("SDL_VIDEODRIVER",                 "wayland")


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.exec_cmd() spawns async processes — no need for `& disown`.
hl.on("hyprland.start", function()
    -- Wayland / session environment
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Polkit agent
    hl.exec_cmd("/usr/bin/lxqt-policykit-agent")

    -- XWayland access for current user
    hl.exec_cmd("xhost +SI:localuser:pierre")

    -- Status bar & applets
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator & blueman-applet")

    -- Wallpaper
    hl.exec_cmd("swaybg -i ~/Pictures/BingWallpaper/20221123-TignesLake_FR-FR8817232825_UHD.jpg")

    -- Clipboard managers
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    -- Delayed apps (replaces `sleep 5; ...`)
    hl.timer(function()
        hl.exec_cmd("openrgb --startminimized --profile pink.orp")
        hl.exec_cmd("nextcloud")
        hl.exec_cmd("vorta -d")
        hl.exec_cmd("firefox")

        -- Launch on specific workspaces, matching old `[workspace N silent]` exec rules
        -- Thunderbird → workspace 8
        hl.dispatch(hl.dsp.exec_cmd("thunderbird",            { workspace = "8 silent" }))
        -- Discord → workspace 3
        hl.dispatch(hl.dsp.exec_cmd("com.discordapp.Discord", { workspace = "3 silent" }))
        -- Spotify (commented out, same as original)
        -- hl.dispatch(hl.dsp.exec_cmd("com.spotify.Client",     { workspace = "3 silent" }))
    end, { timeout = 5000, type = "oneshot" })
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 4,
        border_size = 2,
        col = {
            active_border   = "rgb(bd93f9)",
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
    },

    render = {
        -- NOTE: render.cm_fs_passthrough was REMOVED in 0.55.
        -- Its behaviour is now automatic via render.cm_auto_hdr.
        cm_auto_hdr = false,
    },

    misc = {
        disable_hyprland_logo = true,
        enable_anr_dialog     = false,
    },

    debug = {
        overlay = false,
        -- NOTE: misc.vfr was MOVED to debug.vfr in 0.55 (it is a debug variable).
        -- Leave unset unless you need to debug VFR behaviour.
    },

    decoration = {
        rounding = 2,
        blur = {
            enabled           = true,
            size              = 4,
            passes            = 1,
            new_optimizations = true,
        },
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout      = "fr",
        -- kb_variant  = "altgr-intl",  -- uncomment if needed
        kb_model       = "",
        kb_options     = "",
        kb_rules       = "",

        follow_mouse   = 1,
        sensitivity    = 0,          -- -1.0 to 1.0, 0 = no modification
        force_no_accel = true,

        touchpad = {
            natural_scroll = false,
        },
    },

    dwindle = {
        -- NOTE: dwindle.pseudotile was REMOVED in 0.55 (wasn't doing anything).
        -- The SUPER+P bind below has been kept as a no-op; remove if unneeded.
        preserve_split = true,
    },

    master = {
        new_status = "master",  -- was 'true' (bool) in old config, now must be a string
    },
})


-- Custom bezier curve (equivalent to `bezier = myBezier, 0.22, 1, 0.36, 1`)
hl.curve("myBezier", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })

-- Animations
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 2, bezier = "default" })


--------------------
---- WINDOW RULES --
--------------------

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
hl.window_rule({ match = { class = "lxqt-policykit-agent" },  float = true })
hl.window_rule({ match = { title = "Open File" },             float = true })
hl.window_rule({ match = { title = "branchdialog" },          float = true })
hl.window_rule({ match = { title = "^Picture in picture$" },  float = true })
hl.window_rule({ match = { title = "^Picture-in-Picture$" },  float = true })
hl.window_rule({ match = { title = "^Media viewer$" },        float = true })
hl.window_rule({ match = { title = "^File Operation Progress$" }, float = true })

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

-- JetBrains: splash screen — tag first, then apply rules by tag (same structure as original)
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


---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"

-- App launchers & WM actions
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("kitty --single-instance"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("wofi --show drun -I"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))  -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move windows with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize windows with mainMod + ALT + arrow keys (repeating)
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.resize({ x = -100, y = 0, relative = true }),   { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x =  100, y = 0, relative = true }),   { repeating = true })
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.resize({ x = 0, y = -100, relative = true }),   { repeating = true })
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.resize({ x = 0, y =  100, relative = true }),   { repeating = true })

-- Switch workspaces / move windows with keycodes
-- (FR keyboard: digits 1-9,0 live at keycodes 10-19)
for i = 1, 10 do
    local code = 9 + i  -- code:10 → &/1, ..., code:19 → à/0
    hl.bind("SUPER + code:"          .. code, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Scroll through workspaces with mainMod + scroll wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize windows by dragging with mouse buttons
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Group / tabbed layout
hl.bind(mainMod .. " + T", hl.dsp.group.toggle())
hl.bind(mainMod .. " + Y", hl.dsp.group.next())        -- cycle forward in group (was changegroupactive)
hl.bind(mainMod .. " + U", hl.dsp.window.move({ out_of_group = true }))

-- Media / hardware keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { release = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { release = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("light -A 5"),                                   { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("light -U 5"),                                   { repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                         { repeating = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                         { repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                               { repeating = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                           { repeating = true })

-- Screenshots
hl.bind(mainMod .. " + PRINT",     hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))
hl.bind(mainMod .. " + code:49",   hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))
