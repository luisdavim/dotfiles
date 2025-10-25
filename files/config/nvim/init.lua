-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/nvim-mini/mini.nvim', mini_path }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps'
require('mini.deps').setup({ path = { package = path_package } })

-- Use 'mini.deps' helpers
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
-- Run latter on events
local laterGroup = vim.api.nvim_create_augroup("laterGroup", { clear = true })
local function later_on(event, callback)
  vim.api.nvim_create_autocmd(event, {
    callback = function() now(callback) end,
    once = true,
    group = laterGroup,
  })
end
-- Alternative where only one auttocmd is created per event
-- local event_callback_queues = {}
-- local laterGroup = vim.api.nvim_create_augroup("laterGroup", { clear = true })
-- local function later_on(event, callback)
--   if event_callback_queues[event] == nil then
--     event_callback_queues[event] = {}
--     vim.api.nvim_create_autocmd(event, {
--       callback = function()
--         for _, f in ipairs(event_callback_queues[event]) do
--           now(f)
--         end
--       end,
--       once = true,
--       group = laterGroup,
--     })
--   end
--   table.insert(event_callback_queues[event], callback)
-- end

-- Global settings
local keymap = vim.keymap.set
local border_style = 'rounded'

-- Vim setup
now(function()
  vim.g.mapleader = "\\"
  vim.g.fileformats = "unix,dos,mac"

  local set = vim.opt -- set options

  set.encoding = "utf-8"
  set.clipboard = "unnamedplus"
  set.tabstop = 2
  set.softtabstop = 2
  set.smartindent = true
  set.shiftwidth = 2
  set.expandtab = true
  set.smarttab = true
  set.scrolloff = 1
  set.ttyfast = true
  set.lazyredraw = true
  set.ttimeout = true
  set.ttimeoutlen = 50
  set.updatetime = 300
  set.completeopt = 'menuone'
  set.hlsearch = true

  vim.o.number = true
  -- vim.o.pumborder = border_style

  -- Use rg
  vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  vim.opt.grepformat = vim.opt.grepformat ^ { "%f:%l:%c:%m" }

  -- Automatically create parent directories
  local automkdirGroup = vim.api.nvim_create_augroup("automkdirGroup", { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    -- Function gets a table that contains match key, which maps to `<amatch>` (a full filepath).
    callback = function(t)
      local fname = vim.loop.fs_realpath(t.match) or t.match
      local dirname = vim.fs.dirname(fname)
      if not vim.loop.fs_stat(dirname) then
        -- Use 755 permissions, which means rwxr.xr.x
        -- vim.loop.fs_mkdir(dirname, tonumber("0755", 8))
        vim.fn.mkdir(dirname, 'p')
      end
    end,
    group = automkdirGroup
  })

  --- Automatically save when leaving insert mode
  -- vim.o.autowriteall = true
  -- vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged', 'TextChangedP' }, {
  --   pattern = '*',
  --   callback = function()
  --     vim.cmd('silent! write')
  --   end
  -- })

  -- Automatically Split help Buffers to the left
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    command = "wincmd H"
  })

  -- File type detection
  vim.filetype.add({
    extension = {
      dockerfile = 'dockerfile',
      nginx = 'nginx',
    },
    filename = {
      ['Dockerfile'] = 'dockerfile',
      ['dockerfile'] = 'dockerfile',
      ['Jenkinsfile'] = 'groovy',
      ['jenkinsfile'] = 'groovy',
      ['Terrafile'] = 'yaml',
      ['terrafile'] = 'yaml',
      ['nginx.conf'] = 'nginx',
      ['Tiltfile'] = 'tiltfile',
      ['tiltfile'] = 'tiltfile'
    },
    pattern = {
      ['.*/etc/nginx/.*'] = { 'nginx', { priority = 10 } },
      ['.*/usr/local/nginx/conf/.*'] = { 'nginx', { priority = 10 } },
      [".*/%.kube/config"] = 'yaml',
      ['.*/%.kube/config%.d/.*'] = 'yaml',
      ['.*/charts?/.*/templates/.*%.ya?ml'] = 'helm',
      ['.*/templates/.*%.ya?ml'] = 'helm',
      ['.*/templates/.*%.tpl'] = 'helm',
      ['.*/templates/.*%.txt'] = 'helm',
      ['.*/helmfile.*%.ya?ml'] = 'helm',
      ['.*%.dockerfile'] = 'dockerfile',
      ['.*%.Tiltfile'] = 'tiltfile',
      ['.*%.tiltfile'] = 'tiltfile',
      ['.*%.variables.*'] = 'sh',
      ['.*%.env'] = 'sh',
    },
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "helm",
    callback = function()
      vim.opt_local.commentstring = "{{/* %s */}}"
    end,
  })

  -- keymaps

  -- indent using tab
  keymap('v', '<Tab>', '>gv', {})
  keymap('v', '<S-Tab>', '<gv', {})
  keymap('n', '<Tab>', '>>_', {})
  keymap('n', '<S-Tab>', '<<_', {})
  keymap('i', '<S-Tab>', '<C-D>', {})

  -- folds
  keymap('v', "<space>", ":fold<CR>", { silent = true })
  keymap('n', "<space>", "za", { silent = true })

  -- Make <Tab> work for snippets
  keymap({ 'i', 's' }, '<Tab>', function()
    if vim.snippet.active({ direction = 1 }) then
      return '<cmd>lua vim.snippet.jump(1)<cr>'
    else
      return '<Tab>'
    end
  end, { expr = true })

  -- clear search highlight
  keymap('n', '<C-L>', '<cmd>noh<CR>', { noremap = true, silent = true })
  -- toggle spell checker
  keymap('n', '<leader>sc', function()
    vim.opt.spell = not (vim.opt.spell:get())
  end)
end)

now(function()
  add({
    source = 'lewis6991/fileline.nvim'
  })
end)

