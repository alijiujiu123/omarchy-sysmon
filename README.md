# Sysmon

CPU %, memory %, and network rate for the [Omarchy](https://omarchy.org/) bar,
in a framed pill. Clicking it opens a maximized `btop`; clicking again focuses
the window instead of opening a second one.

```
╭──────────────────────────────────────────────╮
│ CPU   4% MEM  30% ↓ 161K ↑12.0K              │   left click  → maximized btop
╰──────────────────────────────────────────────╯   right click → htop
```

## Install

```bash
omarchy plugin add https://github.com/<you>/omarchy-sysmon.git --enable --yes
omarchy bar move alijiujiu.sysmon --section center --after omarchy.spacer
```

Installed plugins land disabled; `--enable` places the widget in the section
from its manifest (`center`). The `omarchy bar move` line is optional - it only
matters if you want a gap between the pill and whatever sits to its left.

Dependencies: `btop` for the detail view (`omarchy pkg add btop`), `htop` for
the right-click shortcut (`omarchy pkg add htop`). Set `SYSMON_MONITOR=htop` in
the environment if you prefer htop in the maximized view.

## What it shows

| Field | Source | Meaning |
|---|---|---|
| `CPU n%` | `/proc/stat` | average over the last refresh interval |
| `MEM n%` | `/proc/meminfo` | `MemTotal - MemAvailable`, so it tracks real pressure |
| `↓ n ↑ n` | `/proc/net/dev` | down/up rate summed over every non-loopback interface |

Every number is printed at a fixed width, so the pill never resizes and never
shifts its neighbours as digits change. At 85% CPU or memory the frame switches
to the theme's urgent colour.

## Settings

Settings live in the bar entry and are read per widget instance:

```bash
omarchy bar set alijiujiu.sysmon interval 1        # refresh interval, seconds
omarchy bar set alijiujiu.sysmon fontSize 10
omarchy bar set alijiujiu.sysmon borderAlpha 0.4   # frame opacity, 0 hides it
omarchy bar set alijiujiu.sysmon 'onClick' 'omarchy-launch-or-focus-tui htop'
```

| Key | Default | Effect |
|---|---|---|
| `interval` | `2` | seconds between samples |
| `fontSize` | `11` | readout font size |
| `borderAlpha` | `0.7` | frame/border opacity (`0` = bare numbers) |
| `onClick` | bundled `bin/open-monitor` | left click command |
| `onRightClick` | `omarchy-launch-or-focus-tui htop` | right click command |
| `onMiddleClick` | unset | middle click command |

Editing `Widget.qml` or the scripts needs `omarchy restart shell` - QML is
cached per URL and is not reloaded when the file changes.

## Layout of the repo

```
manifest.json      plugin manifest (id, kinds, entry point, settings schema)
Widget.qml         bar-widget entry point: the framed pill and its input
bin/sysmon         metrics sampler, prints one waybar-style JSON line
bin/open-monitor   launches (or focuses) the maximized detail view
```

`bin/sysmon` is a plain script rather than QML on purpose: it keeps the /proc
parsing and the fixed-width formatting testable from a shell, and the widget
only draws what it prints.

## Update / remove

```bash
omarchy plugin update alijiujiu.sysmon
omarchy plugin remove alijiujiu.sysmon
```

## License

MIT
