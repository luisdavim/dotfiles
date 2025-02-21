-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps'
require('mini.deps').setup({ path = { package = path_package } })

-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local keymap = vim.keymap.set

-- Safely execute immediately

-- Vim setup
now(function()
  -- indent using tab
  keymap('v', '<Tab>', '>gv', {})
  keymap('v', '<S-Tab>', '<gv', {})
  keymap('n', '<Tab>', '>>_', {})
  keymap('n', '<S-Tab>', '<<_', {})
  keymap('i', '<S-Tab>', '<C-D>', {})

  -- clear search highlight
  keymap('n', '<C-L>', '<cmd>noh<CR>', { noremap = true, silent = true })

  vim.g.mapleader = "\\"
  vim.g.fileformats = "unix,dos,mac"

  local set = vim.opt -- set options

  set.encoding = "utf-8"
  set.clipboard = "unnamed"
  set.tabstop = 2
  set.softtabstop = 2
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
    },
    pattern = {
      ['.*/etc/nginx/.*'] = { 'nginx', { priority = 10 } },
      ['.*/usr/local/nginx/conf/.*'] = { 'nginx', { priority = 10 } },
      [".*/%.kube/config"] = "yaml",
      [".*/%.kube/config%.d/.*"] = "yaml",
      ['.*/charts?/.*/templates/.*%.ya?ml'] = 'helm',
      ['.*/templates/.*%.ya?ml'] = 'helm',
      ['.*/templates/.*%.tpl'] = 'helm',
      ['.*/templates/.*%.txt'] = 'helm',
      ['*/helmfile.*%.ya?ml'] = 'helm'
    },
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "helm",
    callback = function()
      vim.opt_local.commentstring = "{{/* %s */}}"
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
  vim.cmd('colorscheme github_dark_high_contrast')
end)

now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify()
end)

now(function() require('mini.icons').setup() end)
now(function() require('mini.tabline').setup() end)
now(function() require('mini.statusline').setup() end)

now(function() require('mini.starter').setup() end)

now(function()
  local misc = require('mini.misc')
  misc.setup({ make_global = { "put", "put_text" } })
  misc.setup_restore_cursor()
end)

now(function()
  add({
    source = 'ahmedkhalf/project.nvim'
  })
  require('project_nvim').setup()
end)

-- Auto-completion

-- Using mini.completion
-- now(function()
--   require('mini.completion').setup({
--     window = {
--       info = { height = 25, width = 80, border = 'single' },
--       signature = { height = 25, width = 60, border = 'single' },
--     },
--   })
--   -- Override completeopt
--   vim.opt.completeopt = 'longest,menuone'
--   -- Use fuzzy matching for built-in completion
--   if vim.fn.has "nvim-0.11" == 1 then
--     vim.opt.completeopt:append "fuzzy"
--   end
--
--   -- Disable auto-completion in snacks inputs
--   vim.api.nvim_create_autocmd("FileType", {
--     pattern = "snacks_*",
--     command = "lua vim.b.minicompletion_disable = true"
--   })
-- end)

-- Using nvim-cmp
now(function()
  add({
    source = 'hrsh7th/nvim-cmp',
    depends = {
      'neovim/nvim-lspconfig',
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lsp-document-symbol',
    }
  })
  -- Set up nvim-cmp.
  local cmp = require('cmp')
  local lspkind = require('lspkind')

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

        -- For `mini.snippets` users:
        -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        -- insert({ body = args.body }) -- Insert at cursor
        -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
        -- require("cmp.config").set_onetime({ sources = {} })
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    formatting = {
      expandable_indicator = true,
      format = lspkind.cmp_format({
        mode = "symbol_text",
        menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[Latex]",
          path = "[Path]"
        })
      }),
    },
    completion = {
      completeopt = 'menuone',
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'nvim_lsp_signature_help' },
      { name = 'path' },
      { name = 'emoji' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  --[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
 require("cmp_git").setup() ]] --

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'nvim_lsp_document_symbol' },
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })
end)

