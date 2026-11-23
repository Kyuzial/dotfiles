-- KEYBINDINGS
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"

-- App launchers & WM actions
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("kitty --single-instance"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
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
hl.bind(mainMod .. " + Y", hl.dsp.group.next())        -- cycle forward in group
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
