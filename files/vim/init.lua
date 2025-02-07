--- safe_require()
--- Try calling `require` for the given module.
--- If unsuccessful, print the error message using `vim.notify()`
---
---@param module string a name of the module to `require`
---@return unknown module from `pcall` if the call was successful, otherwise nil
local function safe_require(module)
  local status, loaded_module = pcall(require, module)
  if status then
    return loaded_module
  end
  vim.notify("Error loading the module: " .. module)
  return nil
end

--- Load vim configs
vim.cmd('source ~/.vimrc')

--- Treesitter configs
safe_require('nvim-treesitter.configs').setup {
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  }
}

safe_require("ibl").setup{
  scope = { enabled = false },
}

-- safe_require("sg").setup()
