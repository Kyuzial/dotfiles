-- Hyprland Lua Config
-- Wiki: https://wiki.hypr.land/Configuring/
--
-- Entry point: each section lives in its own file under conf/.
-- Paths in require() are relative to this file's directory.
-- Editing any required file makes Hyprland reload the config.

require("./conf/monitors.lua")
require("./conf/env.lua")
require("./conf/autostart.lua")
require("./conf/settings.lua")
require("./conf/animations.lua")
require("./conf/window-rules.lua")
require("./conf/binds.lua")
require("./conf/bitwarden-fix.lua")