-- LSP config
now(function()
  -- Treesitter
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Use 'master' while monitoring updates in 'main'
    checkout = 'master',
    monitor = 'main',
    -- Perform action after every checkout
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  -- Possible to immediately execute code which depends on the added plugin
  require('nvim-treesitter.configs').setup({
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-context',
  })
  require('treesitter-context').setup()
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-refactor',
  })

  vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

  add({
    source = 'neovim/nvim-lspconfig',
    -- Supply dependencies near target plugin
    depends = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'folke/lazydev.nvim',
      -- 'jay-babu/mason-null-ls.nvim',
      -- 'nvimtools/none-ls.nvim',
    },
  })

  require('lazydev').setup()
  -- require('mason-null-ls').setup({
  --   handlers = {},
  -- })
  require('mason').setup()
  require("mason-lspconfig").setup({
    automatic_installation = true,
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
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), capabilities)
  require('mason-lspconfig').setup_handlers({
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
      }
    end,
    -- Next, you can provide a dedicated handler for specific servers.
    -- For example, a handler override for the `rust_analyzer`:
    -- ['rust_analyzer'] = function ()
    --   require('rust-tools').setup {}
    -- end
    ['gopls'] = function()
      require('lspconfig').gopls.setup {
        capabilities = capabilities,
        cmd = { "gopls", "-remote=auto" },
        filetypes = { "go", "gomod", "gowork", "gotmpl", "gohtmltmpl", "gotexttmpl" },
        root_dir = vim.fs.dirname(
          vim.fs.find({ 'go.mod', 'go.work', '.git' }, { upward = true })[1]
        ),
        settings = {
          gopls = {
            gofumpt = true,
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
      }
    end
  })

  add({
    source = 'fnune/codeactions-on-save.nvim',
  })
  add({
    source = 'dnlhc/glance.nvim',
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
      local opts = { buffer = event.buf }

      MiniIcons.tweak_lsp_kind()

      local id = vim.tbl_get(event, 'data', 'client_id')
      local client = id and vim.lsp.get_client_by_id(id)

      -- highlight symbol under cursor
      if client ~= nil and client.supports_method('textDocument/documentHighlight') then
        vim.b[event.buf].minicursorword_disable = true

        vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'MiniCursorword' })
        vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'MiniCursorword' })
        vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'MiniCursorword' })

        local group = vim.api.nvim_create_augroup('highlight_symbol', { clear = false })
        vim.api.nvim_clear_autocmds({ buffer = event.buf, group = group })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          group = group,
          buffer = event.buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          group = group,
          buffer = event.buf,
          callback = vim.lsp.buf.clear_references,
        })
      end

      -- LSP UI settings
      vim.diagnostic.config({
        virtual_text = false,
        float = {
          border = 'single',
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
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = 'single',
          width = math.floor(0.25 * vim.o.columns)
        })
      -- Signature help
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers['signature_help'], {
          border = 'single',
          width = math.floor(0.25 * vim.o.columns),
          close_events = { 'CursorMoved', 'BufHidden', 'WinLeave' },
        })

      -- Diagnostics
      -- Function to check if a floating dialog exists and if not
      -- then check for diagnostics under the cursor
      function OpenDiagnosticIfNoFloat()
        for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_config(winid).zindex then
            return
          end
        end
        vim.diagnostic.open_float(nil, {
          scope = 'line',
          border = 'single',
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
        command = "lua OpenDiagnosticIfNoFloat()",
        group = 'lsp_diagnostics_hold',
      })

      -- Inlay hints
      if client ~= nil and client.supports_method('textDocument/inlayHint') then
        local bufnr = event.buf
        vim.lsp.inlay_hint.enable(true, { bufnr })
        keymap('n', '<leader>H',
          function()
            if vim.lsp.inlay_hint.is_enabled() then
              vim.lsp.inlay_hint.enable(false, { bufnr })
            else
              vim.lsp.inlay_hint.enable(true, { bufnr })
            end
          end, opts)
      end

      require('glance').setup()

      -- Rename UI
      local function dorename(win)
        local new_name = vim.trim(vim.fn.getline('.'))
        vim.api.nvim_win_close(win, true)
        vim.lsp.buf.rename(new_name)
      end

      local function rename()
        local cword = vim.fn.expand('<cword>')
        local width = cword:len() + 5
        if width < 30 then width = 30 end
        local ropts = {
          relative = 'cursor',
          row = 0,
          col = 0,
          width = width,
          height = 1,
          style = 'minimal',
          border = 'single',
          title = 'Rename'
        }
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, ropts)
        local fmt = '<cmd>lua Rename.dorename(%d)<CR>'
        local fmtc = '<cmd>lua vim.api.nvim_win_close(%d, true)<CR>'
        vim.b[buf].minicompletion_disable = true

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { cword })
        vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', string.format(fmt, win), { silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', string.format(fmtc, win), { silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'i', '<Esc>', string.format(fmtc, win), { silent = true })
      end

      _G.Rename = {
        rename = rename,
        dorename = dorename
      }

      -- Format on save
      vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
        -- buffer = 0, -- if 0 doesn't work do vim.api.nvim_get_current_buf()
        callback = function(_)
          vim.lsp.buf.format({ async = false })
          -- vim.lsp.buf.code_action is async and may not resolve before the buffer is closed
          -- vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
          -- vim.lsp.buf.code_action { context = { only = { 'source.fixAll' } }, apply = true }
        end
      })
      vim.api.nvim_create_user_command('Format', function()
        vim.lsp.buf.format({ async = false })
      end, {})

      local cos = require('codeactions-on-save')
      cos.register({ '*.py', '*.go', '*.rb' }, { 'source.organizeImports' })
      cos.register({ '*.ts', '*.tsx' }, { 'source.organizeImports.biome', 'source.fixAll' })

      -- LSP keymaps
      keymap('n', '<leader>rn', function() Rename.rename() end, { silent = true })
      keymap('n', '<leader>ca', function() vim.lsp.buf.code_action() end, opts)
      keymap('n', '<leader>ld', function() MiniExtra.pickers.diagnostic() end, opts)

      keymap('n', 'K', function() vim.lsp.buf.hover() end, opts)
      -- keymap('n', 'gd', function() vim.lsp.buf.definition() end, opts)
      keymap('n', 'gd', function() MiniExtra.pickers.lsp({ scope = 'definition' }) end, opts)
      -- keymap('n', 'gD', function() vim.lsp.buf.declaration() end, opts)
      keymap('n', 'gD', function() MiniExtra.pickers.lsp({ scope = 'declaration' }) end, opts)
      -- keymap('n', 'gi', function() vim.lsp.buf.implementation() end, opts)
      keymap('n', 'gi', function() MiniExtra.pickers.lsp({ scope = 'implementation' }) end, opts)
      -- keymap('n', 'go', function() vim.lsp.buf.type_definition() end, opts)
      keymap('n', 'go', function() MiniExtra.pickers.lsp({ scope = 'type_definition' }) end, opts)
      -- keymap('n', 'gr', function() vim.lsp.buf.references() end, opts)
      keymap('n', 'gr', function() MiniExtra.pickers.lsp({ scope = 'references' }) end, opts)
      keymap('n', 'gs', function() vim.lsp.buf.signature_help() end, opts)
      keymap('n', 'gS', function() MiniExtra.pickers.lsp({ scope = 'document_symbol' }) end, opts)
      keymap('n', 'gf', function() MiniExtra.pickers.lsp({ scope = 'workspace_symbol' }) end, opts)
      keymap('n', ']g', function() vim.diagnostic.goto_next() end, opts)
      keymap('n', '[g', function() vim.diagnostic.goto_prev() end, opts)
      keymap({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
      keymap('n', '<F4>', function() vim.lsp.buf.code_action() end, opts)
      keymap('n', '<F2>', function() vim.lsp.buf.rename() end, opts)
    end,
  })
