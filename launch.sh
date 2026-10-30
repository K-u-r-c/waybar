#!/usr/bin/env bash
# Waybar tylko na głównym monitorze (hypr/monitors.conf -> PRIMARY_MONITOR, domyślnie największy).
# config.jsonc dociąga "output" z pliku generowanego tutaj.

mkdir -p "$HOME/.cache/waybar"
primary=$("$HOME/.config/hypr/primary-monitor.sh")
if [[ -n "$primary" && "$primary" != null ]]; then
    printf '{ "output": ["%s"] }\n' "$primary" > "$HOME/.cache/waybar/output.jsonc"
else
    echo '{}' > "$HOME/.cache/waybar/output.jsonc"   # nie wiadomo który – pasek na wszystkich
fi
exec waybar
