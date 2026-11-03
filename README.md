# waybar

Czarno-biały, „terminalowy” pasek dla **Hyprlanda**. Po lewej pulpity z ikonami ich okien (jak pasek zadań w Windowsie, klik w ikonę = fokus na okno) i tytuł okna zakończony kursorem `█`, na środku zegar, po prawej odtwarzacz, dźwięk i tray.

- **auto-hide** (`autohide.sh`): pasek chowa się sam i wraca po najechaniu myszą na górną krawędź głównego monitora,
- **ikony gier** (`game-icons.py`, odpalany z `launch.sh`): gry ze Steama i Heroica mają klasy okien `steam_app_…`, więc dla ich ikon na pulpitach tworzy ukryte skróty `~/.local/share/applications/steam_app_<id>.desktop`,
- **tylko na głównym monitorze** (`launch.sh`): `$PRIMARY_MONITOR` albo największy, bez wpisanych na sztywno nazw.

> Część zestawu **[linux-tools](https://github.com/K-u-r-c/linux-tools)**.

## Instalacja

```bash
sudo pacman -S --needed waybar jq ttf-meslo-nerd playerctl pavucontrol

[ -d ~/.config/waybar ] && mv ~/.config/waybar ~/.config/waybar.bak
git clone https://github.com/K-u-r-c/waybar ~/.config/waybar
```

W `hyprland.conf` (w moim [hypr](https://github.com/K-u-r-c/hypr) już jest):

```ini
exec-once = ~/.config/waybar/launch.sh
exec-once = ~/.config/waybar/autohide.sh
```

Aktualizacja: `git -C ~/.config/waybar pull && pkill waybar; ~/.config/waybar/launch.sh & disown`.

## Współpraca

| Z czym | Po co | Bez tego |
|---|---|---|
| [hypr](https://github.com/K-u-r-c/hypr): `primary-monitor.sh` | wybór monitora dla paska i krawędzi auto-hide | pasek na wszystkich monitorach, auto-hide na całej szerokości |
