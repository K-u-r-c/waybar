#!/usr/bin/env bash
# Auto-hide waybara: pasek wraca po najechaniu myszą na górną krawędź głównego monitora.
#
# SIGUSR1 to w waybarze PRZEŁĄCZNIK (pokaż/ukryj), więc nie można ufać zapamiętanemu stanowi:
# po mignięciu ekranu / zmianie trybu / restarcie waybara pasek wraca jako widoczny i stan się odwraca.
# Dlatego prawdziwy stan czytamy z Hyprlanda (hyprctl layers): widoczny waybar jest na warstwie
# top/overlay (2-3), ukryty na bottom (1). Co ~1 s stan jest wyrównywany, co ~5 s geometria monitora.

# tylko jedna kopia (exec-once + ręczne uruchomienie)
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-autohide.lock"
flock -n 9 || exit 0

sleep 1

read_geometry() {
  # pasek jest na głównym monitorze – krawędź i zakres X liczymy względem niego, nie od y=0
  read -r mon_x mon_y mon_w < <("$HOME/.config/hypr/primary-monitor.sh" --json 2>/dev/null |
    jq -r '[.x, .y, ((if .transform % 2 == 1 then .height else .width end) / .scale | floor)] | @tsv')
  mon_x=${mon_x:-0} mon_y=${mon_y:-0} mon_w=${mon_w:-99999}
}

# 1 = widoczny, 0 = ukryty, "" = waybar nie działa
real_state() {
  hyprctl layers -j 2>/dev/null | jq -r '
    [.[].levels | to_entries[] | select(any(.value[]; .namespace == "waybar")) | .key | tonumber]
    | if length == 0 then "" elif max >= 2 then 1 else 0 end'
}

# ustawia pasek na $1 (1/0), przełączając tylko gdy faktycznie jest inaczej
apply() {
  local want=$1 real
  real=$(real_state)
  [[ -z "$real" || "$real" == "$want" ]] && return
  pkill -USR1 -x waybar
  grace=4   # warstwa zmienia się asynchronicznie – chwilę nie sprawdzamy, żeby nie przełączyć dwa razy
}

read_geometry
want=0 last=-1 tick=0 grace=0

while true; do
  read -r x y < <(hyprctl cursorpos -j 2>/dev/null | jq -r '"\(.x) \(.y)"')

  if [[ -n "$y" && "$y" != "null" ]]; then
    on_mon=false
    ((x >= mon_x && x < mon_x + mon_w)) && on_mon=true

    if [[ "$on_mon" == true ]] && ((y <= mon_y + 3)); then
      want=1
    elif [[ "$on_mon" == false ]] || ((y > mon_y + 40)); then
      want=0
    fi   # między 4 a 40 px: bez zmian, żeby pasek nie znikał pod kursorem
  fi

  ((tick++))
  ((grace > 0)) && ((grace--))

  if [[ "$want" != "$last" ]]; then
    apply "$want"
    last=$want
  elif ((tick % 12 == 0 && grace == 0)); then
    apply "$want"
  fi

  ((tick % 60 == 0)) && read_geometry

  sleep 0.08
done