end)

-- TODO: pick some snacks
-- now(function()
--   add({
--     source ="folke/snacks.nvim",
--   })
--
--   local snacks =require('snacks')
--   snacks.setup({
--     animate = { enabled = false },
--     bigfile = { enabled = true },
--     bufdelete = { enabled = false },
--     dashboard = { enabled = false },
--     debug = { enabled = false },
--     dim = { enabled = false },
--     explorer = { enabled = true },
--     git = { enabled = false },
--     gitbrowse = { enabled = false },
--     image = { enabled = false },
--     indent = { enabled = false },
--     input = { enabled = true },
--     layout = { enabled = false },
--     lazygit = { enabled = false },
--     notifier = {
--       enabled = false,
--       timeout = 3000,
--     },
--     picker = { enabled = true },
--     quickfile = { enabled = true },
--     scope = { enabled = false },
--     scroll = { enabled = false },
--     statuscolumn = { enabled = true },
--     words = { enabled = true },
--     styles = {
--       notification = {
--         -- wo = { wrap = true } -- Wrap notifications
--       }
--     }
--   })
-- end)

-- Safely execute later

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

  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    desc = "Prevent colorscheme clearing self-defined DAP marker colors",
    callback = function()
      -- Reuse current SignColumn background (except for DapStoppedLine)
      local sign_column_hl = vim.api.nvim_get_hl(0, { name = 'SignColumn' })
      -- if bg or ctermbg aren't found, use bg = 'bg' (which means current Normal) and ctermbg = 'Black'
      -- convert to 6 digit hex value starting with #
      local sign_column_bg = (sign_column_hl.bg ~= nil) and ('#%06x'):format(sign_column_hl.bg) or 'bg'
      local sign_column_ctermbg = (sign_column_hl.ctermbg ~= nil) and sign_column_hl.ctermbg or 'Black'

      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00ff00', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d', ctermbg = 'Green' })
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#c23127', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      vim.api.nvim_set_hl(0, 'DapBreakpointRejected',
        { fg = '#888ca6', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
    end
  })

  vim.fn.sign_define('DapBreakpoint',
    { text = '⏹', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapBreakpointCondition',
    { text = 'ﳁ', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapBreakpointRejected',
    { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapLogPoint', { text = '🗎', texthl = 'DapLogPoint', linehl = 'DapLogPoint', numhl = 'DapLogPoint' })
  vim.fn.sign_define('DapStopped', { text = '⏵', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

  -- reload current color scheme to pick up colors override if it was set up in a lazy plugin definition fashion
  vim.cmd.colorscheme(vim.g.colors_name)

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
  require('mini.basics').setup({
    options = { extra_ui = true, win_borders = "single" },
    mappings = { basic = true, windows = true, move_with_alt = true },
  })
  vim.opt.completeopt = 'menuone'
end)

later(function() require('mini.extra').setup() end)

-- later(function() require('mini.animate').setup() end)
-- later(function() require('mini.base16').setup() end)
-- later(function() require('mini.colors').setup() end)
-- later(function() require('mini.hues').setup() end)

later(function() require('mini.ai').setup() end)
later(function() require('mini.align').setup() end)
later(function() require('mini.comment').setup() end)
later(function() require('mini.move').setup() end)
later(function() require('mini.operators').setup() end)

later(function()
  require('mini.pick').setup()

  -- vim.ui.select = MiniPick.ui_select
  vim.ui.select = function(items, opts, on_choice)
    local get_cursor_anchor = function() return vim.fn.screenrow() < 0.5 * vim.o.lines and "NW" or "SW" end
    local num_items = #items
    local max_height = math.floor(0.45 * vim.o.columns)
    local height = math.min(math.max(num_items, 1), max_height)
    local start_opts = {
      options = { content_from_bottom = get_cursor_anchor() == "SW" },
      window = {
        config = {
          relative = "cursor",
          anchor = get_cursor_anchor(),
          row = get_cursor_anchor() == "NW" and 1 or 0,
          col = 0,
          width = math.floor(0.45 * vim.o.columns),
          height = height,
        },
      },
    }
    return MiniPick.ui_select(items, opts, on_choice, start_opts)
  end

  keymap('n', '<C-p>', '<cmd>Pick files<cr>', {})
  keymap('n', '<C-f>', '<cmd>Pick grep_live<cr>', {})
  keymap('n', '<C-_>', '<cmd>Pick explorer<cr>', {})
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

  local filter_show = function(_) return true end
  local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, '.')
  end

  local toggle_dotfiles = function()
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

  local map_split = function(buf_id, lhs, direction)
    local rhs = function()
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
      -- Tweak keys to your liking
      map_split(buf_id, '<C-s>', 'belowright horizontal')
      map_split(buf_id, '<C-v>', 'belowright vertical')
    end,
  })

  keymap('n', '<C-o>', function() MiniFiles.open() end, {})
end)

later(function() require('mini.pairs').setup({ modes = { insert = true, command = true, terminal = true } }) end)
later(function() require('mini.splitjoin').setup() end)

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
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function()
  require('mini.trailspace').setup()

  -- trim spaces on save
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    -- buffer = 0, -- if 0 doesn't work do vim.api.nvim_get_current_buf()
    callback = function(_)
      MiniTrailspace.trim()
      MiniTrailspace.trim_last_lines()
    end
  })
