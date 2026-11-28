#!/usr/bin/env python3
"""Universal media controls for Waybar, via MPRIS (playerctl).

Works with anything that exposes MPRIS over D-Bus: Spotify, Firefox/Chromium
(YouTube, …), VLC, mpv, Audacious, Rhythmbox…

Player selection (what the bar shows *and* controls):
  • a currently playing stream always beats paused ones
  • among several playing streams, a newly started one takes over;
    otherwise the bar sticks to the player you were controlling (no flapping)
  • actions (play/pause, next, previous) target exactly the player that is
    displayed — never re-guessed at click time
  • the tooltip lists the other players that are running

Design notes (CPU):
  • one `playerctl -a metadata` call per poll gets every player's status and
    metadata at once (no per-player process spawns)
  • the prev/next button modules do not poll at all — they run once and then
    only on demand via RTMIN+9 (which this script sends when players appear
    or disappear), so idle CPU cost is just the single main poll

Usage:
  media.py               → JSON status for the main (play/pause) module
  media.py btn prev|next → icon for the prev/next button modules
  media.py toggle        → play/pause   (left click)
  media.py next|prev     → skip track   (side buttons)
"""

import html
import json
import os
import subprocess
import sys

REFRESH_SIGNAL = "RTMIN+9"   # waybar "signal": 9  (audiosink owns RTMIN+8)
SEP = "\x1f"                 # ASCII unit separator, safe inside metadata
LABEL_LIMIT = 24             # max characters shown in the bar pill
FMT = SEP.join(
    ["{{status}}", "{{playerName}}", "{{artist}}", "{{title}}",
     "{{album}}", "{{position}}", "{{mpris:length}}"]
)

# Font Awesome 7 Solid codepoints. The CSS forces this font family on the
# buttons, and the status icon below is wrapped in a font span, so Pango
# can't pick a random fallback for these private-use glyphs.
ICONS = {
    "playing": "\uf04b",   # ▶ play
    "paused":  "\uf04c",   # ⏸ pause
    "stopped": "\uf04d",   # ⏹ stop
}
ICON_COLORS = {"playing": "#50fa7b", "paused": "#bd93f9", "stopped": "#6272a4"}
PREV_ICON, NEXT_ICON = "\uf048", "\uf051"   # ⏮ ⏭
ACTIONS = {"toggle": "play-pause", "next": "next", "prev": "previous"}