now(function()
  require('mini.basics').setup({
    options = { basic = true, extra_ui = true, win_borders = border_style },
    mappings = { basic = true, windows = true, move_with_alt = true },
  })
  vim.opt.completeopt = 'menuone'
end)

now(function() require('mini.extra').setup() end)

-- later(function() require('mini.animate').setup() end)
-- later(function() require('mini.base16').setup() end)
-- later(function() require('mini.colors').setup() end)
-- later(function() require('mini.hues').setup() end)

later(function() require('mini.ai').setup() end)
later(function() require('mini.align').setup() end)
later(function() require('mini.comment').setup() end)
later(function() require('mini.move').setup() end)
later(function() require('mini.operators').setup() end)

-- Treesitter
now(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    checkout = 'main',
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-context',
  })

  local treesitter = require('nvim-treesitter')
  local ts_config = require('nvim-treesitter.config')
  treesitter.setup({
    -- Directory to install parsers and queries to
    install_dir = vim.fn.stdpath('data') .. '/site'
  })
  require('nvim-treesitter-textobjects').setup()
  require('treesitter-context').setup()

  local ensure_installed = {
    'comment', 'lua', 'luadoc', 'go', 'c', 'bash', 'yaml',
    'json', 'python', 'markdown', 'markdown_inline',
    'diff', 'starlark', 'gitcommit', 'vim', 'vimdoc', 'help',
    'promql', 'sql',
  }
  local syntax_map = {
    ['tiltfile'] = 'starlark',
  }
  local already_installed = ts_config.get_installed('parsers')
  local parsers_to_install = vim.iter(ensure_installed)
      :filter(function(parser) return not vim.tbl_contains(already_installed, parser) end)
      :totable()
  if #parsers_to_install > 0 then
    treesitter.install(parsers_to_install)
  end

  local function ts_start(bufnr, parser_name)
    vim.treesitter.start(bufnr, parser_name)
    -- Use regex based syntax-highlighting as fallback as some plugins might need it
    vim.bo[bufnr].syntax = "ON"
    -- Use treesitter for folds
    vim.wo.foldlevel = 99
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"
    -- Use treesitter for indentation
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end

  -- Auto-install and start parsers for any buffer
  vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "Enable Treesitter",
    callback = function(event)
      local bufnr = event.buf
      local filetype = event.match

      -- Skip if no filetype
      if filetype == "" then
        return
      end

      -- Get parser name based on filetype
      local lang = vim.tbl_get(syntax_map, filetype)
      if lang == nil then
        lang = filetype
      else
        vim.notify("Using language override " .. lang)
      end
      local parser_name = vim.treesitter.language.get_lang(lang)
      if not parser_name then
        vim.notify(vim.inspect("No treesitter parser found for filetype: " .. lang), vim.log.levels.WARN)
        return
      end

      -- Try to get existing parser
      if not vim.tbl_contains(ts_config.get_available(), parser_name) then return end

      -- Check if parser is already installed
      if not vim.tbl_contains(already_installed, parser_name) then
        -- If not installed, install parser asynchronously and start treesitter
        vim.notify("Installing parser for " .. parser_name, vim.log.levels.INFO)
        treesitter.install({ parser_name }):await(
          function()
            ts_start(bufnr, parser_name)
          end
        )
        return
      end

      -- Start treesitter for this buffer
      ts_start(bufnr, parser_name)
    end,
  })
end)

-- Theme setup
now(function()
  add({
    source = 'projekt0n/github-nvim-theme',
    hooks = { post_checkout = function() vim.cmd('GithubThemeCompile') end },
  })

  vim.o.termguicolors = true
  vim.cmd.colorscheme('github_dark_high_contrast')
end)

now(function()
  require('mini.notify').setup()
  vim.notify = MiniNotify.make_notify()
end)

now(function() require('mini.icons').setup() end)
now(function() require('mini.tabline').setup() end)
now(function() require('mini.statusline').setup() end)

now(function() require('mini.starter').setup() end)

now(function()
  require('mini.misc').setup({ make_global = { "put", "put_text" } })
  MiniMisc.setup_restore_cursor()
  MiniMisc.setup_auto_root({
    'requirements.txt', 'setup.cfg', 'package.json', 'go.mod', 'Cargo.toml', '.projections.json',
    'PROJECT', 'Makefile', 'pom.xml', '.root', '.repo', '.git', '.hg', '.bzr', '.svn',
  })
end)

-- Snacks
now(function()
  add({
    source = "folke/snacks.nvim",
  })

  local truncate_width = vim.api.nvim_win_get_width(0) * 0.5

  local snacks = require('snacks')
  snacks.setup({
    animate = { enabled = false },
    bigfile = { enabled = true },
    bufdelete = { enabled = false },
    dashboard = { enabled = false },
    debug = { enabled = false },
    dim = { enabled = false },
    explorer = {
      enabled = true,
      replace_netrw = true,
    },
    git = { enabled = false },
    gitbrowse = {
      enabled = true,
      url_patterns = {
        [".*github.*%..+"] = {
          branch = "/tree/{branch}",
          file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
          permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
          commit = "/commit/{commit}",
        },
        [".*gitlab.*%..+"] = {
          branch = "/-/tree/{branch}",
          file = "/-/blob/{branch}/{file}#L{line_start}-L{line_end}",
          permalink = "/-/blob/{commit}/{file}#L{line_start}-L{line_end}",
          commit = "/-/commit/{commit}",
        },
      },
    },
    image = { enabled = false },
    indent = {
      enabled = true,
      indent = {
        hl = "Whitespace",
      },
    },
    input = { enabled = true },
    layout = { enabled = false },
    lazygit = { enabled = false },
    notifier = {
      enabled = false,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      formatters = {
        file = {
          truncate = truncate_width,
        },
      },
      layout = {
        preset = 'ivy',
      },
      -- sources = {
      --   explorer = {
      --     auto_close = true,
      --   },
      -- },
    },
    quickfile = { enabled = true },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = true },
    zen = { enabled = false },
    styles = {
      notification = {
        relative = "editor",
        wo = { wrap = true }, -- Wrap notifications
      },
    },
  })

  keymap('n', '<C-p>', Snacks.picker.files, {})
  keymap('n', '<C-f>', Snacks.picker.grep, {})
  -- keymap('n', '<C-_>', function() Snacks.explorer() end, {})
  -- Toggle the explorer buffer
  keymap('n', '<C-_>',
    function()
      local explorer_pickers = Snacks.picker.get({ source = "explorer" })
      for _, v in pairs(explorer_pickers) do
        if v:is_focused() then
          v:close()
        else
          v:focus()
        end
      end
      if #explorer_pickers == 0 then
        Snacks.picker.explorer()
      end
    end, {})

  vim.api.nvim_create_user_command('Gitbrowse', Snacks.gitbrowse.open, {})

  -- Disable Mini.nvi Functionality in snacks inputs
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_*",
    callback = function(args)
      vim.b[args.buf].minicompletion_disable = true
      vim.b[args.buf].minidiff_disable = true
    end
  })
