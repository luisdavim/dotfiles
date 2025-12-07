# Nvim configuration

Overview
========
This init.lua config is a modular, plugin-first Neovim setup built around the "mini.nvim" family of modules and an ad-hoc plugin manager helper (MiniDeps). It loads a collection of plugins and configures common editing, LSP, Treesitter, completion and debugging capabilities. It uses a pattern of "now" (load immediately) and "later" (load lazily) functions to control when modules are bootstrapped.

Requirements
============
- Neovim (0.9+ recommended — features like vim.lsp.inlay_hint require recent NVim versions)
- git (used to clone mini.nvim automatically if missing)
- cargo + Rust toolchain (only required to build the Rust implementation of blink.cmp)
- External binaries installed by mason (gopls, lua_ls, shfmt, shellcheck, gofumpt, etc.) — mason handles many of these automatically.

How plugins are managed
=======================
- The config bootstraps the "mini.nvim" repository manually into stdpath('data')..'/site/pack/deps/start/mini.nvim' if not present. This allows using MiniDeps helpers that follow afterwards.
- Plugin declarations are done using MiniDeps.add (aliased to add in the config). Plugins are often declared with source (repo name), optional dependencies, hooks, and build/install hooks.
- The pattern:
  - now(fn) — run fn immediately at startup
  - later(fn) — queue fn to run later (MiniDeps.later)
  - later_on(event, callback) — attach a single autocommand that will call MiniDeps.now(callback) once the specified event happens
- Some plugins are added immediately (via now), others are added via later (lazy loaded).

Use `:DepsUpdate` to update plugins from current session with new data from their sources.

Lazy loading: now / later / later_on
===================================
- now(function) — executes immediately during startup (used for critical modules).
- later(function) — schedules module load later through MiniDeps.later (useful for non-critical UI or infrequent features).
- later_on(event, callback) — creates an autocommand for event, and when the event triggers it calls MiniDeps.now(callback). It avoids loading a module until the user performs the action (e.g., InsertEnter or VimEnter).

Main features and modules
=========================

Core options & behavior
-----------------------
- Leader is set to backslash: vim.g.mapleader = "\\"
- Universal options: UTF-8 encoding, unnamedplus clipboard, tab width 2, expandtab, smart indent, completeopt set to menuone, hlsearch true, relative file formats = "unix,dos,mac", etc.
- grepprg uses ripgrep: rg --glob "!.git" --no-heading --vimgrep --follow $*
- Auto-create parent directories before write (BufWritePre autocommand).
- Auto-write on InsertLeavePre/TextChanged if toggled on (see ToggleAutoSave).
- Help buffers are automatically opened in leftmost window (wincmd H).
- Filetype detection enhancements for various filenames and paths (Dockerfile, nginx.conf, Tiltfile, helm charts, .kube files, etc.)
- Commentstring for helm filetype is set to "{{/* %s */}}".

Platform detection
------------------
- function is_andriod() checks os_uname release for "android" and alters some plugin behavior (e.g., blink.cmp implementation fallback).

Key mappings (high level)
--------------------------
The config sets many keymaps. Below are the most used ones grouped:

Basic editing & navigation
- Visual indent: v: `<Tab>` -> >gv, `<S-Tab>` -> <gv
- Normal: `<Tab>` and `<S-Tab>` for indent adjustments
- Space toggles folding in visual mode; normal `<space>` toggles fold (za)
- Snippet-friendly `<Tab>` in insert/select mode (uses ``vim.snippet.jump``)
- Clear search highlight: `<C-L>` (<kbd>Ctrl</kbd> + <kbd>l</kbd>)
- Toggle spell check: `<leader>sc`

