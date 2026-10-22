#!/usr/bin/env bash
# Auto-hide waybar: pokazuje się tylko, gdy kursor dotknie górnej krawędzi.
# SIGUSR1 to toggle, więc śledzimy PID waybara – po jego restarcie
# stan jest resetowany (świeży waybar startuje jako widoczny).

sleep 1

visible=true
last_pid=""

while true; do
  pid=$(pgrep -xo waybar)

  if [[ -z "$pid" ]]; then
    last_pid=""
    sleep 0.5
    continue
  fi

  if [[ "$pid" != "$last_pid" ]]; then
    # nowa instancja waybara -> jest widoczna
    last_pid="$pid"
    visible=true
    sleep 0.3
  fi

  y=$(hyprctl cursorpos -j | jq -r '.y' 2>/dev/null)

  if [[ -z "$y" || "$y" == "null" ]]; then
    sleep 0.1
    continue
  fi

  if ((y > 40)) && [[ "$visible" == true ]]; then
    kill -SIGUSR1 "$pid"
    visible=false
  fi

  if ((y <= 3)) && [[ "$visible" == false ]]; then
    kill -SIGUSR1 "$pid"
    visible=true
  fi

  sleep 0.08
done
