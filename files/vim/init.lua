vim.cmd('source ~/.vimrc')

require'nvim-treesitter.configs'.setup {
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  }
}
