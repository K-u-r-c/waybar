#!/usr/bin/env python3
# Ikony gier dla pulpitów na pasku. workspace-taskbar szuka pliku <klasa okna>.desktop, a gry mają klasy
# w stylu steam_app_<id>, których żaden skrót nie nosi. Tu dorabiamy ukryte (NoDisplay) skróty pod tą nazwą:
#   - Steam: skróty z Exec=steam steam://rungameid/<id> -> steam_app_<id>.desktop z ich ikoną,
#   - skróty z StartupWMClass=steam_app_… (np. gry z Heroica) -> <klasa>.desktop z ich ikoną.
# Odpalane z launch.sh przy każdym starcie paska; tworzy tylko brakujące pliki.

import configparser
import re
from pathlib import Path

APPS = Path.home() / ".local/share/applications"
MARK = "X-Waybar-Game-Icon=true"   # nasze pliki – żeby nie ruszać cudzych


def read_entry(path):
    cp = configparser.ConfigParser(interpolation=None, strict=False)
    cp.optionxform = str
    try:
        cp.read(path, encoding="utf-8")
        return cp["Desktop Entry"]
    except Exception:
        return None


for desk in APPS.glob("*.desktop"):
    if desk.name.startswith("steam_app_"):
        continue
    e = read_entry(desk)
    if e is None or not e.get("Icon"):
        continue
    m = re.match(r"steam\s+steam://rungameid/(\d+)", e.get("Exec", ""))
    cls = f"steam_app_{m.group(1)}" if m else e.get("StartupWMClass", "")
    if not cls.startswith("steam_app_"):
        continue
    out = APPS / f"{cls}.desktop"
    if out.exists():
        continue
    out.write_text(
        "[Desktop Entry]\n"
        "Type=Application\n"
        f"Name={e.get('Name', cls)}\n"
        f"Icon={e['Icon']}\n"
        "Exec=true\n"
        "NoDisplay=true\n"
        f"StartupWMClass={cls}\n"
        f"{MARK}\n"
    )