end)

-- later(function()
--   -- local ui_select_orig = vim.ui.select
--   require('mini.pick').setup()
--   -- vim.ui.select = ui_select_orig
--
--   -- MiniPick.ui_select but opens at the cursor position
--   vim.ui.select = function(items, opts, on_choice)
--     local function get_cursor_anchor() return vim.fn.screenrow() < 0.5 * vim.o.lines and "NW" or "SW" end
--     local num_items = #items
--     local max_height = math.floor(0.45 * vim.o.columns)
--     local height = math.min(math.max(num_items, 1), max_height)
--     local start_opts = {
--       options = { content_from_bottom = get_cursor_anchor() == "SW" },
--       window = {
--         config = {
--           relative = "cursor",
--           anchor = get_cursor_anchor(),
--           row = get_cursor_anchor() == "NW" and 1 or 0,
--           col = 0,
--           width = math.floor(0.45 * vim.o.columns),
--           height = height,
--         },
--       },
--     }
--     return MiniPick.ui_select(items, opts, on_choice, start_opts)
--   end
--
--   -- keymap('n', '<C-p>', '<cmd>Pick files<cr>', {})
--   -- keymap('n', '<C-f>', '<cmd>Pick grep_live<cr>', {})
--   -- keymap('n', '<C-_>', '<cmd>Pick explorer<cr>', {})
-- end)

-- Auto-completion

-- Sinppets

-- later(function()
--   local snippets = require('mini.snippets')
--   local gen_loader = snippets.gen_loader
--   snippets.setup({ snippets = { gen_loader.from_lang() } })
--   MiniSnippets.start_lsp_server()
-- end)

-- AI

-- later_on('InsertEnter', function()
--   add({
--     source = 'zbirenbaum/copilot.lua',
--   })
--   require('copilot').setup({
--     suggestion = { enabled = false },
--     panel = { enabled = false },
--   })
-- end)

-- later(function()
--   add({
--     source = "folke/sidekick.nvim",
--   })
--   require('sidekick').setup({
--     -- add any options here
--     cli = {
--       mux = {
--         backend = "tmux",
--         enabled = true,
--       },
--     },
--   })
--
--   keymap('n', "<tab>",
--     function()
--       -- if there is a next edit, jump to it, otherwise apply it if any
--       if not require("sidekick").nes_jump_or_apply() then
--         return "<Tab>" -- fallback to normal tab
--       end
--     end,
--     { desc = "Goto/Apply Next Edit Suggestion" }
--   )
--   keymap({ "n", "x", "i", "t" }, "<C-.>",
--     function()
--       require("sidekick.cli").toggle()
--     end,
--     { desc = "Sidekick Switch Focus" }
--   )
--   keymap({ "n", "v" }, "<leader>aa",
--     function()
--       require("sidekick.cli").toggle()
--     end,
--     { desc = "Sidekick Toggle CLI" }
--   )
--   keymap("n", "<leader>as",
--     function()
--       require("sidekick.cli").select()
--     end,
--     { desc = "Sidekick Select CLI" }
--   )
--   keymap("n", "<leader>ad",
--     function()
--       require("sidekick.cli").close()
--     end,
--     { desc = "Sidekick Detach a CLI Session" }
--   )
--   keymap({ "n", "x" }, "<leader>at",
--     function()
--       require("sidekick.cli").send({ msg = "{this}"})
--     end,
--     { desc = "Sidekick Send This" }
--   )
--   keymap("n", "<leader>af",
--     function()
--       require("sidekick.cli").send({ msg = "{file}"})
--     end,
--     { desc = "Sidekick Send File" }
--   )
--   keymap("x", "<leader>av",
--     function()
--       require("sidekick.cli").send({ msg = "{selection}"})
--     end,
--     { desc = "Sidekick Send Selection" }
--   )
--   keymap({ "n", "x" }, "<leader>ap",
--     function()
--       require("sidekick.cli").prompt()
--     end,
--     { desc = "Sidekick Select Prompt" }
--   )
--   keymap({ "n", "v" }, "<leader>ac",
--     function()
--       require("sidekick.cli").toggle({ name = "claude", focus = true })
--     end,
--     { desc = "Sidekick Claude Toggle" }
--   )
--   keymap({ "n", "v" }, "<leader>ag",
--     function()
--       require("sidekick.cli").toggle({ name = "grok", focus = true })
--     end,
--     { desc = "Sidekick Grok Toggle" }
--   )
-- end)

-- Completion Menu

