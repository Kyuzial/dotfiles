-- AUTOSTART
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.exec_cmd() spawns async processes — no need for `& disown`.
hl.on("hyprland.start", function()
    -- Polkit agent
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")

    -- XWayland access for current user
    hl.exec_cmd("xhost +SI:localuser:pierre")

    -- Status bar & applets
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")

    -- Wallpaper
    hl.exec_cmd("swaybg -i ~/Pictures/BingWallpaper/20221123-TignesLake_FR-FR8817232825_UHD.jpg")

    -- Clipboard managers
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    -- Delayed apps
    hl.timer(function()
        hl.exec_cmd("openrgb --startminimized --profile pink.orp")
        hl.exec_cmd("nextcloud")
        hl.exec_cmd("vorta -d")
        hl.exec_cmd("firefox")

        -- Launch on specific workspaces
        -- Thunderbird → workspace 8
        hl.dispatch(hl.dsp.exec_cmd("thunderbird",            { workspace = "8 silent" }))
        -- Discord → workspace 3
        hl.dispatch(hl.dsp.exec_cmd("com.discordapp.Discord", { workspace = "3 silent" }))
        -- Spotify (disabled)
        -- hl.dispatch(hl.dsp.exec_cmd("com.spotify.Client",     { workspace = "3 silent" }))
    end, { timeout = 5000, type = "oneshot" })
end)