MiniFiles / Explorer and Snacks pickers
- Open MiniFiles: `<C-o>` (<kbd>Ctrl</kbd> + <kbd>o</kbd>)
- Snacks file picker: `<C-p>` (<kbd>Ctrl</kbd> + <kbd>p</kbd>)
- Snacks grep picker: `<CC-f>` (<kbd>Ctrl</kbd> + <kbd>f</kbd>)
- Toggle explorer (snacks): `<C-_>` (this tries toggling an existing explorer picker or opens one -  (<kbd>Ctrl</kbd> + <kbd>/</kbd>))
- Gitbrowse: :Gitbrowse
- Outline (buffer/workspace): `:Outline` or `<leader>o`

Window & buffer helpers
- Yank/paste window: `<leader>wy` (yank window), `<leader>wp` (paste as edit), `<leader>ws` (paste in split), `<leader>wv` (paste in vertical split), `<leader>wt` (paste as tab)
- Diff toggle: `<Leader>df` or `:DiffToggle`
- Gblame command for vertical Git blame: `:Gblame`
- Flog command (gitgraph draw): `:Flog`

LSP-related
- Rename: `<leader>rn` (uses Snacks.input prompt)
- Code actions: `<leader>ca` (visual or normal)
- Diagnostics picker: `<leader>ld`
- Go to definition: `gd`
- Declarations: `gD`
- Implementations: `gi`
- Type definitions: `go`
- References: `gr`
- Signature help: `gs`
- Symbols: `gS`
- Workspace symbols: `gf`
- Next diagnostic: ]g ; previous: `[g`
- Format file (async): `<F3>` ; Format command: `:Format`
- Toggle inlay hints: `<leader>H` (buffer-local)

DAP / Debugging
- Start/continue: `<F5>`
- Step over: `<F10>`
- Step into: `<F11>`
- Step out: `<F12>`
- Toggle breakpoint: `<leader>b`
- Set breakpoint: `<Leader>B`
- Set logpoint: `<Leader>lp`
- Open repl: `<Leader>dr`
- Debug last: `<Leader>dl`
- Open DAP UI: `<Leader>w` ; Close DAP UI: `<Leader>W` ; `:DapCloseUI`

User commands and toggles
-------------------------
A number of user commands are created for toggling behaviors or invoking features:

- `:ToggleAutoSave`
  - Toggles automatic saving behavior handled by the config
  - When enabled, `autowriteall` is toggled and buffers are saved on InsertLeavePre/TextChanged/TextChangedP.

- `:ToggleFormatOnSave`
  - Enabled by default. When enabled, BufWritePre triggers vim.lsp.buf.format to format the buffer before write.

- `:Format`
  - Run vim.lsp.buf.format({ async = false })

- `:QuickFix`
  - Applies 'source.fixAll' code actions via vim.lsp.buf.code_action

- `:Outline [buffer|workspace]`
  - Toggle an outline view (uses Snacks pickers for lsp_symbols or lsp_workspace_symbols)

- `:DiffToggle`
  - Toggle diff mode for all windows (turns cursorline on/off appropriately)

- `:Gblame`
  - Vertical Git blame for current file (uses Git blame -- %)

- `:Flog`
  - Draw a gitgraph (gitgraph.draw)

- `:DapCloseUI`
  - Closes the nvim-dap-ui

- `:ToggleTrimSpaceOnSave`
  - Toggle automatic trailing-space trimming on BufWritePre

- `:ToggleTrimSpaceOnSave` and `:ToggleAutoSave` and `:ToggleFormatOnSave` are simple boolean toggles scoped to the running Neovim session.

Treesitter
==========
- nvim-treesitter is added early (`now`) with automatic parser installation directory = stdpath('data') .. '/site'
- The config ensures several parsers are present (comment, lua, go, bash, json, yaml, python, etc.)
- When a buffer opens, an autocmd attempts to:
  - map filetype → treesitter language (syntax_map overrides)
  - ensure the parser is installed (via treesitter.install(...):await) and then start treesitter for that buffer
  - set fallback regex-based syntax highlighting, sets foldexpr/foldtext and indentation to treesitter-provided values
- Parsers are installed if not already present.