-- Using blink.cmp
now(function()
  local function build_blink(params)
    vim.notify('Building blink.cmp', vim.log.levels.INFO)
    local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = params.path }):wait()
    if obj.code == 0 then
      vim.notify('Building blink.cmp done', vim.log.levels.INFO)
    else
      vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
      vim.system({ 'cargo', 'clean' }, { cwd = params.path }):wait()
    end
  end

  add({
    source = 'Saghen/blink.cmp',
    -- depends = {
    --   'fang2hou/blink-copilot',
    -- },
    hooks = {
      post_install = build_blink,
      post_checkout = build_blink,
    },
  })

  require('blink.cmp').setup({
    fuzzy = { implementation = "prefer_rust" },
    appearance = {
      use_nvim_cmp_as_default = true,
    },
    keymap = {
      preset = 'enter',
      -- ["<Tab>"] = {
      --   "snippet_forward",
      --   function() -- sidekick next edit suggestion
      --     return require("sidekick").nes_jump_or_apply()
      --   end,
      --   function() -- if you are using Neovim's native inline completions
      --     return vim.lsp.inline_completion.get()
      --   end,
      --   "fallback",
      -- },
    },
    -- sources = {
    --   default = { 'lsp', 'buffer', 'snippets', 'path', 'copilot' },
    --   providers = {
    --     copilot = {
    --       name = "copilot",
    --       module = "blink-copilot",
    --       score_offset = 100,
    --       async = true,
    --     },
    --   },
    -- },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 250,
        treesitter_highlighting = true,
        window = { border = border_style },
      },
      menu = {
        border = border_style,
        auto_show = true,
        draw = {
          treesitter = { 'lsp' },
          components = {
            kind_icon = {
              text = function(ctx)
                local kind_icon, _, _ = MiniIcons.get('lsp', ctx.kind)
                return kind_icon
              end,
              highlight = function(ctx)
                local _, hl, _ = MiniIcons.get('lsp', ctx.kind)
                return hl
              end,
            },
            kind = {
              highlight = function(ctx)
                local _, hl, _ = MiniIcons.get('lsp', ctx.kind)
                return hl
              end,
            }
          },
          columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon' }, { "kind" } },
        },
      },
    },
    signature = {
      enabled = true,
      window = { border = border_style },
    },
  })
end)


