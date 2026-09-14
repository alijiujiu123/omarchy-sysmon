# AGENTS.md — omarchy-sysmon

Framed CPU / memory / network-rate readout for the Omarchy bar, with one-click btop detail.
A **shell plugin** (Quickshell/QML: `manifest.json` + `Widget.qml` + `bin/sysmon`), not a
compositor plugin — so it has no `.so`, no Hyprland ABI, and none of the crash surface a
Hyprland plugin has. `README.md` has the user-facing description.

## How it is installed on my machines

`omarchy plugin add https://github.com/alijiujiu123/omarchy-sysmon --enable --yes`, run by
the `shell` module of **`omarchy-setup-kit`** — the hub that owns how this machine is
assembled and configured (`docs/architecture.md` there). Two consequences worth remembering:

- `omarchy plugin add` clones this repo and reads `manifest.json` **from the repo root**.
  Nothing may be moved out of the root, and this repo cannot be merged into another one.
- The kit owns **bar placement and enablement** (`omarchy bar move alijiujiu.sysmon
  --section center --after omarchy.spacer`). If you change the default section/placement,
  change it in the kit's `modules/shell/install.sh` too, or the next machine gets the old
  layout.

The installed copy is a git clone at `~/.config/omarchy/plugins/alijiujiu.sysmon`, so
`./status.sh` in the kit can compare its commit with this repo's — keep them in sync by
pushing here and running `omarchy plugin update alijiujiu.sysmon`.

## Working loop

```bash
cd ~/Projects/omarchy-sysmon
# edit Widget.qml / bin/sysmon / manifest.json
git commit && git push                                   # plain semver, independent of Hyprland
omarchy plugin update alijiujiu.sysmon && omarchy restart shell   # apply locally
cd ~/Projects/omarchy-setup-kit && ./status.sh           # repo vs installed clone, enablement
```

- Never edit the packaged copy under `/usr/share/omarchy/` (package-owned, overwritten by
  `omarchy update`); the version the shell loads is the clone under `~/.config/omarchy/plugins/`.
- Hot reload: QML changes are picked up by restarting the shell; there is no unload/load
  dance and no risk of killing the session.
- Bump `version` in `manifest.json` for user-visible changes — that is what makes an update
  observable in `omarchy plugin list`.

## Definition of done

1. Change works in the running shell (`omarchy plugin update … && omarchy restart shell`),
   and `manifest.json` still validates (`omarchy plugin validate .`).
2. Pushed here, and the installed clone updated to the same commit.
3. If the default placement, enablement or the repo URL changed: the kit's `shell` module
   updated as well, with `./status.sh` reporting no drift afterwards.
