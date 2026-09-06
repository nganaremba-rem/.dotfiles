# Your Neovim, explained from 0 to 100%

This is the "what do I actually have and how do I use it" guide, in plain English.

The other file, `doc/CONFIG_GUIDE.md`, explains *how the config was built* — it is for
when you want to change things. **This** file is for when you want to *use* things.

Read it once top to bottom. After that, jump to the cheat sheet at the end.

---

## Table of contents

1. [The two ideas you need first](#1-the-two-ideas-you-need-first)
2. [How your Neovim starts up](#2-how-your-neovim-starts-up)
3. [The map of your keyboard](#3-the-map-of-your-keyboard)
4. [Moving around files](#4-moving-around-files)
5. [Writing code: LSP, completion, formatting](#5-writing-code-lsp-completion-formatting)
6. [Seeing problems in your code](#6-seeing-problems-in-your-code)
7. [Git](#7-git)
8. [Running and building your project](#8-running-and-building-your-project)
9. [Terminals inside Neovim](#9-terminals-inside-neovim)
10. [Debugging](#10-debugging)
11. [The AI part — Supermaven, Avante, and Claude Code](#11-the-ai-part)
12. [Everything else that is quietly helping you](#12-everything-else-that-is-quietly-helping-you)
13. [Adding a new language](#13-adding-a-new-language)
14. [When something breaks](#14-when-something-breaks)
15. [The full cheat sheet](#15-the-full-cheat-sheet)

---

## 1. The two ideas you need first

### Idea 1: The leader key is Spacebar

Almost every shortcut in this config starts with pressing **Space**.

Space is called the "leader" key. It is a doorway. You press Space, then more letters,
and something happens.

```
Space  s  f     →  Search Files
Space  g  g     →  open Lazygit
Space  r  r     →  Run the project
```

You do not need to memorise these. **Press Space and wait half a second.** A menu pops
up at the bottom showing every key you can press next, with a description. That menu is
a plugin called **which-key**. It is your built-in cheat sheet — you can genuinely learn
this whole config just by pressing Space and reading.

Try it right now. Press Space, wait, read the list. Press `s`, wait, read the list again.
Press `Esc` to back out.

### Idea 2: Everything is a plugin, and they load lazily

Your config has ~50 plugins. They are managed by **lazy.nvim**.

"Lazily" means: a plugin is not loaded when Neovim starts. It is loaded the first moment
you actually need it. The Git-diff plugin does not load until you press a Git key. The
Markdown preview plugin does not load until you open a `.md` file.

That is why your Neovim opens in a fraction of a second even with 50 plugins.

Type `:Lazy` to see the plugin dashboard — what is installed, what is loaded, and how
many milliseconds each one costs. `:Lazy update` updates them all. Press `q` to close.

---

## 2. How your Neovim starts up

Your config lives in `~/.config/nvim`, which is a symlink into your dotfiles repo at
`~/.dotfiles/nvim-kickstart/.config/nvim`. Editing either path edits the same files.

The startup chain is small and deliberate:

```
init.lua                          ← 12 lines. It just calls four things:
  ├── custom.config.options       ← editor settings (line numbers, tabs, clipboard…)
  ├── custom.config.keymaps       ← your personal key shortcuts
  ├── custom.config.lazy          ← starts the plugin manager, which loads:
  │     └── lua/custom/plugins/*.lua   ← one file per plugin
  │         └── lua/custom/plugins/ai/*.lua
  └── custom.config.autocmds      ← "when X happens, do Y" rules
```

Two special files sit outside that list and are worth knowing:

- **`lua/custom/languages.lua`** — the single list of every programming language you
  support and what tools it uses. This is the most important file in your config.
  See [section 13](#13-adding-a-new-language).
- **`lua/custom/health.lua`** — run `:checkhealth custom` and it tells you what is broken
  or missing on this machine.

### Things that happen automatically, without you asking

These are the "autocmds". You never press a key for these:

| When | What happens |
|---|---|
| You copy (yank) text | It flashes briefly so you can see what you grabbed |
| You reopen a file | Cursor jumps back to where you left it |
| You save a file | Trailing spaces at line ends are deleted (except in Markdown, where two trailing spaces mean a line break) |
| You save a file | The file is auto-formatted (see [section 5](#5-writing-code-lsp-completion-formatting)) |
| A file changes on disk | Neovim reloads it instead of showing stale content |
| You open a `.md` or `.txt` file | Word wrap and spellcheck turn on |
| You resize your terminal | Split windows resize to match |
| You open help / quickfix / man pages | `Esc` closes them |
| A program inside Neovim needs an editor | It opens a tab in *this* Neovim instead of launching a second nested Neovim |

That last one is genuinely nice: run `git commit` in a terminal inside Neovim and the
commit message opens as a tab here, not as a confusing Neovim-inside-Neovim.

---

## 3. The map of your keyboard

Shortcuts are grouped by their second letter. Learn the groups, not the individual keys.

| Press Space then… | Group | What lives there |
|---|---|---|
| `b` | **B**uffer | close buffers |
| `c` | **C**ode | format, rename, code actions, symbol outline |
| `d` | **D**ebug | breakpoints, step, continue |
| `e` | *(no group)* | file explorer toggle |
| `f` | **F**ind/replace | project-wide search & replace, Flutter |
| `g` | **G**it | status, diff, blame, push, lazygit |
| `h` | Git **H**unk | stage/reset/preview individual changes |
| `m` | Har**m**poon | bookmark files for instant jumping |
| `r` | **R**un/build | run, build, test, dev server |
| `s` | **S**earch | find files, grep, help, keymaps, everything |
| `t` | **T**erminal | open/switch/kill terminals |
| `u` | **U**I toggle | wrap, blame, zen mode, AI on/off, undo tree |
| `x` | Diagnostics | error lists |
| `a` | **A**I | Avante AI assistant |

And a few important keys that do **not** start with Space:

| Key | What it does |
|---|---|
| `Ctrl-s` | Save (works in insert mode too) |
| `Ctrl-h/j/k/l` | Move between windows — **and between tmux panes**, seamlessly |
| `Shift-h` / `Shift-l` | Previous / next open file (buffer) |
| `Ctrl-\` | Toggle terminal |
| `K` | Show documentation for the thing under the cursor |
| `gd` | Go to definition |
| `Esc` | Clear search highlighting |

---

## 4. Moving around files

You have four different ways to move around, for four different situations.

### 4a. The picker — `Space s` (plugin: snacks.nvim)

This is your main tool. It is a fuzzy finder: a window opens, you type a few letters,
it filters instantly, you press Enter.

```
Space Space   →  find a file by name         ← the one you will use most
Space s f     →  same thing
Space s g     →  search the TEXT inside all files (grep)
Space s w     →  grep for the word under your cursor
Space s b     →  switch between already-open files
Space s .     →  recently opened files
Space /       →  search inside the current file only
Space s h     →  search Neovim's help docs
Space s k     →  search every keybinding you have    ← great for learning
Space s r     →  reopen the last search you did
Space s u     →  browse your undo history
Space s n     →  browse your Neovim config files
```

**Example.** You know there is a function called `parseConfig` somewhere but you have no
idea which file:

```
Space s g   →  type: parseConfig   →  see every match with a preview  →  Enter
```

Important detail: this picker finds **hidden and gitignored files too**, so `.env` shows
up. Most configs get this wrong.

### 4b. The file tree — `Space e` (plugin: neo-tree)

A classic sidebar tree, like VS Code.

```
Space e   →  open/close the tree
Space E   →  open the tree AND highlight the file you are currently in
```

Inside the tree: `a` add file, `d` delete, `r` rename, `Enter` open, `\` close.

It shows dotfiles and gitignored files (deliberately), and it refreshes itself when git
state changes or you save a file.

### 4c. Harpoon — `Space m` (plugin: harpoon)

The picker is for files you *do not know*. Harpoon is for the 4 files you are working on
*right now*.

You mark a file once, then jump to it with a single keypress forever after.

```
Space m a   →  mark this file
Space m m   →  see the list of marked files (edit or reorder it here)
Space 1     →  jump to marked file 1
Space 2     →  jump to marked file 2
Space 3     →  file 3
Space 4     →  file 4
```

**Example.** You are building a login feature that touches `LoginForm.tsx`,
`auth.ts`, `api.ts`, and `types.ts`. Open each one, press `Space m a`. Now
`Space 1` through `Space 4` cycle between them with zero thinking. This is the single
biggest speed upgrade in your whole config, and most people never use it.

### 4d. Jumping within one file

```
Space c s   →  outline of all functions/classes in this file (aerial)
[a  /  ]a   →  jump to previous / next function
[[  /  ]]   →  jump to previous / next use of the word under your cursor
Shift-h/l   →  previous / next open file
```

---

## 5. Writing code: LSP, completion, formatting

### What an LSP is (in one paragraph)

An **LSP** (Language Server Protocol server) is a separate program that actually
understands your programming language. When you open a TypeScript file, Neovim starts
`vtsls` in the background. That program reads your whole project and can answer questions
like "where is this function defined?", "what type is this?", "what are you allowed to
type here?", "this line is wrong". Neovim just displays the answers. Every "smart" editor
feature you have comes from an LSP.

Your LSPs are installed automatically by **Mason** (`:Mason` to see them). You do not
install them by hand.

### The LSP keys

| Key | What it does |
|---|---|
| `K` | Show docs for the thing under the cursor |
| `gd` or `grd` | Go to where it is defined |
| `grr` | Show everywhere it is used |
| `gri` | Go to implementation |
| `grt` | Go to its type definition |
| `grD` | Go to declaration |
| `gO` | List all symbols in this file |
| `gW` | Search all symbols in the whole project |
| `Space c r` | Rename it everywhere (with live preview as you type) |
| `Space c a` | Code actions — "fix this for me" suggestions |
| `Space c o` | Auto-fix imports (ESLint) |
| `Space c R` | Rename the *file* and update every import pointing at it |
| `Space u h` | Toggle inlay hints (the small grey type annotations) |

**Example of `Space c a`.** Your cursor is on a red-underlined variable that TypeScript
says does not exist. Press `Space c a`, and a menu offers "Import `useState` from 'react'".
Press Enter. Done.

**Example of `Space c r`.** Cursor on `getUser`. Press `Space c r`, type `fetchUser`, and
as you type you *see* the change previewed in every file at once. Enter to confirm.

### Autocomplete — blink.cmp

As you type, a menu of suggestions appears.

| Key | What it does |
|---|---|
| `Tab` | Accept the highlighted suggestion |
| `Ctrl-n` / `Ctrl-p` | Move down / up the list |
| `Ctrl-Space` | Force the menu open, or show docs |
| `Ctrl-e` | Close the menu |
| `Enter` | Accept — but only if you deliberately selected something |

That last rule is intentional and subtle: if the menu popped up on its own because you
typed a `{` or a `.`, pressing Enter gives you a **newline**, not a random completion.
It only accepts when you actually chose an item. This prevents the classic
"I pressed Enter and it ate my brace" bug.

You also get **snippets** (from friendly-snippets). Type `fn` in Lua or `useState` in
React and accept the suggestion — it expands into a full template with `Tab` jumping
between the blanks.

### Formatting — conform.nvim

**Your files auto-format every time you save.** That is already on. You do not need to
do anything.

```
Space c f   →  format now, without saving
              (in visual mode: format just the selected lines)
```

Which formatter runs is decided per-language in `lua/custom/languages.lua`. Python uses
ruff/isort/black, Lua uses stylua, Rust uses rustfmt, web files use biome or prettier.

One clever bit worth knowing: **biome only runs if your project has a `biome.json`.**
Otherwise it falls through to prettier. Without that rule, biome would silently reformat
every prettier project with the wrong style.

---

## 6. Seeing problems in your code

Errors and warnings are called **diagnostics**. They show as red/yellow text at the end
of the offending line, and as icons in the left gutter.

```
Space x x   →  list of ALL problems in the project (Trouble panel)
Space x d   →  problems in this file only
Space x t   →  all your TODO / FIXME / HACK comments
Space c d   →  read the full error for the current line in a popup
Space s d   →  fuzzy-search through all diagnostics
]d  /  [d   →  jump to next / previous problem
]q  /  ]q   →  next / previous item in the quickfix list
]t  /  [t   →  next / previous TODO comment
```

**Example.** After a big refactor, press `Space x x`. A panel opens listing every error
grouped by file. Press Enter on one to jump straight there. Fix it. The list updates live.

Alongside the LSP, a **linter** also runs on save (nvim-lint) — for example
`markdownlint` on Markdown files. Linters catch style and quality issues that the LSP
does not.

---

## 7. Git

You have **four** Git tools, and they genuinely do different jobs. This is not redundancy.

### 7a. Lazygit — `Space g g` — the daily driver

A full terminal Git UI opens over your editor. Stage, commit, branch, rebase, push,
resolve conflicts, browse history. If you only learn one Git thing here, learn this one.

```
Space g g   →  lazygit
Space g L   →  lazygit, opened on the log view
```

Inside lazygit: `Space` stages a file, `c` commits, `P` pushes, `?` shows help, `q` quits.

### 7b. Gitsigns — `Space h` — line-level changes

The coloured marks in the left gutter come from gitsigns. A "hunk" is one contiguous
block of changed lines.

```
]c  /  [c   →  jump to next / previous change in this file
Space h p   →  preview the change under the cursor
Space h s   →  stage just this hunk         (works on a visual selection too)
Space h r   →  reset (undo) just this hunk
Space h S   →  stage the whole file
Space h R   →  reset the whole file
Space h b   →  who wrote this line, and why (full blame popup)
Space h d   →  diff this file against the staged version
Space u b   →  toggle always-on blame text at the end of every line
```

**Example.** You changed 5 things in a file but only 2 belong in this commit. Put your
cursor in the first good change, `Space h s`. Jump to the next with `]c`, `Space h s`
again. Now commit — only those two hunks are included.

### 7c. Diffview — `Space g d` — proper side-by-side diffs

```
Space g d   →  side-by-side diff of all your current changes
Space g f   →  full history of THIS file, commit by commit
Space g F   →  full history of the whole repo
Space g c   →  close diffview   (Esc also works)
```

**Example.** "When did this function break?" Open the file, `Space g f`, and walk the
commit list — each commit shows its diff on the right. You will find it in seconds.

### 7d. Fugitive — `Space g s` — the power tool

```
Space g s   →  Git status, interactive
Space g b   →  Git blame in a side column
Space g l   →  Git log as a graph
Space g w   →  stage this file
Space g r   →  discard changes in this file (restore from git)
Space g v   →  vertical split diff
Space g C   →  commit
Space g p   →  push
Space g P   →  pull
Space g B   →  open this file/line on GitHub in your browser
```

---

## 8. Running and building your project

Plugin: **overseer.nvim**. The point: `Space r r` runs your project *whatever language it
is*, without you remembering the command.

```
Space r r   →  run the project      (npm run dev / cargo run / go run . / …)
Space r f   →  run just THIS file
Space r b   →  build
Space r t   →  run tests
Space r l   →  start the live/dev server
Space r c   →  pick from every task it detected (npm scripts, Makefile, cargo, VS Code tasks.json)
Space r o   →  show the task list / output panel
Space r w   →  re-run the last task automatically every time you save
Space r q   →  quick action on the last task (restart, stop…)
Space r m   →  live Markdown preview in your browser (in .md files)
```

The commands come from `lua/custom/languages.lua`. Examples of what is already set up:

| Language | `Space r r` runs | `Space r t` runs |
|---|---|---|
| JS/TS | `$PM run dev` (npm/pnpm/bun, auto-detected from your lockfile) | `$PM test` |
| Python | `python3 <file>` | `pytest` |
| Rust | `cargo run` | `cargo test` |
| Go | `go run .` | `go test ./...` |
| C | `make run` | `make test` |
| Dart/Flutter | `flutter run` | `flutter test` |
| Bash | `bash <file>` | — |

Two nice touches: it **saves your file first** (so you never run stale code), and for
builds and tests it captures compiler errors into the quickfix list, so `]q` walks you
through them.

**`Space r w` is underused.** Run your tests once, then `Space r w`. Now every save
re-runs the test suite automatically.

### Flutter specifically

```
Space f i r   →  Flutter Run
Space f i s   →  Hot restart
Space f i e   →  pick an emulator
Space f i l   →  toggle the log
Space f i q   →  quit
```

---

## 9. Terminals inside Neovim

Built on snacks.terminal. You get **5 persistent, independent terminals** that keep
their state between toggles.

```
Ctrl-\      →  toggle the last terminal you used   ← the main one
Ctrl-`      →  same (VS Code muscle memory)
Space t t   →  floating terminal
Space t h   →  horizontal split at the bottom
Space t v   →  vertical split at the right
Space t 1..5 →  jump to persistent terminal 1-5
Alt-1..5    →  same, but works from INSIDE a terminal
Space t f   →  terminal opened in the current file's directory
Space t n   →  brand new throwaway terminal
Space t k   →  kill the focused terminal   (Alt-k from inside one)
Space t g   →  lazygit
```

To get out of a terminal back into normal Neovim: press `Esc Esc`.
To move from a terminal into another window: `Ctrl-h/j/k/l` works directly.

**Example.** `Space t 1` for your dev server, `Space t 2` for tests, `Space t 3` for git
commands. `Alt-1`, `Alt-2`, `Alt-3` flip between them instantly, each keeping its own
scrollback and running process.

---

## 10. Debugging

Plugin: **nvim-dap** with a UI. Real breakpoint debugging, like an IDE. Currently set up
for Go out of the box; other languages need their debug adapter installed via Mason.

```
Space d b   →  toggle a breakpoint on this line
Space d B   →  conditional breakpoint (asks for a condition)
F5   / Space d c  →  start debugging, or continue to the next breakpoint
F10  / Space d o  →  step over (run this line, don't go inside)
F11  / Space d i  →  step into (go inside the function call)
Shift-F11 / Space d O  →  step out
F7   / Space d u  →  show/hide the debugger UI
Space d r   →  toggle the REPL (type expressions while paused)
Space d l   →  re-run the last debug session
Space d t   →  stop debugging
```

**Example.** Put your cursor on a suspicious line, `Space d b` (a red dot appears), then
`F5`. The program runs and freezes at that line. Panels open showing every variable's
current value. `F10` walks forward one line at a time.

---

## 11. The AI part

You have **two separate AI tools** doing two completely different jobs. This is the part
you asked about most, so it is the most detailed section.

### 11a. Supermaven — the invisible autocomplete

**What it is:** an AI that predicts the next chunk of code as you type and shows it as
faint grey "ghost text" ahead of your cursor. Exactly like GitHub Copilot or Cursor's
inline suggestions. You have it on the **free tier**. It is extremely fast — suggestions
appear as fast as you type.

**Where it is configured:** `lua/custom/plugins/ai/completion.lua`

**How to use it:** you don't. It just runs. When you see grey text you like:

| Key | What it does |
|---|---|
| `Ctrl-j` | Accept the whole suggestion |
| `Ctrl-l` | Accept just the next word |
| `Ctrl-]` | Dismiss it |
| `Space u a` | Turn ghost text off/on entirely |

**What it looks like:**

```javascript
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
         this grey part is Supermaven guessing. Ctrl-j takes it.
```

**Why `Ctrl-j` and not `Tab`?** Because `Tab` already accepts the *normal* LSP completion
menu. If both used Tab, you would never know which one you were getting. So:
**Tab = the real completion menu, Ctrl-j = the AI guess.**

**Swapping the provider.** Your config was built so this is a one-line change. Open
`lua/custom/plugins/ai/completion.lua`, change line 19:

```lua
local PROVIDER = 'supermaven'   -- change to 'copilot' or 'codeium'
```

Restart Neovim. Copilot needs a paid subscription and a one-time `:Copilot auth`.
Codeium is free and needs `:Codeium Auth`. The keys stay identical either way.

### 11b. Avante — the chat assistant that edits your code

**What it is:** a clone of Cursor's AI sidebar, inside Neovim. You open a chat panel,
describe what you want, and it replies — and when it proposes code changes, they appear
as a **diff you accept or reject**, not as text you copy-paste.

**Where it is configured:** `lua/custom/plugins/ai/avante.lua`

**What model it uses:** Claude Opus 5, via the Anthropic API directly.

**How it is paid for:** by your `ANTHROPIC_API_KEY` environment variable, which is
already set in your `~/.zshrc`. This is **pay-per-token API billing** — every question
costs money based on how much text goes in and out. Opus 5 is the flagship model:
$5 per million input tokens, $25 per million output tokens.

If you want it cheaper and faster, open `avante.lua` and change line 20:

```lua
local MODEL = 'claude-opus-5'    -- change to 'claude-sonnet-5'
```

**The keys (all start with `Space a`):**

| Key | What it does |
|---|---|
| `Space a a` | **Ask** — open the chat and type a question |
| `Space a t` | Toggle the sidebar open/closed |
| `Space a e` | **Edit** — select code in visual mode first, then describe the change |
| `Space a n` | Start a brand-new conversation |
| `Space a f` | Focus the sidebar |
| `Space a r` | Refresh / regenerate the answer |
| `Space a c` | Add the current file to the AI's context |
| `Space a B` | Add all open files to context |
| `Space a h` | Browse your chat history |
| `Space a ?` | Switch model |
| `Space a S` | Stop generation |

**Inside the sidebar:**

| Key | What it does |
|---|---|
| `Enter` | Send your message (in normal mode) |
| `Ctrl-s` | Send (from insert mode) |
| `A` | Apply **all** the suggested changes |
| `a` | Apply just the change at your cursor |
| `Tab` | Switch between the input box and the response |
| `@` | Add a file to the conversation |
| `d` | Remove a file from the conversation |
| `r` | Retry your last request |
| `e` | Edit your last request |
| `q` | Close |

**Full worked example.**

You have a React component and you want it converted to TypeScript.

1. Open the file.
2. Press `Space a c` — the file is now in the AI's context.
3. Press `Space a a` — the chat panel opens on the right.
4. Type: `Convert this component to TypeScript. Add proper prop types.` Press Enter.
5. Claude replies. Its code changes appear as green/red diff blocks in your actual file.
6. Read them. Press `A` to accept everything, or move to each one and press `a` to accept
   selectively. Reject by just not applying.

**Second example — editing a selection.**

1. Visually select a messy function (press `V`, then `j` a few times).
2. Press `Space a e`.
3. Type: `split this into two smaller functions and add error handling`
4. It rewrites just that selection as a diff.

**Important:** Avante's inline auto-suggestions are deliberately turned **off**
(`auto_suggestions = false`) because Supermaven already owns ghost text. Two AIs writing
grey text over each other is a mess. One job, one owner.

### 11c. Can you use Claude Code instead? Yes — three ways.

You already have the `claude` CLI installed at `~/.local/bin/claude`.

---

**Option 1 — Just run it in a terminal. Zero setup. Works today.**

```
Space t v        →  vertical terminal on the right
claude           →  type this
```

That is genuinely it. You now have Claude Code in a side panel next to your code.

And it works *better* here than in most setups, because of the `$EDITOR` autocmd in your
config: when Claude Code (or git, or anything else) needs to open a file for editing, it
opens as a **tab in this same Neovim** — not a nested editor inside a terminal inside
your editor.

To keep it around permanently, use a numbered slot:

```
Space t 5        →  terminal 5
claude           →  start it once
Alt-5            →  come back to it any time, conversation still alive
```

**Honest comparison:** Claude Code in a terminal is *more capable* than Avante. It reads
and writes files itself, runs commands, runs your tests, uses git. Avante can only
suggest diffs for files you hand it. What Claude Code lacks in the terminal is knowing
your cursor position and your visual selection.

---

**Option 2 — `coder/claudecode.nvim`, the proper integration.**

This plugin speaks the same protocol as the official VS Code and JetBrains extensions.
It gives Claude Code real editor awareness: your selection, your open files, and diffs
that render natively in Neovim.

It needs `snacks.nvim` — which you already have.

Create `lua/custom/plugins/ai/claudecode.lua`:

```lua
-- Claude Code, integrated. Uses the same WebSocket protocol as the official
-- VS Code / JetBrains extensions.
--
-- NOTE: default keymaps are <leader>a… which collides head-on with avante.
-- These are remapped to <leader>k… ("klaude") so both can coexist.
return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {},
  keys = {
    { '<leader>k', nil, desc = 'Claude Code' },
    { '<leader>kc', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude Code' },
    { '<leader>kf', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude Code' },
    { '<leader>kr', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume session' },
    { '<leader>kC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue conversation' },
    { '<leader>km', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select model' },
    { '<leader>kb', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>ks', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send selection' },
    { '<leader>ka', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>kd', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Reject diff' },
  },
}
```

Then add the group label to `lua/custom/plugins/which-key.lua`, inside `spec`:

```lua
{ '<leader>k', group = 'Claude Code' },
```

Restart Neovim, and lazy.nvim installs it on first use.

**How you would use it:** select a function visually, press `Space k s` to send it,
describe the change in the Claude panel, and its edits arrive as diffs you accept with
`Space k a`.

---

**Option 3 — Replace Avante entirely.**

If you find you prefer Claude Code, delete `lua/custom/plugins/ai/avante.lua`, run
`:Lazy clean`, and then you are free to use `<leader>a…` for Claude Code's own defaults
instead of the `<leader>k…` remap above.

Reasons you might: one AI subscription instead of a second API bill; Claude Code can run
your tests and use git; `avante` needs `make` to build on every update.

Reasons you might not: Avante's sidebar is tuned for Neovim and its diff-apply flow
(`A` / `a`) is very fast for small edits.

---

**My recommendation:** start with **Option 1** today — it costs nothing to try, and one
terminal split gets you 90% of the value. If you find yourself constantly copy-pasting
selections into it, add **Option 2**. Keep Avante until you are sure, then decide.

### 11d. Quick comparison table

| | Supermaven | Avante | Claude Code (terminal) | claudecode.nvim |
|---|---|---|---|---|
| What | Ghost-text autocomplete | Chat sidebar with diffs | Full agent in a terminal | Full agent, editor-aware |
| Speed | Instant | Seconds | Seconds | Seconds |
| Cost | Free tier | Anthropic API per-token | Your Claude plan | Your Claude plan |
| Can it edit files? | Inserts as you type | Suggests diffs | Yes, itself | Yes, as native diffs |
| Can it run commands? | No | No | Yes | Yes |
| Knows your selection | N/A | Yes | No | Yes |
| Setup needed | None | Already done | None | Add one file |

---

## 12. Everything else that is quietly helping you

These do not have big keybindings. They just make things better.

**mini.ai — smarter text objects.** In Vim, `ci(` means "change inside parentheses". This
extends that to be smarter and to search forward.

```
va)    →  visually select around the parentheses
ci'    →  change what is inside the quotes
yaa    →  yank around the NEXT set of brackets, even if it is below you
```

**mini.surround — wrap things.**

```
saiw)  →  Surround Add, Inner Word, with )     →   word  becomes  (word)
sd'    →  Surround Delete '                    →  'word' becomes   word
sr)'   →  Surround Replace ) with '            →  (word) becomes  'word'
```

**mini.splitjoin — `gS`.** Toggles a one-liner into multiple lines and back.

```
before:  const { a, b, c } = props
press gS
after:   const {
           a,
           b,
           c
         } = props
press gS again → back to one line
```

**nvim-autopairs.** Type `(` and get `()`. Type `"` and get `""`.

**nvim-ts-autotag.** Type `<div>` in JSX and `</div>` appears. Rename the opening tag and
the closing one follows.

**Treesitter.** The engine behind accurate syntax highlighting, indentation, and code
folding. It parses your code into a real syntax tree instead of guessing with regex. It
also powers `zc` (fold), `zM` (fold all), `zR` (unfold all).

**guess-indent.** Opens a file and detects whether it uses tabs or 2 or 4 spaces, then
matches it. No more mixed-indent commits.

**marks.nvim.** Vim marks (`ma` to set mark a, `` `a `` to jump to it) get visible gutter
icons. `Space s m` lists them all.

**undotree — `Space u u`.** Vim's undo is a *tree*, not a line. If you undo, type
something new, then want the old branch back — it is still there. This shows the tree
and lets you jump to any past state.

**grug-far — `Space f r`.** Project-wide find and replace with a live preview of every
match before you commit to it. `Space f w` pre-fills it with the word under your cursor.

**noice.nvim.** Redesigns Neovim's messages and command line. The command line appears as
a floating box in the middle. `Space u n` dismisses notifications, `Space u N` shows the
history.

**Snacks zen mode — `Space u z`.** Hides everything but your code.

**Snacks scratch — `Space .`.** A throwaway scratch buffer for notes or testing snippets.

**Dashboard.** The screen you see when you open `nvim` with no file. Press `f` for files,
`g` for grep, `r` for recent, `G` for lazygit, `l` for `:Lazy`, `q` to quit.

**bufferline.** The tabs across the top. `Shift-h` / `Shift-l` to move between them,
`Space b d` to close one (without wrecking your window layout), `Space b o` to close all
the others.

**lualine.** Your status line. It shows: mode, git branch, +/- line counts, filename,
error counts, macro recording indicator, search match count, active LSP servers, indent
size, file size, encoding, position, and a clock.

**vim-tmux-navigator.** The reason `Ctrl-h/j/k/l` crosses from a Neovim split into a tmux
pane without you noticing the boundary.

**tokyonight.** Your colour scheme — the "night" variant, with transparency on so your
terminal background shows through.

---

## 13. Adding a new language

This is the best-designed part of your config. **You edit exactly one file.**

Open `lua/custom/languages.lua` and add an entry. Everything else — LSP setup, formatting
on save, linting, syntax highlighting, installing the tools via Mason, and the
run/build/test commands — is derived automatically.

Example, adding Ruby:

```lua
ruby = {
  filetypes  = { 'ruby' },
  lsp        = { ruby_lsp = {} },
  formatters = { 'rubocop' },
  treesitter = { 'ruby' },
  tasks = {
    run  = 'ruby $FILE',
    file = 'ruby $FILE',
    test = 'rspec',
  },
},
```

Restart Neovim, open a `.rb` file, and Mason installs `ruby-lsp` and `rubocop` on the
spot. `Space r r` now runs it. Format-on-save now works. Syntax highlighting works.

The placeholders you can use in `tasks`:

| Placeholder | Means |
|---|---|
| `$FILE` | Full path of the current file |
| `$DIR` | Its directory |
| `$STEM` | Filename without the extension |
| `$ROOT` | The project root |
| `$OUT` | A build output path (for `-o` flags) |
| `$PM` | `npm`, `pnpm`, `yarn` or `bun`, detected from the lockfile |
| `$NAME` | An identifier-safe version of the filename |

Languages already configured: **Lua, Python, Rust, Go, C, JavaScript, TypeScript, JSX,
TSX, CSS, HTML, Dart/Flutter, JSON, YAML, TOML, Markdown, Bash, Docker.**

---

## 14. When something breaks

**Step 1, always:**

```
:checkhealth custom
```

This is a custom health check written for *your* config. It verifies your external tools
are installed, that no two plugins are fighting over the same keymap, and that the
language registry is consistent. Read the output — it usually names the exact problem.

```
:checkhealth        →  the full Neovim health report
:Lazy               →  plugin status; anything broken shows here
:Lazy update        →  update all plugins
:Mason              →  LSP servers / formatters / linters; install or update here
:LspInfo            →  which language servers are attached to this file
:ConformInfo        →  which formatter is being used for this file, and why
:messages           →  the last messages Neovim showed
Space u N           →  notification history
```

**Common situations:**

| Symptom | Try |
|---|---|
| No completions / no `gd` | `:LspInfo` — is a server attached? If not, `:Mason` and check it is installed |
| File will not format | `:ConformInfo` — is the formatter installed and available? |
| A key does nothing | `Space s k` and search for it — is it bound to something else? |
| Colours look wrong | Your terminal font must be a Nerd Font; check `:checkhealth custom` |
| AI ghost text is gone | `Space u a` toggles it |
| Avante errors about auth | Is `ANTHROPIC_API_KEY` exported in `~/.zshrc`? |
| Slow startup | `:Lazy profile` shows the millisecond cost of each plugin |

**Rebuild from scratch, worst case:** delete `~/.local/share/nvim` and start Neovim. It
re-downloads everything. Your config is never touched — it lives in your dotfiles repo.

---

## 15. The full cheat sheet

Print this part. Ignore the rest.

### Essentials
```
Space                 open the menu (which-key) — your live cheat sheet
Space Space           find a file
Space s g             search text in all files
Space e               file tree
Ctrl-s                save
Ctrl-h/j/k/l          move between windows and tmux panes
Shift-h / Shift-l     previous / next open file
Ctrl-\                terminal
Esc                   clear search highlight
```

### Code
```
K                     documentation for what is under the cursor
gd                    go to definition
grr                   find all references
gri / grt / grD       implementation / type / declaration
gO / gW               symbols in file / in project
Space c a             code actions (auto-fix)
Space c r             rename symbol (live preview)
Space c R             rename file + update imports
Space c f             format now
Space c s             function outline
Space c o             fix imports (ESLint)
Space c d             show this line's error
Space u h             toggle inlay hints
Tab                   accept completion
Ctrl-j                accept AI ghost text
Ctrl-l                accept one AI word
gS                    split/join a one-liner
```

### Search
```
Space s f  files            Space s g  grep           Space s w  grep word under cursor
Space s b  buffers          Space s .  recent         Space /    search in this file
Space s h  help             Space s k  keymaps        Space s d  diagnostics
Space s r  resume search    Space s u  undo history   Space s m  marks
Space s n  config files     Space s q  quickfix       Space s c  commands
Space f r  find & replace project-wide
Space f w  find & replace the word under the cursor
```

### Files you are working on now
```
Space m a   mark this file        Space 1..4  jump to marked file 1-4
Space m m   the marked list       Space m n / m p   next / previous
```

### Git
```
Space g g   lazygit  ←            Space g s   status         Space g d   diff view
Space g f   this file's history   Space g b   blame          Space g l   log graph
Space g C   commit                Space g p   push           Space g P   pull
Space g B   open on GitHub
]c / [c     next / prev change
Space h p   preview hunk          Space h s   stage hunk     Space h r   reset hunk
Space h S   stage file            Space h R   reset file     Space h b   blame this line
Space u b   toggle inline blame
```

### Run / build
```
Space r r  run       Space r f  run this file    Space r b  build
Space r t  test      Space r l  dev server       Space r c  pick a task
Space r o  task list Space r w  re-run on save   Space r m  markdown preview
```

### Terminal
```
Ctrl-\        toggle          Space t t  float      Space t h / t v  split
Space t 1..5  slots 1-5       Alt-1..5   same, from inside a terminal
Space t f     in file's dir   Space t n  new        Space t k / Alt-k  kill
Esc Esc       leave terminal mode
```

### Problems
```
Space x x  all problems     Space x d  this file      Space x t  TODOs
Space x q  quickfix         Space x L  location list
]d / [d    next / prev problem      ]q / [q  next / prev quickfix item
]t / [t    next / prev TODO
```

### Debug
```
Space d b  breakpoint    F5   start/continue    F10  step over
Space d B  conditional   F11  step into         F7   toggle UI
Space d t  stop          Space d r  REPL        Space d l  run last
```

### AI
```
Ctrl-j      accept ghost text        Ctrl-l   accept one word
Ctrl-]      dismiss                  Space u a  toggle ghost text
Space a a   ask Avante               Space a e  edit selection (visual mode first)
Space a t   toggle sidebar           Space a c  add this file to context
Space a n   new conversation         Space a ?  switch model
  in sidebar:  A = apply all,  a = apply one,  Tab = switch pane,  q = close
```

### UI toggles
```
Space u u  undo tree      Space u z  zen mode      Space u w  word wrap
Space u b  git blame      Space u a  AI ghost      Space u h  inlay hints
Space u n  dismiss notifications     Space u N  notification history
Space .    scratch buffer            Space b d  close buffer
```

### Text objects (use after d, c, y, v)
```
i(  a(  i{  a{  i'  a"      inside / around brackets and quotes
ih                          inside a git hunk
saiw)   sd'   sr)'          add / delete / replace surroundings
vag                         select the whole file
```

---

## Where to go next

1. **Use `Space` and read the menu.** That habit alone will teach you this config.
2. **Use `Space s k`** to search every keybinding you have, by description.
3. **Start using Harpoon** (`Space m a`, then `Space 1`-`Space 4`). It is the biggest
   single speedup available to you and it takes 30 seconds to learn.
4. When you want to *change* something, read `doc/CONFIG_GUIDE.md` — it explains why each
   piece is built the way it is.
