-- LOOK AND FEEL (variables)
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
        cm_auto_hdr = false,
    },

    misc = {
        disable_hyprland_logo = true,
        enable_anr_dialog     = false,
    },

    debug = {
        overlay = false,
    },

    decoration = {
        rounding = 2,
        dim_modal = true,
        blur = {
            enabled           = true,
            size              = 4,
            passes            = 1,
            new_optimizations = true,
            popups            = true,
            popups_ignorealpha = 0.2,
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
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },
})
