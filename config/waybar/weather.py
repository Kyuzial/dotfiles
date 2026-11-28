#!/usr/bin/env python3
"""
Waybar weather module using Open-Meteo API (no API key required).
High precision forecasts powered by ECMWF & DWD models.
Outputs JSON formatted for Waybar:
  - text:    compact bar label (e.g. " 25°C  ↑27° ↓16°  ↗NE 14km/h")
  - tooltip: rich multi-line hourly & 3-day forecast
  - class:   CSS class for styling (sunny, partly, cloudy, foggy, rainy, drizzle, snowy, sleet, stormy)
"""

import json
import sys
import urllib.request
from datetime import datetime

# ── WMO Code → (Description, NerdFont/Icon, CSS Class) ────────────────────────
WMO_CODES: dict[int, tuple[str, str, str]] = {
    0:  ("Clear sky", "", "sunny"),
    1:  ("Mainly clear", "", "sunny"),
    2:  ("Partly cloudy", "", "partly"),
    3:  ("Overcast", "󰖐", "cloudy"),
    45: ("Foggy", "", "foggy"),
    48: ("Depositing rime fog", "", "foggy"),
    51: ("Light drizzle", "", "drizzle"),
    53: ("Moderate drizzle", "", "drizzle"),
    55: ("Dense drizzle", "", "drizzle"),
    56: ("Light freezing drizzle", "", "sleet"),
    57: ("Dense freezing drizzle", "", "sleet"),
    61: ("Slight rain", "", "rainy"),
    63: ("Moderate rain", "", "rainy"),
    65: ("Heavy rain", "", "rainy"),
    66: ("Light freezing rain", "", "sleet"),
    67: ("Heavy freezing rain", "", "sleet"),
    71: ("Slight snow", "", "snowy"),
    73: ("Moderate snow", "", "snowy"),
    75: ("Heavy snow", "", "snowy"),
    77: ("Snow grains", "", "snowy"),
    80: ("Slight rain showers", "", "rainy"),
    81: ("Moderate rain showers", "", "rainy"),
    82: ("Violent rain showers", "", "rainy"),
    85: ("Slight snow showers", "", "snowy"),
    86: ("Heavy snow showers", "", "snowy"),
    95: ("Thunderstorm", "⛈", "stormy"),
    96: ("Thunderstorm with hail", "⛈", "stormy"),
    99: ("Heavy thunderstorm", "⛈", "stormy"),
}

WIND_DIRS = ["↑N", "↗NE", "→E", "↘SE", "↓S", "↙SW", "←W", "↖NW"]

def get_wmo_info(code: int) -> tuple[str, str, str]:
    return WMO_CODES.get(code, ("Unknown", "?", "unknown"))

def wind_arrow(degrees: float) -> str:
    return WIND_DIRS[round(degrees / 45) % 8]

def format_iso_time(iso_str: str) -> str:
    """Format ISO timestamp like '2026-07-24T06:13' into '6:13 AM'."""
    try:
        dt = datetime.fromisoformat(iso_str)
        return dt.strftime("%I:%M %p").lstrip("0")
    except Exception:
        return iso_str.split("T")[-1]

def fetch_location() -> tuple[float, float, str, str]:
    """Fetch current location via IP geolocation APIs."""
    # Try ip-api.com
    try:
        req = urllib.request.Request("http://ip-api.com/json/", headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=4) as resp:
            geo = json.load(resp)
            if geo.get("status") == "success":
                return geo["lat"], geo["lon"], geo.get("city", "Unknown"), geo.get("regionName", "")
    except Exception:
        pass

    # Fallback to ipinfo.io
    try:
        req = urllib.request.Request("https://ipinfo.io/json", headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=4) as resp:
            geo = json.load(resp)
            loc = geo.get("loc", "48.8566,2.3522").split(",")
            return float(loc[0]), float(loc[1]), geo.get("city", "Unknown"), geo.get("region", "")
    except Exception:
        pass

    # Default fallback (Paris)
    return 48.8566, 2.3522, "Paris", "Île-de-France"

