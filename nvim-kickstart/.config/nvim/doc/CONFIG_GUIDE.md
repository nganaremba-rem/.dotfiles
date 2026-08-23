# Building this Neovim config from scratch

This is the "how would I rebuild this from an empty machine" document: every stage,
in the order it has to happen, with the reasoning behind each decision and the
traps that decision avoids.

It is written to be **read top-to-bottom once** and then used as a reference. Each
stage says **what** you add, **how** it hooks into Neovim, and **why** it is done
that way rather than the obvious alternative.

---

## 0. What you end up with

```
~/.config/nvim/                    ← symlink target (GNU stow from ~/.dotfiles)
├── init.lua                       ← 12 lines: requires four modules, nothing else
├── lua/
│   ├── custom/
│   │   ├── config/                ← editor-level: options, keymaps, autocmds, lazy bootstrap
│   │   ├── languages.lua          ← THE language registry (single source of truth)
│   │   ├── lang/init.lua          ← derives plugin config from the registry
│   │   ├── health.lua             ← :checkhealth custom (invariant tests)
│   │   └── plugins/               ← one file per plugin, auto-imported
│   │       └── ai/                ← AI plugins (lazy `import` is not recursive)
│   └── kickstart/                 ← the few upstream kickstart files still in use
└── doc/CONFIG_GUIDE.md            ← this file
```