LSP and Mason setup
===================
- Plugins: folke/lazydev.nvim is added as a way to get a collection that depends on lspconfig, mason, mason-lspconfig etc.
- mason setup and mason-lspconfig: ensure_installed includes lua_ls, gopls, bashls, jsonls, yamlls
- mason-tool-installer ensures some linters/formatters (shfmt, shellcheck, gofumpt)
- custom_lspconfig table contains server-specific settings (gopls with many fine-grained settings, bashls with shfmt config, harper_ls filetypes example)
- A base_lspconfig is built with capabilities from blink.cmp and the on_attach function (which sets up highlights, inlay hints, folding, and autocommands)
- LspAttach autocommand configures:
  - Diagnostics UI (virtual_text=false, float border and width, custom signs)
  - CursorHold to show diagnostics under cursor unless a floating window already exists
  - Format on save behavior (ToggleFormatOnSave)
  - Register codeactions-on-save for common filetypes
  - Bordered hover and signature help wrappers
  - LSP keymaps bound to buffer

This configuration uses `Mason` to manage the LSP tools, use `:LspInstall` to see what language servers are available for the current filetype.

Completion (blink.cmp)
======================
- blink.cmp is added and built using a custom build callback (build_blink) that runs `cargo build --release` in the plugin path.
- On Android-like systems the config sets implementation = "lua" fallback; otherwise "prefer_rust".
- blink.cmp is configured with:
  - fuzzy implementation selection
  - use_nvim_cmp_as_default = true (appearance)
  - completion/documentation/menu/signature UI options including border style
  - integration with MiniIcons to show kind icons and highlights
- If building fails, the build step runs `cargo clean`.

Snacks (picker framework)
=========================
- folke/snacks.nvim is added and configured as a comprehensive picker/utility framework.
- Snacks replaces or enhances file picker, explorer, gitbrowse, and more.
- Keybindings:
  - Snacks.picker.files → `<C-p>`
  - Snacks.picker.grep → `<C-f>`
  - Snacks.picker.explorer toggle → `<C-_>`
- Snack pickers are used as LSP pickers (definitions, references, symbols, workspace symbols, diagnostics)
- Snacks.gitbrowse has URL patterns and is wired with the `:Gitbrowse` command.

Git / diff / blame integrations
===============================
- mini.git configured and a user autocmd handles MiniGitCommandSplit for 'blame' to align and bind scrolling between windows.
- blame.nvim (FabijanZulj/blame.nvim) added later and set up.
- vgit.nvim is loaded on VimEnter via later_on('VimEnter') and configured to disable live_blame default.
- isakbm/gitgraph.nvim + diffview.nvim are set up now (so gitgraph shell alias works). Hooks with DiffviewOpen integration are configured.
- `:Gblame` and `:Flog` commands are available.

DAP (debugging)
===============
- nvim-dap, nvim-dap-ui and adapters for go and python are added (dap-go, dap-python). mason-nvim-dap ensures automatic installation.
- dapui is set to automatically open before attach/launch
- Virtual text and icons configured
- DAP keymaps and DapCloseUI command are provided

Mini.* family modules configured
=============================
This config uses many mini modules. Not exhaustive, but the noteworthy ones are:
- mini.basics (options and mappings)
- mini.extra
- mini.notify + MiniNotify.make_notify
- mini.icons
- mini.tabline
- mini.statusline
- mini.starter
- mini.misc (restore cursor, auto root)
- mini.git
- mini.diff
- mini.files (file explorer) — mapped and extended with dotfile toggle and split helpers
- mini.pairs
- mini.splitjoin
- mini.surround
- mini.bracketed
- mini.jump
- mini.jump2d
- mini.sessions
- mini.visits
- mini.fuzzy
- mini.cursorword
- mini.hipatterns (highlights FIXME, TODO, HACK, NOTE and hex colors)
- mini.trailspace (trim trailing whitespace)
- mini.bufremove
- mini.map (minimap)
- mini.pairs
- etc.

