-- ANIMATIONS
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

-- Custom bezier curve (equivalent to `bezier = myBezier, 0.22, 1, 0.36, 1`)
hl.curve("myBezier", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 2, bezier = "default" })
