# Shell guide: changing the bar and the menu

Both are plain data files. You edit a file, save, and the shell picks it up. No restart, no code.

| What | File |
|---|---|
| Bar | `~/.config/omarchy/shell.json` → `bar.layout` |
| Menu (Super+Space) | `~/.config/omarchy/extensions/omarchy-menu.jsonc` |

`oq` in the commands below is the wrapper that gives a command the shell's environment. Use it in a terminal and in keybinds. Inside the two files you do not need it.

---

## Part 1: the bar

Open `~/.config/omarchy/shell.json` and find `bar.layout`. It has three lists:

```json
"layout": {
  "left":   [ { "id": "omarchy.menu" }, { "id": "omarchy.workspaces" } ],
  "center": [ { "id": "omarchy.clock" } ],
  "right":  [ { "id": "omarchy.audio" }, { "id": "omarchy.power", "showPercentage": true } ]
}
```

Each `{ ... }` is one widget. The order in a list is the order on the bar. Options for a widget sit next to its `id` in the same entry.

### Remove a widget

Delete its `{ ... }` entry. Mind the commas: every entry except the last one in a list ends with a comma.

### Move a widget

Either drag it on the bar with the left mouse button, or cut its entry and paste it at another position or in another list.

### Add a built-in widget

Add an entry with its id:

```json
{ "id": "omarchy.tailscale" }
```

Available ids:

| Id | Shows |
|---|---|
| `omarchy.menu` | Logo button that opens the menu |
| `omarchy.workspaces` | Workspaces |
| `omarchy.active-window` | Title of the focused window |
| `omarchy.clock` | Clock |
| `omarchy.elsewhen` | World clock |
| `omarchy.weather` | Weather |
| `omarchy.media` | Playing media |
| `omarchy.indicators` | Night light, do-not-disturb, recording, stay-awake |
| `omarchy.system-update` | Pending updates |
| `omarchy.keyboard-layout` | Keyboard layout |
| `omarchy.tray` | System tray |
| `omarchy.agents` | AI agent usage |
| `omarchy.bluetooth` | Bluetooth |
| `omarchy.network` | Wi-Fi and network |
| `omarchy.audio` | Volume |
| `omarchy.microphone` | Microphone (red while something records) |
| `omarchy.monitor` | Display settings |
| `omarchy.power` | Battery |
| `omarchy.tailscale` | Tailscale |
| `omarchy.dropbox` | Dropbox |
| `omarchy.spacer` | Empty gap |

`oq omarchy plugin list` prints the current list.

### Add your own widget

Use a command module. The `id` is any name you choose, and `"type": "command"` is what makes it one.

A label that updates:

```json
{ "id": "vpn", "type": "command",
  "exec": "warp-cli status | rg -o 'Connected|Disconnected'",
  "interval": 5,
  "tooltip": "WARP",
  "onClick": "warp-cli connect",
  "onRightClick": "warp-cli disconnect" }
```

An icon button that does not update:

```json
{ "id": "files", "type": "command", "text": "󰉋", "fontSize": 15,
  "tooltip": "Files", "onClick": "nautilus" }
```