def main():
    try:
        lat, lon, city, region = fetch_location()

        om_url = (
            f"https://api.open-meteo.com/v1/forecast?"
            f"latitude={lat}&longitude={lon}&"
            f"current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m&"
            f"hourly=temperature_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m,wind_direction_10m&"
            f"daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&"
            f"timezone=auto"
        )
        req = urllib.request.Request(om_url, headers={"User-Agent": "WaybarWeather/1.0"})
        with urllib.request.urlopen(req, timeout=8) as resp:
            data = json.load(resp)
    except Exception as e:
        print(json.dumps({"text": "  N/A", "tooltip": str(e), "class": "unknown"}))
        sys.exit(0)

    cur   = data["current"]
    daily = data["daily"]
    hourly= data["hourly"]

    code      = int(cur["weather_code"])
    desc, icon, css = get_wmo_info(code)

    temp      = round(cur["temperature_2m"])
    feels     = round(cur["apparent_temperature"])
    humidity  = cur["relative_humidity_2m"]
    wind_spd  = round(cur["wind_speed_10m"])
    wind_deg  = cur["wind_direction_10m"]
    warrow    = wind_arrow(wind_deg)

    hi        = round(daily["temperature_2m_max"][0])
    lo        = round(daily["temperature_2m_min"][0])
    uv        = daily["uv_index_max"][0]
    sunrise   = format_iso_time(daily["sunrise"][0])
    sunset    = format_iso_time(daily["sunset"][0])

    icon_prefix = f"{icon}  " if icon else ""
    text = f"{icon_prefix}{temp}°C  ↑{hi}° ↓{lo}°  {warrow} {wind_spd}km/h".strip()

    # ── Tooltip ──────────────────────────────────────────────────────────────
    now_time = datetime.now().strftime("%H:%M")
    lines = [
        f"<b> {city}, {region}</b>   🕐 {now_time}",
        f"<b>{icon_prefix}{desc}</b>",
        "",
        f"  🌡  {temp}°C   feels like {feels}°C",
        f"  💧 Humidity: {humidity}%",
        f"  {warrow}  Wind: {wind_spd} km/h",
        f"  ☀  UV index: {uv}",
        f"  🌅 Sunrise: {sunrise}   🌇 Sunset: {sunset}",
        "",
        f"<b>Today — ↑ {hi}°C  ↓ {lo}°C</b>",
        "─" * 70,
    ]

    # Today hourly breakdown (every 3 hours)
    today_str = daily["time"][0]
    for idx, t_str in enumerate(hourly["time"]):
        if t_str.startswith(today_str):
            hour = int(t_str.split("T")[1].split(":")[0])
            if hour % 3 == 0:
                h_code = int(hourly["weather_code"][idx])
                h_desc, h_icon, _ = get_wmo_info(h_code)
                h_temp = round(hourly["temperature_2m"][idx])
                h_feels = round(hourly["apparent_temperature"][idx])
                h_pop = hourly["precipitation_probability"][idx]
                h_wspd = round(hourly["wind_speed_10m"][idx])
                h_wdeg = hourly["wind_direction_10m"][idx]
                h_warrow = wind_arrow(h_wdeg)
                h_time = f"{hour:02d}:00"
                h_icon_str = f"{h_icon}  " if h_icon else ""
                lines.append(
                    f"  {h_time}   {h_icon_str}{h_desc:<20}  {h_temp:>3}°C (feels {h_feels}°C)  {h_pop:>3}% rain   {h_warrow} {h_wspd} km/h"
                )

    # 3-day forecast summary
    lines += ["", "<b>3-day forecast</b>", "─" * 70]
    for d in range(min(3, len(daily["time"]))):
        d_date = daily["time"][d]
        d_hi = round(daily["temperature_2m_max"][d])
        d_lo = round(daily["temperature_2m_min"][d])
        d_code = int(daily["weather_code"][d])
        d_desc, d_icon, _ = get_wmo_info(d_code)
        
        # calculate max rain probability for this day
        day_pops = [hourly["precipitation_probability"][i] for i, t in enumerate(hourly["time"]) if t.startswith(d_date)]
        max_pop = max(day_pops) if day_pops else 0
        d_icon_str = f"{d_icon}  " if d_icon else ""
        lines.append(f"  {d_date}   {d_icon_str}{d_desc:<20}  ↑{d_hi}° ↓{d_lo}°   {max_pop}% rain")

    output = {
        "text": text,
        "tooltip": "\n".join(lines),
        "class": css,
    }
    print(json.dumps(output))

if __name__ == "__main__":
    main()
