#!/usr/bin/env bash

sleep 1

visible=true

while true; do
  y=$(hyprctl cursorpos -j | jq -r '.y' 2>/dev/null)

  if [[ -z "$y" || "$y" == "null" ]]; then
    sleep 0.1
    continue
  fi

  if ((y > 40)) && [[ "$visible" == true ]]; then
    pkill -SIGUSR1 waybar
    visible=false
  fi

  if ((y <= 3)) && [[ "$visible" == false ]]; then
    pkill -SIGUSR1 waybar
    visible=true
  fi

  sleep 0.08
done
