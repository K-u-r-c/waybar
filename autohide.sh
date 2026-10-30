#!/usr/bin/env bash

sleep 1

# pasek jest na głównym monitorze – krawędź i zakres X liczymy względem niego, nie od y=0
read -r mon_x mon_y mon_w < <("$HOME/.config/hypr/primary-monitor.sh" --json |
  jq -r '[.x, .y, ((if .transform % 2 == 1 then .height else .width end) / .scale | floor)] | @tsv')
mon_x=${mon_x:-0} mon_y=${mon_y:-0} mon_w=${mon_w:-99999}

visible=true

while true; do
  read -r x y < <(hyprctl cursorpos -j 2>/dev/null | jq -r '"\(.x) \(.y)"')

  if [[ -z "$y" || "$y" == "null" ]]; then
    sleep 0.1
    continue
  fi

  on_mon=false
  ((x >= mon_x && x < mon_x + mon_w)) && on_mon=true

  if { [[ "$on_mon" == false ]] || ((y > mon_y + 40)); } && [[ "$visible" == true ]]; then
    pkill -SIGUSR1 waybar
    visible=false
  fi

  if [[ "$on_mon" == true ]] && ((y <= mon_y + 3)) && [[ "$visible" == false ]]; then
    pkill -SIGUSR1 waybar
    visible=true
  fi

  sleep 0.08
done