-- LSP config
now(function()
  add({
    source = 'folke/lazydev.nvim',
    depends = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp'
      -- 'jay-babu/mason-null-ls.nvim',
      -- 'nvimtools/none-ls.nvim',
    },
  })

  require('lazydev').setup()
  -- require('mason-null-ls').setup({
  --   handlers = {},
  -- })
  require('mason').setup()
  local mason_lspconfig = require('mason-lspconfig')
  mason_lspconfig.setup({
    automatic_enable = true,
    ensure_installed = { 'lua_ls', 'gopls', 'bashls', 'bzl', 'buf_ls', 'jsonls', 'yamlls' },
  })
  require('mason-tool-installer').setup({
    auto_update = false,
    run_on_start = true,
    start_delay = 3000,
    debounce_hours = 5,
    integrations = {
      ['mason-lspconfig'] = true,
      -- ['mason-null-ls'] = true,
      ['mason-nvim-dap'] = true,
    },
    ensure_installed = { 'shfmt', 'shellcheck', 'gofumpt' },
  })

  add({
    source = 'fnune/codeactions-on-save.nvim',
  })
  add({
    source = 'dnlhc/glance.nvim',
  })

  require('lspconfig')
  -- TODO: this should not be needed
  vim.lsp.enable('tilt_ls')

  local capabilities = require('blink.cmp').get_lsp_capabilities()
  capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), capabilities)

  local function on_attach(client, buffnr)
    MiniIcons.tweak_lsp_kind()

    -- highlight symbol under cursor
    if client ~= nil and client.supports_method('textDocument/documentHighlight', buffnr) then
      vim.b[buffnr].minicursorword_disable = true

      vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'MiniCursorword' })
      vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'MiniCursorword' })
      vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'MiniCursorword' })

      local group = vim.api.nvim_create_augroup('highlight_symbol', { clear = false })
      vim.api.nvim_clear_autocmds({ buffer = buffnr, group = group })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = group,
        buffer = buffnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = group,
        buffer = buffnr,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- LSP UI settings
    vim.diagnostic.config({
      virtual_text = false,
      float = {
        border = border_style,
        width = math.floor(0.25 * vim.o.columns)
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '✘',
          [vim.diagnostic.severity.WARN] = '▲',
          [vim.diagnostic.severity.HINT] = '⚑',
          [vim.diagnostic.severity.INFO] = '»',
        },
      },
    })

    -- Diagnostics
    -- Function to check if a floating dialog exists and if not
    -- then check for diagnostics under the cursor
    local function openDiagnosticIfNoFloat()
      for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(winid).zindex then
          return
        end
      end
      vim.diagnostic.open_float(nil, {
        scope = 'line',
        border = border_style,
        width = math.floor(0.25 * vim.o.columns),
        focusable = false,
        close_events = {
          'CursorMoved',
          'CursorMovedI',
          'BufHidden',
          'InsertCharPre',
          'WinLeave',
        },
      })
    end

    -- Show diagnostics under the cursor when holding position
    vim.api.nvim_create_augroup('lsp_diagnostics_hold', { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorHold' }, {
      pattern = "*",
      callback = openDiagnosticIfNoFloat,
      group = 'lsp_diagnostics_hold',
    })

    -- Inlay hints
    if client ~= nil and client.supports_method('textDocument/inlayHint', buffnr) then
      vim.lsp.inlay_hint.enable(true, { buffnr })
      keymap('n', '<leader>H',
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { buffnr })
        end, { buffer = buffnr, desc = "Toggle inlay hints" })
      vim.api.nvim_create_user_command('LspToggleHints', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { buffnr })
      end, {})
    end

    -- Folds
    if client ~= nil and client.supports_method('textDocument/foldingRange', buffnr) then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
      vim.wo[win][0].foldtext = "v:lua.vim.lsp.foldtext()"
      vim.wo[win][0].foldmethod = "expr"
    end

    require('glance').setup()

    -- Format on save
    local format_on_save = true
    local function toggle_format_on_save()
      format_on_save = not format_on_save
    end

    -- Create a command :ToggleFormatOnSave that calls the toggle function
    vim.api.nvim_create_user_command('ToggleFormatOnSave', toggle_format_on_save, {})

    vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
      -- buffer = 0, -- if 0 doesn't work do vim.api.nvim_get_current_buf()
      -- pattern = { "*.yaml", "*.yml", "*.go", "*.ts", "*.tf", "*.sh" },
      callback = function(_)
        if not format_on_save then
          return
        end
        vim.lsp.buf.format({ async = false })
        -- vim.lsp.buf.code_action is async and may not resolve before the buffer is closed
        -- vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
        -- vim.lsp.buf.code_action { context = { only = { 'source.fixAll' } }, apply = true }
      end
    })
    vim.api.nvim_create_user_command('Format', function()
      vim.lsp.buf.format({ async = false })
    end, {})
    vim.api.nvim_create_user_command('QuickFix', function()
      vim.lsp.buf.code_action { context = { only = { 'source.fixAll' } }, apply = true }
    end, {})

    local cos = require('codeactions-on-save')
    cos.register({ '*.py', '*.go', '*.rb' }, { 'source.organizeImports' })
    cos.register({ '*.ts', '*.tsx' }, { 'source.organizeImports.biome', 'source.fixAll' })

    local function bordered_hover(_opts)
      _opts = _opts or {}
      return vim.lsp.buf.hover(vim.tbl_deep_extend('force', _opts, {
        border = border_style
      }))
    end

    local function bordered_signature_help(_opts)
      _opts = _opts or {}
      return vim.lsp.buf.signature_help(vim.tbl_deep_extend('force', _opts, {
        border = border_style
      }))
    end

    -- LSP keymaps
    keymap('n', '<leader>rn',
      function()
        local cword = vim.fn.expand('<cword>')
        Snacks.input(
          { prompt = 'Rename', default = cword, win = { relative = 'cursor', row = -3, col = -3 } },
          vim.lsp.buf.rename
        )
      end,
      { silent = true }
    )
    keymap({ 'n', 'v' }, '<leader>ca', function() vim.lsp.buf.code_action() end,
      { buffer = buffnr, desc = "Code actions" }
    )
    -- keymap('n', '<leader>ld', MiniExtra.pickers.diagnostic, { buffer = buffnr, desc = "Diagnostics" })
    keymap('n', '<leader>ld', Snacks.picker.diagnostics, { buffer = buffnr, desc = "Diagnostics" })

    -- keymap('n', 'gd', function() vim.lsp.buf.definition() end, { buffer = buffnr, desc = "Go to definition" })
    -- keymap('n', gd, function() require('glance').open("definitions") end, { buffer = buffnr, desc = "Go to definition" })
    -- keymap('n', 'gd', function() MiniExtra.pickers.lsp({ scope = 'definition' }) end, { buffer = buffnr, desc = "Go to definition" })
    keymap('n', 'gd', Snacks.picker.lsp_definitions, { buffer = buffnr, desc = "Go to definition" })

    -- keymap('n', 'gD', function() vim.lsp.buf.declaration() end, { buffer = buffnr, desc = "go to declaration" })
    -- keymap('n', 'gD', function() MiniExtra.pickers.lsp({ scope = 'declaration' }) end, { buffer = buffnr, desc = "go to declaration" })
    keymap('n', 'gD', Snacks.picker.lsp_declarations, { buffer = buffnr, desc = "go to declaration" })

    -- keymap('n', 'gi', function() vim.lsp.buf.implementation() end, { buffer = buffnr, desc = "go to implementation" })
    -- keymap('n', 'gi', function() MiniExtra.pickers.lsp({ scope = 'implementation' }) end, { buffer = buffnr, desc = "go to implementation" })
    keymap('n', 'gi', Snacks.picker.lsp_implementations, { buffer = buffnr, desc = "go to implementation" })

    -- keymap('n', 'go', function() vim.lsp.buf.type_definition() end, { buffer = buffnr, desc = "go to type definition" })
    -- keymap('n', 'go', function() MiniExtra.pickers.lsp({ scope = 'type_definition' }) end, { buffer = buffnr, desc = "go to type definition" })
    keymap('n', 'go', Snacks.picker.lsp_type_definitions, { buffer = buffnr, desc = "go to type definition" })

    -- keymap('n', 'gr', function() vim.lsp.buf.references() end, { buffer = buffnr, desc = "list references" })
    -- keymap('n', 'gr', function() MiniExtra.pickers.lsp({ scope = 'references' }) end, { buffer = buffnr, desc = "list references" })
    keymap('n', 'gr', Snacks.picker.lsp_references, { buffer = buffnr, desc = "list references" })

    keymap('n', 'gs', bordered_signature_help, { buffer = buffnr, desc = "signature help" })

    -- keymap('n', 'gS', function() MiniExtra.pickers.lsp({ scope = 'document_symbol' }) end, { buffer = buffnr, desc = "list symbols" })
    keymap('n', 'gS', Snacks.picker.lsp_symbols, { buffer = buffnr, desc = "list symbols" })

    -- keymap('n', 'gf', function() MiniExtra.pickers.lsp({ scope = 'workspace_symbol' }) end, { buffer = buffnr, desc = "list workspace symbols" })
    keymap('n', 'gf', Snacks.picker.lsp_workspace_symbols, { buffer = buffnr, desc = "list workspace symbols" })

    keymap('n', ']g', function() vim.diagnostic.jump({ count = 1, float = true }) end,
      { buffer = buffnr, desc = "go to next diagnostic" })
    keymap('n', '[g', function() vim.diagnostic.jump({ count = -1, float = true }) end,
      { buffer = buffnr, desc = "go to previous diagnostic" })

    keymap({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end,
      { buffer = buffnr, desc = "format file" })
    keymap({ 'n', 'v' }, '<F4>', vim.lsp.buf.code_action, { buffer = buffnr, desc = "code actions" })
    keymap('n', '<F2>', vim.lsp.buf.rename, { buffer = buffnr, desc = "rename symbol" })
    keymap('n', 'K', bordered_hover, { buffer = buffnr, desc = "show help" })
  end

  local custom_lspconfig = {
    ["harper_ls"] = {
      filetypes = { "markdown", "gitcommit", "html" },
    },
    ['gopls'] = {
      cmd = { "gopls", "-remote=auto" },
      filetypes = { "go", "gomod", "gowork", "gotmpl", "gohtmltmpl", "gotexttmpl" },
      root_dir = vim.fs.dirname(
        vim.fs.find({ 'go.mod', 'go.work', '.git' }, { upward = true })[1]
      ),
      settings = {
        gopls = {
          gofumpt = false,
          staticcheck = true,
          semanticTokens = true,
          usePlaceholders = true,
          completeUnimported = true,
          completionDocumentation = true,
          deepCompletion = true,
          matcher = "Fuzzy",
          directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules", "-.nvim" },
          codelenses = {
            gc_details = false,
            generate = true,
            regenerate_cgo = true,
            run_govulncheck = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralTypes = true,
            compositeLiteralFields = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
            constantValues = true
          },
          analyses = {
            nilness = true,
            unusedparams = true,
            unusedwrite = true,
            useany = true,
            unreachable = false,
            shadow = true,
          },
        },
      },
    },
    ['bashls'] = {
      settings = {
        bashIde = {
          shfmt = {
            -- simplifyCode = true,
            -- binaryNextLine = true,
            languageDialect = "auto",
            spaceRedirects = true,
            caseIndent = true,
            indentSize = 2,
          },
        },
      },
    }
  }

  local base_lspconfig = {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
    local srv_settings = vim.tbl_get(custom_lspconfig, server)
    if srv_settings ~= nil then
      -- vim.notify('LSP: setting up ' .. server .. ' with custom configs')
      vim.lsp.config(server, vim.tbl_deep_extend('force', srv_settings, base_lspconfig))
    else
      -- vim.notify('LSP: setting up ' .. server)
      vim.lsp.config(server, base_lspconfig)
    end
  end

  -- vim.lsp.config("*", base_lspconfig)
end)

-- Git and diff

now(function()
  -- Define a function to toggle diff mode in all windows
  function DiffToggle()
    if vim.wo.diff then
      -- If already in diff mode, turn on cursorline and turn off diff in all windows
      vim.cmd('windo set cursorline')
      vim.cmd('windo diffoff')
    else
      -- If not in diff mode, turn off cursorline and turn on diff in all windows
      vim.cmd('windo set nocursorline')
      vim.cmd('windo diffthis')
    end
  end

  -- Create a command :DiffToggle that calls the function
  vim.api.nvim_create_user_command('DiffToggle', DiffToggle, {})

  -- Create a normal-mode mapping for <Leader>df to call DiffToggle
  keymap('n', '<Leader>df', DiffToggle, { silent = true })
end)

now(function()
  require('mini.git').setup()

  local function align_blame(au_data)
    if au_data.data.git_subcommand ~= 'blame' then return end

    -- Align blame output with source
    local win_src = au_data.data.win_source
    vim.wo.wrap = false
    vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
    vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })

    -- Bind both windows so that they scroll together
    vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
  end

  local au_opts = { pattern = 'MiniGitCommandSplit', callback = align_blame }
  vim.api.nvim_create_autocmd('User', au_opts)
  vim.api.nvim_create_user_command('Gblame', function()
    vim.cmd('vertical Git blame -- %')
  end, {})
