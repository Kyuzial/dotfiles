#!/usr/bin/env python3
"""
Waybar weather module — uses wttr.in (no API key needed).
Outputs JSON with:
  - text:    compact bar label  e.g. "  23°C  ↑26°  ↓12°"
  - tooltip: rich multi-line day forecast
  - class:   CSS class for colouring (sunny / cloudy / rainy / snowy / stormy)
"""

import json
import sys
import urllib.request
from datetime import datetime

# ── Weather-code → (Nerd Font icon, CSS class) ───────────────────────────────
WC: dict[int, tuple[str, str]] = {
    113: ("", "sunny"),       # Sunny / Clear
    116: ("", "partly"),      # Partly Cloudy
    119: ("󰖐", "cloudy"),     # Cloudy
    122: ("", "cloudy"),      # Overcast
    143: ("", "foggy"),       # Mist
    176: ("", "rainy"),       # Patchy rain nearby
    179: ("", "snowy"),       # Patchy snow nearby
    182: ("", "sleet"),       # Patchy sleet nearby
    185: ("", "sleet"),       # Patchy freezing drizzle
    200: ("", "stormy"),      # Thundery outbreaks
    227: ("", "snowy"),       # Blowing snow
    230: ("", "snowy"),       # Blizzard
    248: ("", "foggy"),       # Fog
    260: ("", "foggy"),       # Freezing fog
    263: ("", "drizzle"),     # Light drizzle
    266: ("", "drizzle"),     # Drizzle
    281: ("", "sleet"),       # Freezing drizzle
    284: ("", "sleet"),       # Heavy freezing drizzle
    293: ("", "rainy"),       # Light rain
    296: ("", "rainy"),       # Light rain
    299: ("", "rainy"),       # Moderate rain
    302: ("", "rainy"),       # Moderate rain
    305: ("", "rainy"),       # Heavy rain
    308: ("", "rainy"),       # Heavy rain
    311: ("", "sleet"),       # Light sleet
    314: ("", "sleet"),       # Moderate sleet
    317: ("", "sleet"),       # Light sleet
    320: ("", "snowy"),       # Light snow
    323: ("", "snowy"),       # Patchy light snow
    326: ("", "snowy"),       # Light snow
    329: ("", "snowy"),       # Patchy moderate snow
    332: ("", "snowy"),       # Moderate snow
    335: ("", "snowy"),       # Patchy heavy snow
    338: ("", "snowy"),       # Heavy snow
    350: ("", "sleet"),       # Ice pellets
    353: ("", "rainy"),       # Light rain shower
    356: ("", "rainy"),       # Moderate/heavy rain shower
    359: ("", "rainy"),       # Torrential rain
    362: ("", "sleet"),       # Light sleet shower
    365: ("", "sleet"),       # Moderate sleet shower
    368: ("", "snowy"),       # Light snow shower
    371: ("", "snowy"),       # Moderate/heavy snow shower
    374: ("", "sleet"),       # Light ice-pellet shower
    377: ("", "sleet"),       # Moderate ice-pellet shower
    386: ("⛈", "stormy"),     # Thundery rain
    389: ("⛈", "stormy"),     # Heavy thundery rain
    392: ("⛈", "stormy"),     # Thundery snow
    395: ("⛈", "stormy"),     # Heavy thundery snow
}

WIND_DIRS = ["↑N","↗NE","→E","↘SE","↓S","↙SW","←W","↖NW"]

def wc_info(code: int) -> tuple[str, str]:
    return WC.get(code, ("?", "unknown"))

def wind_arrow(degrees: int) -> str:
    return WIND_DIRS[round(degrees / 45) % 8]

def format_time(t: str) -> str:
    """'1200' → '12:00'"""
    t = t.zfill(4)
    return f"{t[:2]}:{t[2:]}"

def hourly_line(h: dict) -> str:
    code  = int(h["weatherCode"])
    icon, _ = wc_info(code)
    temp  = h["tempC"]
    feels = h["FeelsLikeC"]
    rain  = h["chanceofrain"]
    wind  = int(h["windspeedKmph"])
    wdir  = wind_arrow(int(h["winddirDegree"]))
    time  = format_time(h["time"])
    desc  = h["weatherDesc"][0]["value"]
    parts = [
        f"  {time}  {icon} {desc:<20}",
        f"{temp:>3}°C (feels {feels}°C)",
        f"  {rain:>3}% rain",
        f" {wdir} {wind} km/h",
    ]
    return "  ".join(parts)

def main():
    try:
        url = "https://wttr.in/?format=j1"
        with urllib.request.urlopen(url, timeout=8) as resp:
            data = json.load(resp)
    except Exception as e:
        print(json.dumps({"text": "  N/A", "tooltip": str(e), "class": "unknown"}))
        sys.exit(0)

    cur  = data["current_condition"][0]
    area = data["nearest_area"][0]
    today = data["weather"][0]

    code      = int(cur["weatherCode"])
    icon, css = wc_info(code)
    temp      = cur["temp_C"]
    feels     = cur["FeelsLikeC"]
    humidity  = cur["humidity"]
    wind_spd  = cur["windspeedKmph"]
    wind_deg  = int(cur["winddirDegree"])
    uv        = cur["uvIndex"]
    desc      = cur["weatherDesc"][0]["value"]

    city      = area["areaName"][0]["value"]
    region    = area["region"][0]["value"]

    hi        = today["maxtempC"]
    lo        = today["mintempC"]
    sunrise   = today["astronomy"][0]["sunrise"]
    sunset    = today["astronomy"][0]["sunset"]

    # ── Bar text ─────────────────────────────────────────────────────────────
    warrow = wind_arrow(wind_deg)
    text = f"{icon} {temp}°C  ↑{hi}° ↓{lo}°  {warrow} {wind_spd}km/h"

    # ── Tooltip ──────────────────────────────────────────────────────────────
    now = datetime.now().strftime("%H:%M")
    lines = [
        f"<b> {city}, {region}</b>   🕐 {now}",
        f"<b>{icon} {desc}</b>",
        f"",
        f"  🌡  {temp}°C   feels like {feels}°C",
        f"  💧 Humidity: {humidity}%",
        f"  {warrow}  Wind: {wind_spd} km/h",
        f"  ☀  UV index: {uv}",
        f"  🌅 Sunrise: {sunrise}   🌇 Sunset: {sunset}",
        f"",
        f"<b>Today — ↑ {hi}°C  ↓ {lo}°C</b>",
        "─" * 70,
    ]
    for h in today["hourly"]:
        lines.append(hourly_line(h))

    # 3-day forecast summary
    lines += ["", "<b>3-day forecast</b>", "─" * 70]
    for day in data["weather"]:
        date = day["date"]
        dhi  = day["maxtempC"]
        dlo  = day["mintempC"]
        # pick noon slot
        noon = next((h for h in day["hourly"] if h["time"] == "1200"), day["hourly"][0])
        dc   = int(noon["weatherCode"])
        di, _= wc_info(dc)
        ddesc = noon["weatherDesc"][0]["value"]
        rain  = noon["chanceofrain"]
        lines.append(f"  {date}   {di} {ddesc:<20}  ↑{dhi}° ↓{dlo}°   {rain}% rain")

    output = {
        "text":    text,
        "tooltip": "\n".join(lines),
        "class":   css,
    }
    print(json.dumps(output))

if __name__ == "__main__":
    main()
