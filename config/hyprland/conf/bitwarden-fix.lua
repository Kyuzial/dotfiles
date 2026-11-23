-- DYNAMIC FIX for browser extension popups (like Bitwarden)
-- Firefox: windows change title to 'Extension: (Bitwarden...' after creation
-- Helium/Chromium: windows change class to 'chrome-<ext-id>-...' after creation
local function is_bitwarden_popup(w)
    return w.title:match("^Extension:.*Bitwarden")
        or (w.class:match("^chrome%-") and w.title:match("^Bitwarden$"))
end

local function float_bitwarden(w)
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = "address:" .. w.address }))
    hl.dispatch(hl.dsp.window.resize({ x = 650, y = 650, relative = false, window = "address:" .. w.address }))
    hl.dispatch(hl.dsp.window.center({ window = "address:" .. w.address }))
end

local function fix_bitwarden_popups()
    for _, w in ipairs(hl.get_windows()) do
        if is_bitwarden_popup(w) then
            float_bitwarden(w)
        end
    end
end

-- Fix any currently open popups when the configuration starts/reloads
fix_bitwarden_popups()

-- Watch for title/class updates and float/center/resize them dynamically
hl.on("window.title", function(w)
    if is_bitwarden_popup(w) then
        float_bitwarden(w)
    end
end)

hl.on("window.class", function(w)
    if is_bitwarden_popup(w) then
        float_bitwarden(w)
    end
end)