Other notable plugins
---------------------
- Projekt0n/github-nvim-theme (theme; colorscheme set to github_dark_high_contrast)
- nvim-treesitter-textobjects and nvim-treesitter-context
- snacks.nvim (many pickers)
- blink.cmp (completion engine)
- lazydev.nvim, nvim-lspconfig and mason.nvim (LSP utilities)
- codeactions-on-save.nvim
- glance.nvim
- gx.nvim (gx browsing helpers)
- render-markdown.nvim and github-preview for markdown workflows
- markdown-table-mode for markdown table editing
- text-case.nvim
- blame.nvim
- vgit.nvim
- nvim-dap-ui and supporting DAP plugins
- gitgraph.nvim + diffview.nvim

Frequently used commands & keymaps (quick reference)
===================================================
User commands
- `:ToggleAutoSave` — toggle automatic in-session auto-save (note spelling)
- `:ToggleFormatOnSave` — toggle LSP format on save
- `:ToggleTrimSpaceOnSave` — toggle trailing whitespace trimming on save
- `:Format` — run LSP format for buffer
- `:QuickFix` — apply source.fixAll
- `:Outline` [buffer|workspace] — open outline picker
- `:DiffToggle` — toggle diff mode in all windows
- `:Gblame` — vertical Git blame for file
- `:Flog` — open gitgraph with a large history
- `:DapCloseUI` — close dap ui
- `:LspInstall` — install language servers for the current buffer's filetype
- `:DepsUpdate` — update plugins
- `:Mason` — Manage installed tools, like linters and LSPs

Keymaps
- `<C-p>` → Snacks file picker
- `<C-f>` → Snacks grep picker
- `<C-_>` → Toggle snacks explorer
- `<C-o>` → MiniFiles.open (explorer)
-`<leader>sc` → toggle spell checking
-`<leader>o` → outline toggle (buffer)
-`<leader>rn` → rename (prompts via Snacks)
-`<leader>ca` → code actions
-`<leader>ld` → diagnostics picker
- gd / gD / gi / go / gr / gS / gf → LSP navigation via Snacks pickers
-`<F3>` → format file
-`<F5>` /`<F10>` /`<F11>` /`<F12>` → dap controls
- `<leader>b`, `<Leader>B`, `<Leader>lp`, `<Leader>dr`,`<Leader>dl` → dap breakpoints/repl/debug last
- `<leader>wy`, `<leader>wp`, `<leader>ws`, `<leader>wv`,`<leader>wt` → yank/paste windows

How to add or modify plugins
============================
This setup uses MiniDeps.add to register plugins. Example pattern used in the config:

```lua
now(function()
  add({
    source = 'owner/repo',
    depends = { 'dependency/one', 'dependency/two' },
    hooks = { post_checkout = function() ... end },
    checkout = 'main',
  })
end)
```

Guidelines:
- If you want a plugin to load immediately, register it inside a now(...) call.
- If the plugin can be lazy-loaded, use later(...) or later_on(event, fn) and add it inside that.
- Use hooks to run build scripts. Example: blink.cmp uses post_install and post_checkout hooks to run a build function that runs `cargo build --release` in the plugin directory.

Building blink.cmp manually
---------------------------
If blink.cmp build fails, you can build it yourself:

1. Find the plugin path: it is installed under stdpath('data')..'/site/pack/deps/start/Saghen/blink.cmp' (or the path returned by MiniDeps when installed).
2. Run:
   ```bash
   cargo build --release
   ```
   in that plugin folder. The config attempts to run `cargo build --release` automatically after install/checkout.

Note: On Android the config uses the Lua fallback and won't try Rust by default (is_andriod detection).

