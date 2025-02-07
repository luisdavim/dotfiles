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

-- Safely execute immediately

-- Vim setup
now(function()
  vim.keymap.set('v', '<Tab>', '>gv', {})
  vim.keymap.set('v', '<S-Tab>', '<gv', {})
  vim.keymap.set('n', '<Tab>', '>>_', {})
  vim.keymap.set('n', '<S-Tab>', '<<_', {})
  vim.keymap.set('i', '<S-Tab>', '<C-D>', {})

  vim.g.mapleader = "\\"
  vim.g.nobackup = true
  vim.g.nowritebackup = true
  vim.g.noswapfile = true
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
  set.regexpengine = 1
  set.ttyfast = true
  set.lazyredraw = true
  set.ttimeout = true
  set.ttimeoutlen = 50
  set.updatetime = 300

  set.number = true
  set.incsearch = true
  set.hlsearch = true
  set.infercase = true
  set.ignorecase = true
  set.smartcase = true

  -- Automatically Split help Buffers to the left
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    command = "wincmd H"
  })

  -- Automatically restore cursor position
  vim.api.nvim_create_autocmd('BufRead', {
    callback = function(opts)
      vim.api.nvim_create_autocmd('BufWinEnter', {
        once = true,
        buffer = opts.buf,
        callback = function()
          local ft = vim.bo[opts.buf].filetype
          local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
          if
              not (ft:match('commit') and ft:match('rebase'))
              and last_known_line > 1
              and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
          then
            vim.api.nvim_feedkeys([[g`"]], 'nx', false)
          end
        end,
      })
    end,
  })

  -- file type detection
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
now(function()
  require('mini.completion').setup({
    window = {
      info = { height = 25, width = 80, border = 'single' },
      signature = { height = 25, width = 60, border = 'single' },
    },
  })
end)
now(function() require('mini.starter').setup() end)

-- LSP and DAP related config
now(function()
  add({
    source = 'nvim-lua/plenary.nvim'
  })
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

  -- DAP
  -- add({
  --   source = 'mfussenegger/nvim-dap',
  --   depends = {
  --     'rcarriga/nvim-dap-ui',
  --     'nvim-neotest/nvim-nio',
  --     'jay-babu/mason-nvim-dap.nvim',
  --   }
  -- })
  -- require('dap')
  -- require('dapui').setup()
  -- require('mason-nvim-dap').setup()
  -- require('dap.ext.vscode').load_launchjs(nil, {})

  -- LSP
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

  require('mason-lspconfig').setup_handlers({
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
      require('lspconfig')[server_name].setup {}
    end,
    -- Next, you can provide a dedicated handler for specific servers.
    -- For example, a handler override for the `rust_analyzer`:
    -- ['rust_analyzer'] = function ()
    --   require('rust-tools').setup {}
    -- end
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
      local opts = { buffer = event.buf }

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
          title = 'rename'
        }
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, ropts)
        local fmt = '<cmd>lua Rename.dorename(%d)<CR>'
        local fmtc = '<cmd>lua vim.api.nvim_win_close(%d, true)<CR>'

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { cword })
        vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', string.format(fmt, win), { silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', string.format(fmtc, win), { silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'i', '<Esc>', string.format(fmtc, win), { silent = true })
      end

      _G.Rename = {
        rename = rename,
        dorename = dorename
      }

      vim.keymap.set('n', '<leader>rn', '<cmd>lua Rename.rename()<CR>', { silent = true })
      vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

      vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
      vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
      vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
      vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
      vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
      vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
      vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)

      -- format on save
      vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
        -- buffer = 0, -- if 0 doesn't work do vim.api.nvim_get_current_buf()
        callback = function(o)
          vim.lsp.buf.format({ async = false })
        end
      })

      MiniIcons.tweak_lsp_kind()
    end,
  })
end)

now(function()
  add({
    source = 'ahmedkhalf/project.nvim'
  })
  require('project_nvim').setup()
end)

-- Safely execute later
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

  vim.keymap.set('n', '<C-p>', '<cmd>Pick files<cr>', {})
  vim.keymap.set('n', '<C-f>', '<cmd>Pick grep_live<cr>', {})
  vim.keymap.set('n', '<C-_>', '<cmd>Pick explorer<cr>', {})
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

  local filter_show = function(fs_entry) return true end
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
      vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
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
    vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
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

  vim.keymap.set('n', '<C-o>', '<cmd>lua MiniFiles.open()<cr>', {})
end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.splitjoin').setup() end)
later(function() require('mini.snippets').setup() end)
later(function()
  require('mini.surround').setup()
  vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
end)
later(function()
  require('mini.basics').setup({
    basic = true,
    extra_ui = true,
  })
end)
later(function() require('mini.bracketed').setup() end)
later(function() require('mini.bufremove').setup() end)
later(function() require('mini.clue').setup() end)
later(function() require('mini.diff').setup() end)
later(function() require('mini.extra').setup() end)
later(function() require('mini.git').setup() end)
later(function() require('mini.jump').setup() end)
later(function() require('mini.jump2d').setup() end)
later(function() require('mini.misc').setup() end)
later(function() require('mini.sessions').setup() end)
later(function() require('mini.visits').setup() end)
later(function() require('mini.fuzzy').setup() end)
-- later(function() require('mini.animate').setup() end)
-- later(function() require('mini.base16').setup() end)
-- later(function() require('mini.colors').setup() end)
-- later(function() require('mini.hues').setup() end)
later(function() require('mini.cursorword').setup() end)
later(function() require('mini.hipatterns').setup() end)
later(function() require('mini.indentscope').setup() end)
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
later(function()
  require('mini.trailspace').setup()

  -- trim spaces on save
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    -- buffer = 0, -- if 0 doesn't work do vim.api.nvim_get_current_buf()
    callback = function(opts)
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

later(function()
  add({
    source = 'lukas-reineke/indent-blankline.nvim',
  })

  require("ibl").setup {
    scope = { enabled = false },
  }
end)