end)

later(function()
  add({
    source = 'MeanderingProgrammer/render-markdown.nvim',
  })
  -- require('render-markdown').setup({})
end)

-- Indentation marks and scope
later(function() require('mini.indentscope').setup() end)

-- later(function()
--   add({
--     source = 'nvimdev/indentmini.nvim'
--   })
--   require("indentmini").setup()
--   -- Colors are applied automatically based on user-defined highlight groups.
--   -- There is no default value.
--   vim.cmd.highlight('IndentLine guifg=#999999')
--   -- Current indent line highlight
--   vim.cmd.highlight('IndentLineCurrent guifg=#123456')
-- end)

later(function()
  add({
    source = 'lukas-reineke/indent-blankline.nvim',
  })

  require("ibl").setup {
    scope = { enabled = false },
    indent = {
      char = "▎",
      tab_char = "▎",
    },
  }
end)

-- Git and diff

-- TODO: this doesn't seem to play nice with later
now(function()
  add({
    source = 'tanvirtin/vgit.nvim',
    depends = {
      'nvim-lua/plenary.nvim'
    }
  })
  require("vgit").setup()
end)

-- later(function()
--   add({
--     source = 'sindrets/diffview.nvim'
--   })
--   require("diffview").setup()
-- end)
--
later(function() require('mini.diff').setup() end)

