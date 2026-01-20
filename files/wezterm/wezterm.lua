-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

local function getPah(str, sep)
  sep = sep or '/'
  return str:match("(.*" .. sep .. ")")
end

local function download(url, file)
  -- Check if the file exists
  local f = io.open(file, "r")
  if f == nil then
    -- File doesn't exist, let's download it
    wezterm.log_info("Terminfo missing. Downloading to " .. file)

    -- Ensure the directory exists
    os.execute("mkdir -p " .. getPah(file))

    -- Download the file using curl
    local success = os.execute("curl -fsSL " .. url .. " -o " .. file)

    if success then
      wezterm.log_info("file downloaded successfully.")
      return true
    else
      wezterm.log_error("Failed to download file.")
      return false
    end
  else
    f:close()
  end
  return false
end

-- Shell integration
local integration_script = os.getenv("HOME") .. "/.local/bin/wezterm.sh"
local integration_script_url =
"https://raw.githubusercontent.com/wezterm/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh"

if download(integration_script_url, integration_script) then
  os.execute("chmod +x " .. integration_script)
end

-- Terminfo
-- local terminfo_dir = os.getenv("HOME") .. "/.local/share/terminfo/"
-- local terminfo_file = terminfo_dir .. "wezterm.terminfo"
-- local terminfo_url = "https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo"
--
-- download(terminfo_url, terminfo_file)
--
-- config.set_environment_variables = {
--   TERMINFO_DIRS = terminfo_dir,
--   TERMINFO = terminfo_dir,
--   WSLENV = 'TERMINFO_DIRS',
-- }
config.term = 'wezterm'

-- Font
config.font_size = 14
config.font = wezterm.font({
  family = 'JetBrainsMono Nerd Font Mono',
  weight = "Medium",
})

-- Mouse
config.hide_mouse_cursor_when_typing = true

-- Window
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'

return config