def playerctl(*args: str) -> subprocess.CompletedProcess:
    """Run playerctl without a shell — no quoting/injection surface."""
    return subprocess.run(
        ["playerctl", *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def refresh_waybar() -> None:
    subprocess.run(["pkill", f"-{REFRESH_SIGNAL}", "waybar"], capture_output=True)


def format_time(microseconds: str) -> str | None:
    """Microseconds (as metadata string) → 'm:ss', or None if unusable."""
    try:
        micro = int(microseconds)
    except (TypeError, ValueError):
        return None
    if micro < 0:
        return None
    secs = micro // 1_000_000
    return f"{secs // 60}:{secs % 60:02d}"


# ── Selection state: which player the bar is currently showing ────────────
def state_file() -> str:
    base = os.environ.get("XDG_RUNTIME_DIR") or "/tmp"
    return os.path.join(base, f"waybar-media-{os.getuid()}.state")


def read_state() -> tuple[str, set[str], bool]:
    """Returns (displayed player, players playing last poll, manual pin)."""
    try:
        with open(state_file(), encoding="utf-8") as f:
            lines = f.read().splitlines()
    except OSError:
        return "", set(), False
    chosen = lines[0].strip() if lines else ""
    playing = {p for p in (lines[1].split(",") if len(lines) > 1 else []) if p}
    pinned = len(lines) > 2 and lines[2].strip() == "1"
    return chosen, playing, pinned


def write_state(chosen: str, playing: set[str], pinned: bool) -> None:
    path = state_file()
    tmp = f"{path}.{os.getpid()}.tmp"
    try:
        with open(tmp, "w", encoding="utf-8") as f:
            f.write(f"{chosen}\n{','.join(sorted(playing))}\n{'1' if pinned else '0'}\n")
        os.replace(tmp, path)
    except OSError:
        try:
            os.unlink(tmp)
        except OSError:
            pass


def scan_players() -> dict[str, tuple[str, ...]]:
    """All players in ONE playerctl call → {name: (status, name, artist, title, …)}.

    Names are the MPRIS app names (spotify, firefox, vlc, …). When an app
    exposes several instances (e.g. two Firefox windows), the currently
    playing one wins, otherwise the first seen.
    """
    raw = playerctl("-a", "metadata", "--format", FMT).stdout
    players: dict[str, tuple[str, ...]] = {}
    for line in raw.splitlines():
        fields = (line.split(SEP) + [""] * 7)[:7]
        info = tuple(f.strip() for f in fields)
        name = info[1]
        if not name:
            continue
        if name not in players or (info[0] == "Playing" and players[name][0] != "Playing"):
            players[name] = info
    return players


def default_player(players: dict[str, tuple[str, ...]]) -> str:
    """playerctl's own 'most recently active' pick, validated against the map."""
    name = playerctl("metadata", "--format", "{{playerName}}").stdout.strip()
    return name if name in players else ""


def select_player() -> tuple[str, dict[str, tuple[str, ...]]] | None:
    """Decide which player the bar shows; persist it for the click actions.

    Returns (chosen player, {player: metadata}) or None when nothing is
    playing or paused (a lingering 'Stopped' browser player hides the pill).
    """
    prev_chosen, prev_playing, pinned = read_state()
    players = scan_players()

    if not players:
        write_state("", set(), False)
        if prev_chosen:                     # pill was visible → hide buttons
            refresh_waybar()
        return None

    names = list(players)
    playing = [n for n in names if players[n][0] == "Playing"]
    paused = [n for n in names if players[n][0] == "Paused"]

    if not playing and not paused:
        write_state("", set(), False)
        if prev_chosen:
            refresh_waybar()
        return None                         # only stopped/idle players → hide
    candidates = playing or paused

    # A manual pin (from scrolling) may point at a player that isn't a
    # candidate right now; keep it while it is alive and visible.
    pin_kept = (
        pinned
        and prev_chosen in players
        and players[prev_chosen][0] in ("Playing", "Paused")
    )
    if pin_kept and prev_chosen not in candidates:
        candidates = candidates + [prev_chosen]

    newly_playing = [n for n in playing if n not in prev_playing]

    if prev_chosen in candidates:
        if newly_playing and prev_chosen not in newly_playing:
            # A new stream just started — follow it.
            chosen = default_player(players)
            if chosen not in newly_playing:
                chosen = newly_playing[0]
            pin_kept = False
        else:
            chosen = prev_chosen            # stick: no flapping
    else:
        pin_kept = False
        chosen = default_player(players)
        if chosen not in candidates:
            chosen = candidates[0]

    write_state(chosen, set(playing), pin_kept)
    if bool(chosen) != bool(prev_chosen):
        refresh_waybar()                    # show/hide the side buttons
    return chosen, players


def cycle_player(step: int) -> None:
    """Scroll handler: manually select the next/previous live player.

    Currently unused (kept for a possible scroll-to-switch feature).
    """
    chosen, _, _ = read_state()
    players = scan_players()
    # Sorted for a stable, predictable scroll order.
    names = sorted(n for n, info in players.items() if info[0] in ("Playing", "Paused"))
    if not names:
        return
    if chosen in names:
        chosen = names[(names.index(chosen) + step) % len(names)]
    else:
        chosen = names[0] if step > 0 else names[-1]
    playing_now = {n for n, info in players.items() if info[0] == "Playing"}
    write_state(chosen, playing_now, True)


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"

    # ── Actions (waybar mouse bindings) ──────────────────────────────────
    if cmd in ACTIONS:
        chosen, _, _ = read_state()
        # Act on the displayed player; fall back to playerctl's default
        # only if that player is gone.
        if not chosen or playerctl("-p", chosen, ACTIONS[cmd]).returncode != 0:
            playerctl(ACTIONS[cmd])
        refresh_waybar()
        return

    # ── Prev/next buttons: icon only while the main pill is showing ─────
    if cmd == "btn":
        chosen, _, _ = read_state()
        if chosen:
            print(PREV_ICON if (len(sys.argv) > 2 and sys.argv[2] == "prev") else NEXT_ICON)
        return

    if cmd != "status":
        return

    # ── Status (the main pill) ───────────────────────────────────────────
    selected = select_player()
    if selected is None:
        return                      # empty output → waybar hides the pill

    chosen, players = selected
    status, player, artist, title, album, pos, length = players[chosen]
    state = status.lower()
    if state not in ("playing", "paused"):
        state = "stopped"

    # Bar label: prefer "Artist – Title", but drop the artist when the pair
    # doesn't fit; truncate only as a last resort.
    if artist and title:
        combined = f"{artist} – {title}"
        label = combined if len(combined) <= LABEL_LIMIT else title
    elif title:
        label = title
    else:
        label = f"Media — {player}" if player else "Media"
    if len(label) > LABEL_LIMIT:
        label = label[: LABEL_LIMIT - 1] + "…"

    text = (
        f"<span font_family='Font Awesome 7 Free Solid' foreground='{ICON_COLORS[state]}'>"
        f"{ICONS[state]}</span>\u2009 "
        f"{html.escape(label, quote=False)}"
    )

    # Rich tooltip
    player_display = player.capitalize() if player else "Media"
    lines = [f"<b>{html.escape(player_display, quote=False)} — {status}</b>"]
    if title:
        lines.append(f"<b>{html.escape(title, quote=False)}</b>")
    if artist:
        lines.append(f"by {html.escape(artist, quote=False)}")
    if album:
        lines.append(f"from {html.escape(album, quote=False)}")
    current = format_time(pos)
    if current:
        total = format_time(length)
        lines.append(f"{current} / {total}" if total and total != "0:00" else current)

    # Other running players (multi-stream awareness)
    others = []
    for name, info in players.items():
        if name == chosen:
            continue
        others.append(f"{name.capitalize()} ({info[0]})")
    if others:
        lines.append(
            "<span size='small' foreground='#6272a4'>other players: "
            + html.escape(", ".join(others), quote=False) + "</span>"
        )

    lines.append(
        "<span size='small' foreground='#6272a4'>"
        "left: play/pause · right: next · middle: previous</span>"
    )

    print(json.dumps(
        {"text": text, "tooltip": "\n".join(lines), "class": state},
        ensure_ascii=False,
        separators=(",", ":"),
    ))


if __name__ == "__main__":
    main()
