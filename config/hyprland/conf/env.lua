-- ENVIRONMENT VARIABLES
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XDG_CURRENT_DESKTOP",             "Hyprland")
hl.env("XDG_SESSION_TYPE",                "wayland")
hl.env("XDG_SESSION_DESKTOP",             "Hyprland")

hl.env("XCURSOR_SIZE",                    "24")
hl.env("HYPRCURSOR_SIZE",                 "24")
hl.env("_JAVA_AWT_WM_NONREPARENTING",     "1")
hl.env("_JAVA_OPTIONS",                   "-Dawt.useSystemAAFontSettings=lcd")

hl.env("QT_QPA_PLATFORMTHEME",            "qt5ct")
hl.env("QT_QPA_PLATFORM",                 "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.env("ELECTRON_OZONE_PLATFORM_HINT",    "auto")
hl.env("SDL_VIDEODRIVER",                 "wayland")