| Option | Meaning |
|---|---|
| `exec` | Command run every `interval` seconds. Its output is the label. Print the icon as part of the output. |
| `interval` | Seconds between runs. Default 5. |
| `stream` | `true` for a command that keeps running and prints a line whenever its reading changes. Each line replaces the label. Cheaper than `interval` for anything that updates often; the bar restarts it if it exits. |
| `text` | Fixed label, used when there is no `exec`. |
| `onClick`, `onRightClick`, `onMiddleClick` | Command to run on that click. |
| `tooltip` | Text shown on hover. |
| `fontSize` | Size in pixels. Use 14 for text and 15 for a lone icon to match the rest of the bar. |
| `color` | Colour of the label. A theme name (`red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `grey`, `accent`) follows the theme; a hex value like `#a6e3a1` is used as is. |

For anything longer than one line, put a script in `~/.local/bin` and call it from `exec`. The CPU, memory and network readings already on the bar come from one such script, `bar-stat`, used as a stream. The number is the seconds between readings:

```json
{ "id": "cpu", "type": "command", "exec": "bar-stat cpu 3", "stream": true }
```

It has `cpu`, `mem`, `net`, `camera` and `screencast`. A command runs once however many monitors show the bar.

`exec` may also print JSON in the waybar style, so an existing waybar script usually works unchanged:

```json
{ "text": "󰖂 on", "tooltip": "WARP connected", "class": "active" }
```

`"class": "active"` draws the label in the alert colour. `"color"` sets any colour for that run, which is how a status light works:

```json
{ "text": "󰖂", "color": "green", "tooltip": "WARP: Connected" }
```

Terminal colour codes (`\033[32m…`) do not work here. The bar shows plain text, so colour has to come from `color`.

### Add a gap

Sections have no spacing setting; a gap is a widget of its own. Put a spacer where you want the gap, with its width in pixels:

```json
{ "id": "omarchy.spacer", "size": 12 }
```

You can add as many spacers as you like. To loosen one command module only, give it `"horizontalMargin": 14` (the default is 7.5 on each side).

### Privacy icons

Three icons show what is in use. Each turns red while active; hover for which app or screen.

```json
{ "id": "omarchy.microphone" },
{ "id": "camera", "type": "command", "exec": "bar-stat camera 2", "stream": true, "fontSize": 15 },
{ "id": "screencast", "type": "command", "exec": "bar-stat screencast", "stream": true, "fontSize": 15 }
```

### Apply

Saving the file is enough. If the bar does not change:

```bash
oq omarchy-shell shell reloadConfig
```

### Do it from the terminal instead

```bash
oq omarchy-bar put omarchy.tailscale --section right      # add
oq omarchy-bar move omarchy.clock --section left --index 1 # move
oq omarchy-bar move omarchy.audio --before omarchy.power   # move next to another
oq omarchy plugin disable omarchy.weather                  # remove
oq omarchy-bar position bottom                             # top | bottom | left | right
```

### Other bar settings

In the same file, next to `layout`:

- `"position"`: `top`, `bottom`, `left` or `right`.
- `"transparent"`: `true` or `false`.

Text size for the whole shell is in `~/.config/omarchy/shell.toml` (`[font] base-size`). The Text size control in the Display panel writes the same value.

---

## Part 2: the menu

Open `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Each line is one row:

```jsonc
"trigger.dotfiles": {"icon":"󰊢","label":"Dotfiles status","action":"omarchy-launch-floating-terminal-with-presentation 'git -C ~/.dotfiles status'"},
```

### Where a row appears

The id decides it. Dots are levels:

- `mine` sits on the root menu.
- `mine.notes` sits inside `mine`.
- `trigger.dotfiles` sits inside the existing Trigger menu.

The root menus that ship are `apps`, `trigger`, `style`, `setup`, `install`, `remove`, `update`, `about` and `system`.

### Add a row that runs something

Give it an `action`. It is a bash command, started in the background with no terminal:

```jsonc
"mine.notes": {"icon":"󰎞","label":"Notes","action":"footclient -e nvim ~/notes.md"},
```

If the command prints output you want to read, wrap it so it opens a floating terminal and waits for a key:

```jsonc
"mine.disk": {"icon":"󰋊","label":"Disk usage","action":"omarchy-launch-floating-terminal-with-presentation 'df -h'"},
```

### Add a submenu

A row without an `action` is a submenu. Its children are the ids that start with its name:

```jsonc
"mine": {"icon":"󰣇","label":"Mine"},
"mine.notes": {"icon":"󰎞","label":"Notes","action":"footclient -e nvim ~/notes.md"},
"mine.disk": {"icon":"󰋊","label":"Disk usage","action":"omarchy-launch-floating-terminal-with-presentation 'df -h'"},
```

### Fields

| Field | Meaning |
|---|---|
| `icon` | Glyph in front of the label (Nerd Font). |
| `label` | Text of the row. |
| `action` | Bash command to run when chosen. |
| `when` | Bash test. The row is hidden when it fails. |
| `checked` | Bash test. The row gets a ✓ when it succeeds. |
| `disabled` | Bash test. The row is dimmed when it succeeds. |
| `description` | Extra words that search also matches. |

Example with a check mark:

```jsonc
"mine.vpn": {"icon":"󰖂","label":"VPN","checked":"warp-cli status | rg -q Connected","action":"warp-cli connect"},
```

### Hide a row

Give it a `when` that always fails:

```jsonc
"trigger.capture.color": {"icon":"󰃉","label":"Color","action":"pkill hyprpicker || hyprpicker -a","when":"false"},
```

To hide a whole submenu, hide each row inside it as well. Hiding only the parent leaves its rows findable through search.

### Change a row that already ships

Copy its whole line from the shipped file into your file, then edit it:

```
~/.local/share/omarchy-quattro/default/omarchy/omarchy-menu.jsonc
```

Restate every field, not only the one you change. A row in your file replaces the shipped row completely, so a field you leave out is gone.

### Run it

- **From the menu:** Super+Space, then type part of the label. Search covers the whole tree.
- **Open straight at a submenu:** `oq omarchy-menu toggle mine`
- **From a key:** add a bind in `~/.config/niri/binds/extras.kdl`:

  ```kdl
  Mod+Ctrl+M hotkey-overlay-title="Mine menu" { spawn "oq" "omarchy-menu" "toggle" "mine"; }
  ```

  To run one action directly from a key, bind its command instead of going through the menu.

Saving the file applies it. No reload command is needed.

### Two rules that will bite you

1. **Comments must be on their own line.** A `// note` after a row on the same line breaks the whole file.
2. **A broken file drops all your rows without an error.** The sign is that the Learn menu comes back, because the line that hides it lives in this file. Fix the syntax and save again.

---

## Keys inside the menu and pickers

| Mode | Keys |
|---|---|
| Typing (default) | Letters filter. Arrows move. Enter selects. Esc goes to normal mode. |
| Normal | `h j k l` move, `gg`/`G` first and last, `Ctrl+d`/`Ctrl+u` page, `x` or `dd` delete, `cc` or `S` clear the filter and type, `i` goes back to typing, Enter selects, Esc or `q` closes. |

## Pickers

| Key | Opens |
|---|---|
| Mod+Ctrl+E | Emoji picker (every emoji; type to search by name) |
| Mod+Ctrl+G | Icon picker (every Nerd Font glyph, the icons used on the bar and in the menu) |
| Mod+Ctrl+Alt+B | Wallpaper picker |

Choosing an emoji or icon types it into the focused window. The icon picker is how you find a glyph for an `"icon"` or `"text"` field: search, press Enter, and it lands in your editor.

## If something breaks

- **Bar looks wrong after an edit:** `jq . ~/.config/omarchy/shell.json` shows the first JSON error. This file allows no comments and no trailing commas.
- **Menu rows vanished:** see the two rules above.
- **Restart the shell:** `oq omarchy-restart-shell`
- **See its log:** `journalctl --user -b -t omarchy-shell -n 50`