later(function()
  require('mini.git').setup()

  local align_blame = function(au_data)
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
    pcall(vim.cmd('vertical Git blame -- %'))
  end, {})
end)
--
-- later(function()
--   add({
--     source = 'f-person/git-blame.nvim'
--   })
--   require('gitblame').setup {
--     enabled = false,
--     schedule_event = 'CursorHold',
--     clear_event = 'CursorHoldI',
--   }
-- end)

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
  local function PasteWindow(direction)
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
    PasteWindow('edit')
  end, { silent = true })

  keymap("n", "<leader>ws", function()
    PasteWindow('split')
  end, { silent = true })

  keymap("n", "<leader>wv", function()
    PasteWindow('vsplit')
  end, { silent = true })

  keymap("n", "<leader>wt", function()
    PasteWindow('tabnew')
  end, { silent = true })
end)

-- later(function()
--   local snippets = require('mini.snippets')
--   local gen_loader = snippets.gen_loader
--   snippets.setup({ snippets = { gen_loader.from_lang() } })
-- end)

later(function()
  local miniclue = require('mini.clue')
  --stylua: ignore
  miniclue.setup({
    clues = {
      -- TODO: add custom mappings clues
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = 'n', keys = '<Leader>' }, -- Leader triggers
      { mode = 'x', keys = '<Leader>' },
      { mode = 'n', keys = [[\]] },      -- mini.basics
      { mode = 'n', keys = '[' },        -- mini.bracketed
      { mode = 'n', keys = ']' },
      { mode = 'x', keys = '[' },
      { mode = 'x', keys = ']' },
      { mode = 'i', keys = '<C-x>' }, -- Built-in completion
      { mode = 'n', keys = 'g' },     -- `g` key
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" },     -- Marks
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' }, -- Registers
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' }, -- Window commands
      { mode = 'n', keys = 'z' },     -- `z` key
      { mode = 'x', keys = 'z' },
    },
    window = { config = { border = 'double' } },
  })
end)