end)

now(function()
  local diff = require('mini.diff')
  diff.setup({
    source = { diff.gen_source.git(), diff.gen_source.save() },
    view = {
      style = 'number'
    },
  })
end)

later(function()
  add({
    source = "FabijanZulj/blame.nvim",
  })
  require('blame').setup({})
end)

later_on('VimEnter', function()
  add({
    source = 'tanvirtin/vgit.nvim',
    depends = {
      'nvim-lua/plenary.nvim',
    }
  })
  require("vgit").setup({
    settings = {
      live_blame = {
        enabled = false,
      },
    },
  })
end)

-- using now instead of later so the gitv shell alias works
now(function()
  add({
    source = 'isakbm/gitgraph.nvim',
    depends = {
      'sindrets/diffview.nvim',
    }
  })

  require("diffview").setup()

  local gitgraph = require('gitgraph')
  gitgraph.setup({
    symbols = {
      merge_commit = '',
      commit = '',
      merge_commit_end = '',
      commit_end = '',

      -- Advanced symbols
      GVER = '',
      GHOR = '',
      GCLD = '',
      GCRD = '╭',
      GCLU = '',
      GCRU = '',
      GLRU = '',
      GLRD = '',
      GLUD = '',
      GRUD = '',
      GFORKU = '',
      GFORKD = '',
      GRUDCD = '',
      GRUDCU = '',
      GLUDCD = '',
      GLUDCU = '',
      GLRDCL = '',
      GLRDCR = '',
      GLRUCL = '',
      GLRUCR = '',
    },
    hooks = {
      -- Check diff of a commit
      on_select_commit = function(commit)
        vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
        vim.cmd(':DiffviewOpen ' .. commit.hash .. '^!')
      end,
      -- Check diff from commit a -> commit b
      on_select_range_commit = function(from, to)
        vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
        vim.cmd(':DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
      end,
    },
  })

  vim.api.nvim_create_user_command("Flog", function()
    gitgraph.draw({}, { all = true, max_count = 5000 })
  end, {
    desc = 'Gitgraph - Draw',
  })
end)

-- DAP
later(function()
  add({
    source = 'rcarriga/nvim-dap-ui',
    depends = {
      'mfussenegger/nvim-dap',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
    }
  })
  add({
    source = 'leoluz/nvim-dap-go',
  })
  add({
    source = 'mfussenegger/nvim-dap-python'
  })
  require('mason-nvim-dap').setup({
    automatic_installation = true,
  })

  require("nvim-dap-virtual-text").setup({})
  require('dap-go').setup()
  require("dap-python").setup("python3")

  local dap, dapui = require("dap"), require("dapui")
  dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    controls = {
      icons = {
        pause = "⏸",
        play = "▶",
        step_into = "⏎",
        step_over = "⏭",
        step_out = "⏮",
        step_back = "b",
        run_last = "▶▶",
        terminate = "⏹",
        disconnect = "⏏",
      },
    },
  })

  -- dap.listeners.after.event_initialized["dapui_config"]=function()
  --   dapui.open()
  -- end
  -- dap.listeners.before.event_terminated["dapui_config"]=function()
  --   dapui.close()
  -- end
  -- dap.listeners.before.event_exited["dapui_config"]=function()
  --   dapui.close()
  -- end

  -- open Dap UI automatically when debug starts (e.g. after <F5>)
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end

  -- close Dap UI with :DapCloseUI
  vim.api.nvim_create_user_command("DapCloseUI", function()
    require("dapui").close()
  end, {})

  -- use <Alt-e> to eval expressions
  keymap({ 'n', 'v' }, '<M-e>', function() require('dapui').eval() end)

  -- vim.api.nvim_create_autocmd("ColorScheme", {
  --   pattern = "*",
  --   desc = "Prevent colorscheme clearing self-defined DAP marker colors",
  --   callback = function()
  --     -- Reuse current SignColumn background (except for DapStoppedLine)
  --     local sign_column_hl = vim.api.nvim_get_hl(0, { name = 'SignColumn' })
  --     -- if bg or ctermbg aren't found, use bg = 'bg' (which means current Normal) and ctermbg = 'Black'
  --     -- convert to 6 digit hex value starting with #
  --     local sign_column_bg = (sign_column_hl.bg ~= nil) and ('#%06x'):format(sign_column_hl.bg) or 'bg'
  --     local sign_column_ctermbg = (sign_column_hl.ctermbg ~= nil) and sign_column_hl.ctermbg or 'Black'
  --
  --     vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00ff00', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
  --     vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d', ctermbg = 'Green' })
  --     vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#c23127', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
  --     vim.api.nvim_set_hl(0, 'DapBreakpointRejected',
  --       { fg = '#888ca6', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
  --     vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
  --   end
  -- })
  --
  -- vim.fn.sign_define('DapBreakpoint',
  --   { text = '⏹', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  -- vim.fn.sign_define('DapBreakpointCondition',
  --   { text = 'ﳁ', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  -- vim.fn.sign_define('DapBreakpointRejected',
  --   { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  -- vim.fn.sign_define('DapLogPoint', { text = '🗎', texthl = 'DapLogPoint', linehl = 'DapLogPoint', numhl = 'DapLogPoint' })
  -- vim.fn.sign_define('DapStopped', { text = '⏵', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })
  --
  -- -- reload current color scheme to pick up colors override if it was set up in a lazy plugin definition fashion
  -- vim.cmd.colorscheme(vim.g.colors_name)

  keymap('n', '<F5>', dap.continue)
  keymap('n', '<F10>', dap.step_over)
  keymap('n', '<F11>', dap.step_into)
  keymap('n', '<F12>', dap.step_out)

  keymap('n', '<leader>b', dap.toggle_breakpoint)
  keymap('n', '<Leader>B', dap.set_breakpoint)
  keymap('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
  keymap('n', '<Leader>dr', dap.repl.open)
  keymap('n', '<Leader>dl', dap.run_last)

  keymap('n', '<Leader>w', dapui.open)
  keymap('n', '<Leader>W', dapui.close)
end)

later(function()
  add({
    source = 'johmsalas/text-case.nvim'
  })
  require('textcase').setup({
    substitude_command_name = 'S',
  })
end)

later(function()
  require('mini.files').setup({
    -- Module mappings created only inside explorer.
    -- Use `''` (empty string) to not create one.
    mappings = {
      close       = '<Esc>',
      go_in       = '<Right>',
      go_in_plus  = 'L',
      go_out      = '<Left>',
      go_out_plus = 'H',
      mark_goto   = "'",
      mark_set    = 'm',
      reset       = '<BS>',
      reveal_cwd  = '@',
      show_help   = 'g?',
      synchronize = '=',
      trim_left   = '<',
      trim_right  = '>',
    },
  })

  local show_dotfiles = true

  local function filter_show(_) return true end
  local function filter_hide(fs_entry)
    return not vim.startswith(fs_entry.name, '.')
  end

  local function toggle_dotfiles()
    show_dotfiles = not show_dotfiles
    local new_filter = show_dotfiles and filter_show or filter_hide
    MiniFiles.refresh({ content = { filter = new_filter } })
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
      local buf_id = args.data.buf_id
      -- Tweak left-hand side of mapping to your liking
      keymap('n', 'g.', toggle_dotfiles, { buffer = buf_id })
    end,
  })

  local function map_split(buf_id, lhs, direction)
    local function rhs()
      -- Make new window and set it as target
      local cur_target = MiniFiles.get_explorer_state().target_window
      local path = (MiniFiles.get_fs_entry() or {}).path
      if path == nil then path = '' end
      local new_target = vim.api.nvim_win_call(cur_target, function()
        vim.cmd(direction .. ' split ' .. path)
        return vim.api.nvim_get_current_win()
      end)

      MiniFiles.set_target_window(new_target)
    end

    -- Adding `desc` will result into `show_help` entries
    local desc = 'Split ' .. direction
    keymap('n', lhs, rhs, { buffer = buf_id, desc = desc })
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
      local buf_id = args.data.buf_id
      map_split(buf_id, '<C-s>', 'belowright horizontal')
      map_split(buf_id, '<C-v>', 'belowright vertical')
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesActionRename",
    callback = function(event)
      Snacks.rename.on_rename_file(event.data.from, event.data.to)
    end,
  })

  keymap('n', '<C-o>', MiniFiles.open, {})
end)

later(function() require('mini.pairs').setup({ modes = { insert = true, command = true, terminal = true } }) end)
later(function() require('mini.splitjoin').setup({ mappings = { toggle = 'sj' } }) end)

later(function()
  require('mini.surround').setup()
  keymap('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
end)

later(function() require('mini.bracketed').setup() end)
later(function() require('mini.jump').setup() end)
later(function() require('mini.jump2d').setup() end)
later(function() require('mini.sessions').setup() end)
later(function() require('mini.visits').setup() end)
later(function() require('mini.fuzzy').setup() end)
later(function() require('mini.cursorword').setup() end)

later(function()
  local hipatterns = require('mini.hipatterns')
  -- local hi_words = MiniExtra.gen_highlighter.words
  local function hi_words(words, group, extmark_opts)
    local pattern = vim.tbl_map(function(x)
      return '%f[%w]' .. vim.pesc(x) .. '%f[^' .. x:sub(-1) .. ']'
    end, words)
    return { pattern = pattern, group = group, extmark_opts = extmark_opts }
  end
  local function add_suffix(lst, suffix)
    return vim.tbl_map(function(x)
      return x .. suffix
    end, lst)
  end
  hipatterns.setup({
    highlighters = {
      fixme = hi_words(add_suffix({ 'FIXME', 'Fixme', 'fixme' }, ':'), 'MiniHipatternsFixme'),
      hack = hi_words(add_suffix({ 'HACK', 'Hack', 'hack' }, ':'), 'MiniHipatternsHack'),
      todo = hi_words(add_suffix({ 'TODO', 'Todo', 'todo' }, ':'), 'MiniHipatternsTodo'),
      note = hi_words(add_suffix({ 'NOTE', 'Note', 'note' }, ':'), 'MiniHipatternsNote'),

      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function()
  require('mini.trailspace').setup()

  local trim_space_on_save = true
  local function toggle_trim_space_on_save()
    trim_space_on_save = not trim_space_on_save
  end

  -- Create a command :ToggleTrimSpaceOnSave that calls the toggle function
  vim.api.nvim_create_user_command('ToggleTrimSpaceOnSave', toggle_trim_space_on_save, {})

  -- trim spaces on save
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    -- buffer = 0, -- if 0 doesn't work do vim.api.nvim_get_current_buf()
    callback = function(_)
      if not trim_space_on_save then
        return
      end
      MiniTrailspace.trim()
      MiniTrailspace.trim_last_lines()
    end
  })
end)

-- Language specific

-- Golang
-- later(function ()
--   add({
--     source = "yanskun/gotests.nvim"
--   })
--   require('gotests').setup()
-- end)

-- Markdown rendering
later(function()
  add({
    -- source = "OXY2DEV/markview.nvim"
    source = 'MeanderingProgrammer/render-markdown.nvim',
  })
  require('render-markdown').setup({})

  add({
    source = "wallpants/github-preview.nvim"
  })
  require("github-preview").setup({
    single_file = true,
  })

  add({
    source = 'Kicamon/markdown-table-mode.nvim',
  })
  require('markdown-table-mode').setup({
    filetype = {
      '*.md',
    },
    options = {
      insert = true,              -- when typing "|"
      insert_leave = true,        -- when leaving insert
      pad_separator_line = false, -- add space in separator line
      alig_style = 'default',     -- default, left, center, right
    },
  })
end)

-- Buffer and window management

later(function() require('mini.bufremove').setup() end)

later(function()
  local map = require('mini.map')
  map.setup({
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
    },
    symbols = {
      encode = map.gen_encode_symbols.dot('3x2')
    }
  })
end)

-- Yank/paste buffers
later(function()
  local function pasteWindow(direction)
    if vim.g.yanked_buffer then
      local temp_buffer = nil
      if direction == 'edit' then
        temp_buffer = vim.fn.bufnr('%')
      end

      vim.cmd(direction .. " +buffer" .. vim.g.yanked_buffer)

      if direction == 'edit' then
        vim.g.yanked_buffer = temp_buffer
      end
    end
  end

  keymap("n", "<leader>wy", function()
    vim.g.yanked_buffer = vim.fn.bufnr('%')
  end, { silent = true })

  keymap("n", "<leader>wd", function()
    vim.g.yanked_buffer = vim.fn.bufnr('%')
    vim.cmd("q")
  end, { silent = true })

  keymap("n", "<leader>wp", function()
    pasteWindow('edit')
  end, { silent = true })

  keymap("n", "<leader>ws", function()
    pasteWindow('split')
  end, { silent = true })

  keymap("n", "<leader>wv", function()
    pasteWindow('vsplit')
  end, { silent = true })

  keymap("n", "<leader>wt", function()
    pasteWindow('tabnew')
  end, { silent = true })
end)

later(function()
  add({
    source = 'chrishrb/gx.nvim',
    depends = {
      'nvim-lua/plenary.nvim',
    }
  })

  require("gx").setup({
    handlers = {
      plugin = true,
      github = true,
      brewfile = true,
      package_json = true,
      search = true,
      go = true,
    }
  })

  keymap({ "n", "x" }, "gx", "<cmd>Browse<cr>", {})
end)