Troubleshooting / Tips
======================
- If a plugin fails to build (blink.cmp), check the build logs. The config uses vim.system and notifies on success/failure.
- If Treesitter parser installation hangs or does not start — ensure git and network connectivity and that your Neovim's stdpath('data') folder is writable.
- If LSP servers are not present, run `:Mason` to open mason UI and install servers; mason-lspconfig is configured to ensure several servers.
- If LSP functionality isn't working for a server, check mason get_installed servers and logs to see if they've been configured. The config calls vim.lsp.config(server, config) for each installed server from mason-lspconfig.
- The config uses many autocommands and buffer-local settings in on_attach; if a feature like inlay hints doesn't show up, make sure the server advertises textDocument/inlayHint capability.
- Spelling: ToggleAutoSave is intentionally the command name in the config; if you prefer ToggleAutoSave you can rename it in the config and update usages.

Extending / Personalizing
=========================
- To add your own plugin: wrap MiniDeps.add in now(...) or later(...) and call add({ source = 'owner/repo', ... }). If it needs to be built, provide hooks { post_install = fn, post_checkout = fn }.
- You can change the leader from "\\" to whatever you like by editing vim.g.mapleader line early in the now(...) block.
- Change the border style variable border_style near top (default 'rounded') to 'single', 'double' or 'none' depending on your taste.

# Neovim config — Compact cheatsheet

Quick reference of user commands and key mappings defined in this configuration, plus important mappings from included plugins (Snacks, MiniFiles, nvim-dap, LSP pickers). Grouped and compact for easy lookup.

Notes
- Leader: \
- Many LSP mappings are buffer-local (set on LspAttach).
- Some mappings are created per-explorer buffer (MiniFiles) or per-snacks picker.
- Command names reflect exact spelling in the config (e.g., ToggleAutoSave).

User commands
- `:ToggleAutoSave` — toggle automatic saving (autowriteall + save on InsertLeavePre/TextChanged)
- `:Gitbrowse` — open current line in browser, for example, on `github.com`.
- `:DiffToggle` — toggle diff mode in all windows
- `:Gblame` — vertical Git blame for current file
- `:Flog` — draw gitgraph (history)
- `:DapCloseUI` — close nvim-dap-ui
- `:ToggleFormatOnSave` — toggle format-on-save for LSP formatting
- `:Format` — run LSP format for current buffer
- `:QuickFix` — run source.fixAll code-action apply
- `:LspToggleHints` — toggle inlay hints for current buffer
- `:Outline` [buffer|workspace] — toggle outline view (buffer or workspace)
- `:ToggleTrimSpaceOnSave` — toggle trimming trailing whitespace on save

Note: `<C-_>` is <kbd>Ctrl</kbd> + <kbd>/</kbd>

Global key mappings
- `<C-L>` — clear search highlight (:noh)
-`<leader>sc` — toggle spell checker (toggle vim.opt.spell)
- Visual indent:
  - v: `<Tab>` → indent (">gv")
  - v: `<S-Tab>` → unindent ("<gv")
- Normal indent:
  - n: `<Tab>` → indent line (">>_")
  - n: `<S-Tab>` → unindent line ("<<_")
- Insert:
  - i: `<S-Tab>` → `<C-D>` (shift-tab decreases indent)
- Folding:
  - v: `<Space>` → :fold
  - n: `<Space>` → za (toggle fold)

Snippet-friendly Tab
- modes i,s: `<Tab>` — expression mapping:
  - if `vim.snippet.active({ direction = 1 })` then jump snippet forward
  - else literal `<Tab>`
  (fallback depends on your snippet engine being exposed as vim.snippet)

Snacks (pickers) / file & grep
- n: `<C-p>` → Snacks.picker.files (file picker)
- n: `<C-f>` → Snacks.picker.grep (live grep)
- n: `<C-_>` → toggle Snacks explorer (focus/close/open)
- `:Gitbrowse` — open Snacks gitbrowse
- LSP pickers via Snacks (buffer-local in LspAttach):
  - `gd` → definitions
  - `gD` → declarations
  - `gi` → implementations
  - `go` → type definitions
  - `gr` → references
  - `gS` → document symbols
  - `gf` → workspace symbols
  - `<leader>ld` → diagnostics picker
  - `<leader>rn` → rename (prompts via Snacks.input)
  - `<leader>ca` → code actions (normal & visual)
  - `gs` → signature help (buffer-local mapped to 'gs')
  - `]g` / `[g` → next/prev diagnostic (with float)

