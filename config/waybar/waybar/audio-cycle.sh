#!/usr/bin/env bash
# Dynamic audio sink cycler for Waybar.
# Discovers all available sinks at runtime — works with speakers, USB, Bluetooth, etc.
# Usage:
#   audio-cycle.sh          → prints current sink label (for Waybar "exec")
#   audio-cycle.sh cycle    → switches to the next available sink

# ── Icon heuristics ──────────────────────────────────────────────────────────
# Maps keywords in the sink description/name to an icon.
# First match wins, so order matters.
pick_icon() {
    local desc="${1,,}"  # lowercase
    case "$desc" in
        *bluetooth*|*bluez*|*headset*|*a2dp*) echo "" ;;  # BT headset
        *headphone*|*headphones*)              echo "" ;;  # wired headphones
        *usb*)                                echo "" ;;  # USB audio
        *hdmi*|*dp*|*displayport*)            echo "󰡁" ;;  # HDMI/DP
        *speaker*|*analog*)                   echo "" ;;  # speakers
        *)                                    echo "" ;;  # fallback
    esac
}

# ── Gather sinks ─────────────────────────────────────────────────────────────
# Build parallel arrays: SINK_NAMES[] and SINK_DESCS[]
mapfile -t SINK_NAMES < <(pactl list sinks | grep -E '^\s+Name:' | awk '{print $2}')
mapfile -t SINK_DESCS < <(pactl list sinks | grep -E '^\s+Description:' | sed 's/^\s*Description:\s*//')

if [[ ${#SINK_NAMES[@]} -eq 0 ]]; then
    echo "No sinks"
    exit 1
fi

# ── Current default sink ─────────────────────────────────────────────────────
CURRENT=$(pactl get-default-sink)

CURRENT_IDX=-1
for i in "${!SINK_NAMES[@]}"; do
    if [[ "${SINK_NAMES[$i]}" == "$CURRENT" ]]; then
        CURRENT_IDX=$i
        break
    fi
done

# ── Mode: cycle ──────────────────────────────────────────────────────────────
if [[ "$1" == "cycle" ]]; then
    NEXT_IDX=$(( (CURRENT_IDX + 1) % ${#SINK_NAMES[@]} ))
    NEXT_SINK="${SINK_NAMES[$NEXT_IDX]}"

    pactl set-default-sink "$NEXT_SINK"

    # Move all active audio streams to the new sink
    pactl list sink-inputs short | awk '{print $1}' | while read -r input; do
        pactl move-sink-input "$input" "$NEXT_SINK"
    done

    # Force Waybar to refresh this module immediately
    pkill -RTMIN+8 waybar

# ── Mode: status (default) ───────────────────────────────────────────────────
else
    if [[ $CURRENT_IDX -ge 0 ]]; then
        DESC="${SINK_DESCS[$CURRENT_IDX]}"
        ICON=$(pick_icon "$DESC")
        # Short label: icon + first ~20 chars of description
        SHORT=$(echo "$DESC" | cut -c1-20)
        echo "$ICON $SHORT"
    else
        # Sink not in list (e.g. just switched) — show raw name truncated
        ICON=$(pick_icon "$CURRENT")
        echo "$ICON ${CURRENT:0:20}"
    fi
fi