Design rule that everything else follows: **each concern has exactly one owner.**
When two plugins can own the same thing (notifications, ghost text, `vim.notify`,
a keymap, a filetype's formatter), the config picks the winner *explicitly*
instead of letting plugin load order decide. Load order is not stable and not
visible, so a conflict resolved by load order is a bug that appears months later.

---

## 1. Prerequisites (system, not Neovim)

| Tool | Why | Arch package |
|---|---|---|
| `neovim` ≥ 0.11 | native `vim.lsp.config`/`vim.lsp.enable`, `vim.hl`, `vim.fs.root` | `neovim` |
| `git` | lazy.nvim clones every plugin | `git` |
| `ripgrep` | picker file/grep engine, and `:grep` | `ripgrep` |
| `fd` | faster file walking for the picker | `fd` |
| `node` + a package manager | vtsls, eslint, emmet, markdown-preview | `nodejs`, `pnpm` |
| `make`, `unzip`, `gcc` | building LuaSnip's jsregexp, avante, Mason packages | `base-devel`, `unzip` |
| `lazygit` | `<leader>gg` | `lazygit` |
| A Nerd Font | every icon in the statusline, tree, picker | `ttf-jetbrains-mono-nerd` |

Set the Nerd Font **in the terminal emulator**, not in Neovim — Neovim draws with
whatever glyphs the terminal has. Then tell the config it exists:
`vim.g.have_nerd_font = true` (in `options.lua`) switches every icon set on.

`:checkhealth custom` verifies all of the above; run it after any new machine setup.

---

## 2. Stage 1 — the entry point and why it is nearly empty

`init.lua`:

```lua
vim.loader.enable()          -- byte-compile cache for Lua modules: ~10ms off startup
vim.g.loaded_netrw = 1       -- kill netrw BEFORE it defines its autocmds
vim.g.loaded_netrwPlugin = 1

require 'custom.config.options'
require 'custom.config.keymaps'
require 'custom.config.lazy'
require 'custom.config.autocmds'
```

**Why this order matters:**

1. `options` first because it sets `vim.g.mapleader`. Every mapping created after
   this point resolves `<leader>` at *definition* time — set the leader later and
   half your keymaps silently bind to a different key.
2. `keymaps` before `lazy` so that plugin `keys = {}` specs can deliberately
   *override* a base mapping (that is the documented way to override, e.g. the AI
   provider taking `<C-j>` from the "disabled window-nav key" map).
3. `autocmds` last so its autocmds run after every plugin has registered its own.

**Why netrw is disabled at the top:** netrw defines `BufEnter` handlers when it
loads. Disabling it after plugin load leaves those handlers installed, and then
`nvim some/dir/` opens a netrw listing instead of neo-tree.

---

## 3. Stage 2 — lazy.nvim bootstrap

`lua/custom/config/lazy.lua` clones lazy.nvim if missing, prepends it to
`runtimepath`, then calls `require('lazy').setup { ... }`.

Two things worth understanding:

**`{ import = 'custom.plugins' }` is not recursive.** It imports every `.lua` file
directly inside `lua/custom/plugins/`, and stops. That is why the AI plugins need
their own line: `{ import = 'custom.plugins.ai' }`. Add a new subfolder → add a new
import line, or its plugins silently never load.

**Two specs for the same repo get merged.** `snacks.nvim` appears in both
`plugins/snacks.lua` (the main config, `lazy = false`) and `plugins/terminal.lua`
(`optional = true`, only `keys`). lazy.nvim merges them into one plugin with the
union of the keys. This is how a large plugin gets split into topic files without
being configured twice.

**`performance.rtp.disabled_plugins`** turns off built-in vim plugins for startup
speed. Note what is *not* in the list: `matchit` and `matchparen`. `matchit` is
what makes `%` jump between `<div>` and `</div>`, `if`/`end`, `do`/`done` — plain
`%` only understands brackets. Disabling it for 2ms is a bad trade in a JSX/Lua
config.

---

## 4. Stage 3 — options worth explaining

Most of `options.lua` is self-evident. These are the ones that exist because of a
specific failure:

| Option | Value | The failure it prevents |
|---|---|---|
| `fileencodings` | utf-8 **before** cp932/euc-jp/sjis | The Japanese encodings accept almost any byte sequence, so listed first they mis-detect plain UTF-8 files (`.env`) as euc-jp, write them back `[converted]`, and produce the phantom "file changed since reading it!!!" prompt. |
| `backupcopy` | `yes` | Neovim's default rewrites the file by rename, which changes the inode. File watchers (Vite HMR, `tsc --watch`) follow inodes, so saves stop triggering reloads. |
| `backupdir` | central state dir | Otherwise `.env.local~` backup files appear in the project tree. |
| `signcolumn` | `yes:1` | Reserves the column permanently so text does not shift sideways the instant a diagnostic/git/mark sign appears. |
| `ttimeoutlen` | `0` | Time to wait for a terminal escape sequence. The default makes `<Esc>` feel laggy in insert mode. |
| `timeoutlen` | `300` | Time to wait for a *mapped sequence*. This is the number that makes prefix collisions feel like lag — see §12. |
| `synmaxcol` | `300` | Stops highlighting past column 300; minified/bundled lines otherwise freeze the UI. |
| `clipboard` | set inside `vim.schedule()` | Resolving the clipboard provider spawns a process; deferring it keeps it off the startup path. |

---

## 5. Stage 4 — keymaps and the one invariant that matters

The whole keymap layout obeys a single rule:

> **A prefix is either a group or a standalone map — never both.**

If `<leader>b` is a standalone mapping *and* `<leader>bd` exists, then pressing
`<leader>b` cannot fire immediately: Neovim must wait `timeoutlen` (300ms) to see
whether a `d` is coming. It feels like the editor is lagging, never like a
mis-configuration, which is why it goes undiagnosed for months.

This is why the config moved:

- breakpoints `<leader>b`/`<leader>B` → `<leader>db`/`<leader>dB`
- format `<leader>f` → `<leader>cf`
- aerial `<leader>a` → `<leader>cs` (avante owns the `<leader>a` group)

The namespaces:

```
<leader>b buffer   <leader>c code    <leader>d debug   <leader>f find/replace
<leader>g git      <leader>h hunk    <leader>m harpoon <leader>r run/build
<leader>s search   <leader>t terminal <leader>u UI toggle <leader>x diagnostics
<leader>a AI (avante)
```

`which-key` (`plugins/which-key.lua`) only *labels* these groups — it does not
create them. A group in the which-key spec with no maps under it is a lie; a
prefix with maps and no group entry shows up unlabelled. `:checkhealth custom`
checks the invariant itself against the live keymap table.

Non-leader decisions worth knowing:

- `<C-h/j/k/l>` are window navigation and cross the nvim↔tmux boundary
  (`vim-tmux-navigator`, with `vim.g.tmux_navigator_no_mappings = 1` so this
  config owns the mapping definitions).
- In **insert** mode those same chords are deliberately inert, *except* `<C-j>`
  and `<C-l>`, which the AI completion provider takes over on `InsertEnter`
  (accept suggestion / accept word). That override is intentional and documented
  at both ends.
- `[[` / `]]` = jump between references of the symbol under the cursor
  (`Snacks.words`). Aerial's symbol navigation lives on `[a` / `]a` — it used to
  also claim `[[`/`]]`, and which plugin won depended on load order.

---

## 6. Stage 5 — UI layer, and who owns `vim.notify`

Order of adoption: colorscheme → statusline → bufferline → notifications.

**tokyonight** is configured with `transparent = true` and an `on_highlights`
block instead of a post-hoc "make things transparent" pass. The reason is that
`:colorscheme` wipes all highlight groups; anything applied afterwards has to be
re-applied on every `ColorScheme` event. Letting the theme do it means it is
always correct. (`config/transparent.lua` keeps a corrected version of the manual
approach as an escape hatch for themes without the option — including the
`nvim_get_hl` merge, because `nvim_set_hl(0, g, { bg = 'none' })` *replaces* the
group and silently drops its `fg`.)

**noice + snacks both want `vim.notify`.** Whichever loads last wins, so the
config disables noice's notifier explicitly (`notify = { enabled = false }`) and
lets `Snacks.notifier` own it. noice keeps the cmdline, messages and LSP UI. This
is the archetype of the "explicit owner" rule; `:checkhealth custom` asserts the
winner is who we intended.

**lualine** reads colours from `tokyonight.colors` through a `pcall` with a
fallback to lualine's `auto` theme — a hard `require` on a colorscheme module
turns "I tried a different theme" into a startup error.

---

## 7. Stage 6 — treesitter (the `main` branch API)

`plugins/nvim-treesitter.lua` uses the **`main` branch**, whose API is different
from every tutorial written for the `master` branch: there is no
`require('nvim-treesitter.configs').setup{}` and no `highlight = { enable = true }`.

Instead the config:

1. calls `require('nvim-treesitter').install(parsers)` with the parser list
   (editor-essential parsers + everything the language registry asks for),
2. registers a `FileType` autocmd that, per buffer:
   - maps filetype → language with `vim.treesitter.language.get_lang`,
   - installs the parser on demand if it is available but missing,
   - starts highlighting with `vim.treesitter.start(buf, lang)`,
   - sets `indentexpr` **only if** the language actually ships an `indents.scm`
     query (otherwise Neovim's built-in indent is better than a broken one).

That last check is why JSX/TSX indentation works: `tsx` has `indents.scm`, so
`indentexpr` is set for it.

---

## 8. Stage 7 — LSP, and the language registry idea

This is the core architectural decision in the config.

**The problem.** Adding one language normally means editing five files: the LSP
spec, the conform spec, the nvim-lint spec, the treesitter parser list, and the
Mason install list. They drift, and the drift is silent.

**The solution.** `lua/custom/languages.lua` is a pure data table — the registry.
One entry per language:

```lua
web = {
  filetypes  = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  lsp        = { vtsls = {...}, eslint = {...}, tailwindcss = {...}, emmet_language_server = {...} },
  formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
  treesitter = { 'javascript', 'typescript', 'tsx' },
  tasks      = { run = '$PM run dev', build = '$PM run build', test = '$PM test' },
}
```

`lua/custom/lang/init.lua` then *derives* what each plugin needs:

| Function | Consumer |
|---|---|
| `servers()` | `vim.lsp.config(name, settings)` + `vim.lsp.enable(name)` |
| `formatters_by_ft()` | conform.nvim |
| `linters_by_ft()` | nvim-lint |
| `treesitter_ensure()` | nvim-treesitter install list |
| `format_on_save_fts()` | conform's format-on-save predicate (derived: anything with a formatter) |
| `mason_ensure()` | mason-tool-installer at startup |
| `ensure_for_ft(ft)` | on-demand Mason install the first time you open a filetype |
| `tasks_for_ft(ft, buf)` | overseer `<leader>r…` |

**Adding a language is therefore one registry entry and nothing else.**

Two sharp edges this design has, both now covered by `:checkhealth custom`:

- `servers()` is keyed by **server name**, so declaring the same server in two
  entries means the second silently overwrites the first, *including its
  `filetypes` list*. This is why emmet is declared once, in the `web` entry, with
  every markup filetype listed — including `html`.
- `formatters_by_ft()`/`linters_by_ft()` are keyed by **filetype**, so two entries
  claiming one filetype means one entry's tools are discarded.

**LSP wiring** (`plugins/nvim-lspconfig.lua`) uses the Neovim 0.11 native API:
`vim.lsp.config(name, settings)` merges your settings over nvim-lspconfig's
shipped defaults for that server (`lsp/<name>.lua` in the plugin), then
`vim.lsp.enable(name)` arms it. Keymaps are attached in one `LspAttach` autocmd,
never per-server.

**Task placeholders** (`tasks_for_ft`) expand `$FILE`, `$DIR`, `$ROOT`, `$STEM`,
`$OUT`, `$NAME`, `$TMP`, `$PM`. All are shell-quoted except `$PM` (which resolves
to `bun`/`pnpm`/`yarn`/`npm` from the lockfile). Use `$OUT` rather than
`"$TMP/$STEM"`: two separately-quoted parts concatenate to `'/dir'/name`, which
breaks on any path containing a space.

---

## 9. Stage 8 — completion (blink.cmp), and the `<CR>` rule

`plugins/blink.lua`, `preset = 'super-tab'` — `<Tab>` accepts, `<C-n>`/`<C-p>`
move, `<C-e>` dismisses.

The subtle part is `<CR>`. Two requirements pull in opposite directions:

1. typing `useSta` and pressing Enter should **accept** `useState` and let the LSP
   insert the `import { useState } from 'react'` line;
2. typing `{` in a JSX file and pressing Enter should **insert a newline**, not
   accept whatever the menu happens to be showing.

Requirement 2 fails with the naive `['<CR>'] = { 'select_and_accept', 'fallback' }`
because `{` is an LSP *trigger character*: the menu opens, the first item is
preselected, and Enter accepts it — replacing the brace you just typed. That is
the bug that started this whole review.

The fix is two-part:

```lua
['<CR>'] = { 'accept', 'fallback' },     -- accept only an item that is SELECTED
...
list = { selection = {
  preselect = function(ctx) return ctx.trigger.kind ~= 'trigger_character' end,
  auto_insert = false,
} },
```

`preselect` accepts a predicate and is re-evaluated on every menu update, so:

| you type | trigger kind | preselected? | `<CR>` does |
|---|---|---|---|
| `useSta` | keyword | yes | accept + auto-import |
| `{` (jsx) | trigger_character | no | newline (falls through to nvim-autopairs) |
| `obj.` | trigger_character | no | newline |
| `obj.ma` | keyword | yes | accept |

`cmp.accept()` returns `nil` when nothing is selected, which is what makes blink
run the next command in the list — `fallback` — and blink's fallback resolves the
*live* non-blink mapping for that key at runtime, so nvim-autopairs' `<CR>`
(which expands `{|}` into three lines) still runs. Plugin load order is
irrelevant here; that is worth knowing before "fixing" it by reordering specs.

**Auto-import** works because blink resolves the completion item's
`additionalTextEdits` on accept. Nothing extra to configure.

**Emmet**: `emmet_language_server` is declared in the registry's `web` entry for
all markup filetypes. In a `.tsx` file, typing `div` and accepting gives
`<div></div>`; `div.card` gives `<div className="card">` (it knows JSX); `ul>li*3`
expands the whole tree. It coexists with `nvim-ts-autotag`, which handles the
other direction: typing `<div>` closes the tag, renaming one end renames both.

**Ghost text has exactly one owner.** blink's `ghost_text.enabled = false`,
because the AI provider (supermaven, `plugins/ai/completion.lua`) draws inline
suggestions. Two ghost-text providers render on top of each other.

---

## 10. Stage 9 — formatting and linting

**conform** (`plugins/conform.lua`) gets `formatters_by_ft` from the registry and
computes format-on-save from it: any filetype that declares a formatter is
formatted on save, with `lsp_format = 'fallback'` for everything else. There is no
hand-maintained "format these filetypes" list to drift.

**Trailing-whitespace trimming** lives in `autocmds.lua` and skips `markdown`,
`gitcommit`, `text` and `diff`. In markdown two trailing spaces are a hard line
break — trimming them silently changes rendered output.

**ESLint** runs as an LSP (`vscode-eslint-language-server`), not as a nvim-lint
linter. It only attaches when a config file (`.eslintrc*` / `eslint.config.*`)
exists up-tree, so it stays quiet in non-eslint projects.

> **pnpm trap, worth recognising on sight.** With `FlatCompat` +
> `next/core-web-vitals`, plugin resolution happens from the *project root*, and
> pnpm does not hoist `eslint-plugin-react-hooks` there — it lives beside
> `eslint-config-next` in `node_modules/.pnpm/…`. The LSP then fails every
> `textDocument/diagnostic` with `-32603 … Require stack: …/placeholder.js`.
> This is **not** a Neovim problem: `./node_modules/.bin/eslint .` reproduces it,
> while `next lint` hides it because Next patches resolution. Fix it in the
> project's `eslint.config.mjs`:
> ```js
> resolvePluginsRelativeTo: dirname(require.resolve("eslint-config-next/package.json")) + "/../..",
> ```
> When an LSP misbehaves, run its CLI first. It settles "editor or project?" in
> one command.

---

## 11. Stage 10 — files, pickers, git, terminals, tasks

**Picker**: `Snacks.picker` replaced telescope + fzf-native + ui-select +
dressing. The one non-default setting worth copying is the search profile:

```lua
local FIND = { hidden = true, ignored = true, exclude = { '.git', 'node_modules', ... } }
```

`hidden` and `ignored` are **separate filters and both are required**: `hidden`
passes `--hidden` (dotfiles), `ignored` passes `--no-ignore` (gitignored files).
Setting only `hidden` makes `.env.local` findable while `.env` stays invisible,
which is exactly the kind of half-working state that wastes an afternoon.
neo-tree's `filtered_items` mirrors the same profile so the tree and picker agree.

**neo-tree git refresh** watches `.git/index`, `.git/HEAD` and `.git/refs` with
libuv. Git writes the index by creating `index.lock` and **renaming** it over the
old file, which replaces the inode — so a watcher armed once goes deaf after the
first commit. The watcher therefore re-arms itself inside its own callback, and
stops on `VimLeavePre` so a live handle cannot hold the editor open. The
`BufWritePost` refresh is skipped entirely when no neo-tree window is open.

**Terminals**: `Snacks.terminal`, with identity derived from `cmd + cwd + env`.
Passing a distinct `NVIM_TERM_SLOT` per slot is what makes `<leader>t1..t5` five
independent shells that survive toggling.

**Tasks**: overseer, driven by the registry's `tasks` field. `build`/`test`/`file`
run under the `jobstart` strategy, not a terminal, because a PTY hard-wraps long
lines and a wrapped `path/file.c:12:5: error: …` no longer matches the
errorformat — every quickfix entry lands on line 0. `run`/`serve` stay on a
terminal because they are interactive.

---

## 12. Invariants, and `:checkhealth custom`

`lua/custom/health.lua` encodes the rules above as runnable checks. Run it after
adding a plugin, a keymap, or a registry entry:

1. **Prefix stalls** — any mapping this config owns that is also the prefix of a
   longer one (reads the live keymap table, so it sees the merged result of every
   plugin). Upstream-by-design stalls (`gc`/`gcc`, mini.surround's `sf`/`sfn`
   suffix maps) are listed as info, not warnings.
2. **Duplicate global mappings** — the `[[`-style collision, caught mechanically.
3. **Registry collisions** — a server declared twice, a filetype claimed twice.
4. **Tool translation** — a formatter/linter with no Mason package mapping would
   never be installed, and conform would silently format nothing.
5. **External binaries** — required (`git`, `rg`, `node`) vs optional.
6. **Single-owner globals** — who actually owns `vim.notify`; whether ghost text
   has one owner (needs blink loaded, i.e. enter insert mode once first).

---

## 13. Rebuild order (the checklist)

1. Install the prerequisites from §1; set the Nerd Font in the terminal.
2. `git clone` the dotfiles; `stow nvim-kickstart` so `~/.config/nvim` points at
   the repo.
3. Launch `nvim`. lazy.nvim bootstraps itself and installs everything; Mason
   installs the tools from `mason_ensure()`. Expect one noisy first start.
4. `:Lazy` — everything green.
5. `:checkhealth custom` — fix warnings top-down; then `:checkhealth` for the rest.
6. Open a `.tsx` file: `:LspInfo`-equivalent (`:lua =vim.lsp.get_clients()`) should
   show `vtsls`, `eslint`, `tailwindcss`, `emmet_language_server`.
7. Enter insert mode once, then re-run `:checkhealth custom` so the blink check
   has something to inspect.

To add a language later: add an entry to `lua/custom/languages.lua`. Nothing else.

---

## 14. Troubleshooting cookbook

Every entry here is a real bug this config hit, with the shape of the diagnosis.

| Symptom | Cause | Fix |
|---|---|---|
| Typing `{` in JSX + Enter deletes the brace | `<CR>` was `select_and_accept` and `{` is an LSP trigger character, so a preselected item got accepted | §9: `accept` + predicate `preselect` |
| A leader key "lags" ~300ms | it is both a standalone map and a group prefix | move it under its group; `:checkhealth custom` finds these |
| A keymap does something different depending on the day | two lazy `keys` specs on one lhs — load order decides | one owner; `:checkhealth custom` finds these |
| `eslint: -32603 Request textDocument/diagnostic failed … placeholder.js` | project-side plugin resolution (pnpm + FlatCompat) | §10 — verify with the eslint CLI first |
| Markdown line breaks vanish on save | trailing-whitespace trim | filetype exemption list in `autocmds.lua` |
| `.env` invisible in the picker | `hidden` set but not `ignored` | §11 — both filters |
| Git status in neo-tree stops updating after the first commit | fs_event watcher lost its inode to git's rename | self-re-arming watcher |
| "file changed since reading it!!!" on a UTF-8 file | `fileencodings` order | utf-8 before the Japanese encodings |
| Save no longer triggers Vite HMR | inode changed on write | `backupcopy = 'yes'` |
| Statusline lost its colours after a transparency tweak | `nvim_set_hl` replaces the whole group | read-merge-write (`config/transparent.lua`) |
| Formatter appears to do nothing | tool name has no Mason package mapping, so it was never installed | add it to `FORMATTER_TO_MASON`; `:checkhealth custom` finds these |
| Quickfix entries all point at line 0 | task ran in a PTY and wrapped the compiler output | `jobstart` strategy for parsed task kinds |

---

## 15. AI plugins

`plugins/ai/completion.lua` selects an inline-suggestion provider with a single
`PROVIDER` constant (`supermaven` default, `copilot`, `codeium`). Each provider is
a self-contained lazy spec, so only the selected one is ever installed. Accept is
`<C-j>` for all three — deliberately not `<Tab>`, which belongs to blink's
super-tab.

`plugins/ai/avante.lua` is the sidebar chat. `MODEL` is a single constant at the
top, currently `claude-opus-5`. Note that Opus 5 / 4.8 / 4.7 and Sonnet 5 **reject
sampling parameters** (`temperature`, `top_p`, `top_k`) with HTTP 400 — they were
removed along with adaptive thinking — which is why no temperature is sent. Needs
`ANTHROPIC_API_KEY` exported in the shell.