MiniFiles / Explorer (global & per-explorer)
- n: `<C-o>` → MiniFiles.open
- In explorer buffers:
  - n: `g.` → toggle dotfiles in explorer
  - n: `<C-s>` → open selected path in horizontal split (mapped per-explorer buffer)
  - n: `<C-v>` → open selected path in vertical split (mapped per-explorer buffer)
- MiniFiles explorer internal mappings configured (used inside explorer):
  - close = `<Esc>`
  - go_in = `<Right>`
  - go_in_plus = `L`
  - go_out = `<Left>`
  - go_out_plus = `H`
  - mark_goto = `'`
  - mark_set = `m`
  - reset = `<BS>`
  - reveal_cwd = `@`
  - show_help = `g?`
  - synchronize = `=`
  - trim_left = `<`
  - trim_right = `>`

Windows & buffer helpers
- `<leader>wy` — yank current window (store buffer id)
- `<leader>wd` — yank current window and close it (store buffer id then q)
- `<leader>wp` — paste yanked window as edit (open buffer)
- `<leader>ws` — paste yanked window in split
- `<leader>wv` — paste yanked window in vertical split
- `<leader>wt` — paste yanked window in new tab

Formatting & saving
- `<F3>` (buffer-local in LspAttach) — format buffer (async)
- `<F4>` (buffer-local) — show code actions
- `<F2>` (buffer-local) — rename symbol
- `:Format` — format via LSP (sync)

Mini.surround
- Visual mode:
  - x: S → add surround in visual (MiniSurround.add('visual'))

Trailing spaces
- Trim on save (config default): enabled; toggle with :ToggleTrimSpaceOnSave

Git & diff helpers
- `<Leader>df` — toggle diff mode for all windows (same as :DiffToggle)
- `:Gblame` — vertical Git blame
- `:Flog` — open gitgraph draw

nvim-dap (debugging)
- n/v: `<M-e>` (<kbd>Alt</kbd> + <kbd>e</kbd>) — dapui.eval (evaluate expression)
- n: `<F5>` — dap.continue (start/continue)
- n: `<F10>` — dap.step_over
- n: `<F11>` — dap.step_into
- n: `<F12>` — dap.step_out
- n: `<leader>b` — dap.toggle_breakpoint
- n: `<Leader>B` — dap.set_breakpoint
- n: `<Leader>lp` — set logpoint (prompts for message)
- n: `<Leader>dr` — dap.repl.open
- n: `<Leader>dl` — dap.run_last
- n: `<Leader>w` — open DAP UI
- n: `<Leader>W` — close DAP UI
- `:DapCloseUI` — command to close dap UI

Inlay hints
- Buffer-local mapping (set in on_attach if server supports inlayHint):
  - n: `<leader>H` — toggle inlay hints for buffer
  - `:LspToggleHints` — same toggle as a command

Other plugin notes / useful mappings
- Snacks.rename integration: MiniFiles rename action triggers Snacks.rename.on_rename_file
- blink.cmp:
  - configured to use enter-preset keymap; inline completion integration set to prefer rust (or lua on Android)
  - completion menu & documentation use configured border style
- mini.map (minimap) — no global mapping, but configured integrations (search, diff, diagnostic)
- hipatterns highlighting: TODO/FIXME/HACK/NOTE highlighted (no keymap)

Buffer-local LSP mappings summary (set on LspAttach)
- `<leader>rn`, `<leader>ca`, `<leader>ld`, `gd`, `gD`, `gi`, `go`, `gr`, `gs`, `gS`, `gf`, `]g`, `[g`, `<F3>`, `<F4>`, `<F2>`, `K`

Search tips
- Grep uses ripgrep: grepprg = `rg --glob "!.git" --no-heading --vimgrep --follow $*`
- Grep output format is configured for quickfix
