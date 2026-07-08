-- Synchronise wezterm's theme and NVIM's colorscheme with the `:colorschme`
-- cmd.
-- Wezterm's config file needs modification, this plugin relies on state files
-- on your local filesystem.
--
-- Wezterm's colorscheme is stored next to `$WEZTERM_CONFIG_FILE` as `colorscheme`.
-- NVIM's colorscheme is stored under `stdpath("state")/colorscheme`
--
-- The theme mapping is not-complete and manually maintained for now.
--
-- BUG: the `bg` light/dark value is not properly update on NVIM side after
-- switching from a light theme. This might be due to some colorscheme
-- shenanigans.
--
-- Disclaimer: Thanks for all the various blog posts, comments that inspired this
local M = {}

local UI = require("colorsync.ui")
local CMD = require("colorsync.command")

-- colorscheme file used by wezterm
M.WEZTERM_CONFIG_DIR = vim.fn.expand("$WEZTERM_CONFIG_DIR") .. "/colorscheme"
M.AU_GROUP_NAME = "wezterm_colorscheme"

DEFAULT_MAP_COLORSCHEMES_NVIM_TO_WEZTERM = {
  -- <nvim name> = <wezterm name>
  ["default"] = "NvimDark",
  ["tokyonight-day"] = "Tokyo Night Day",
  ["tokyonight-storm"] = "Tokyo Night Storm",
  ["tokyonight-night"] = "Tokyo Night",
  ["catppuccin-frappe"] = "Catppuccin Frappe",
  ["catppuccin-latte"] = "Catppuccin Latte",
  ["catppuccin-macchiato"] = "Catppuccin Macchiato",
  ["catppuccin-mocha"] = "Catppuccin Mocha",
  ["gruvbox"] = "GruvboxDark",
  ["rose-pine"] = "rose-pine",
  ["rose-pine-main"] = "rose-pine",
  ["rose-pine-dawn"] = "rose-pine-dawn",
  ["rose-pine-moon"] = "rose-pine-moon",
  ["kanagawa"] = "Kanagawa (Gogh)",
  -- add more color schemes here ...
}

local function write_colorscheme_file(filename, colorscheme)
  assert(type(filename) == "string")
  local file = io.open(filename, "w")
  assert(file)
  file:write(colorscheme)
  file:close()
end


local State = { FAILED = "0", OK = "1", INIT_FILE_DOES_NOT_EXIST = "2" }

---@return State
local check_setup = function()
  local nvim_filename = vim.fn.stdpath("state") .. "/colorscheme"
  assert(type(nvim_filename) == "string", "Unexpected error: Could not derive state filename")
  -- I keep the file handle here, so it can be closed.
  local file_handle = io.open(nvim_filename, "r")
  local file_can_be_read = file_handle ~= nil
  if not file_can_be_read then
    -- log.error("IOError: Could not open file for reading" .. nvim_filename)
    M.notify("Error: Could not open file for reading" .. nvim_filename, vim.log.levels.ERROR)
    return State.INIT_FILE_DOES_NOT_EXIST
  end
  file_handle.close()
  return State.OK
end

--- Set up notify on module level, use notify.nvim or default logger
---
--- @param opts table | nil
local function notification_provider(opts)
  local ok, notify = pcall(require, "notify")
  -- use vimlog, no notify dependency
  if not ok then
    error("Not implemented. Use notify.nvim as a dependency.", 2)
  end
  -- plugin default provided opts
  if opts == nil then
    notify.setup({
      timeout = 500,
      render = 'compact',
    })
    -- user provided opts
  else
    notify.setup(opts)
  end

  M.notify = notify
end

-- @param opts table | nil
-- Options
--   opts.notify: (table|false|nil)
--     If a table, it configures the optional notify.nvim integration:
--       { timeout = number, render = string, ... }
--     If false/nil, the plugin falls back to vim.log (no notify.nvim setup).
--
--   opts.scheme_map: (function|table|nil)
--     Provides extra/overriding entries for the NVim->Wezterm scheme mapping.
--     Expected shape (when table):
--       { ["nvim-scheme-name"] = "wezterm-name", ... }
--     If a function, it will be called and its returned table will be merged
--     into the defaults (user values overwrite).}
function M.setup(opts)
  -- notifications or logging
  local notify_opts = (opts and opts.notify) or nil
  notification_provider(notify_opts)

  -- scheme map
  local scheme_opts = (opts and opts.scheme_map) or {}
  M.scheme_map = vim.tbl_deep_extend(
    "force",
    vim.deepcopy(DEFAULT_MAP_COLORSCHEMES_NVIM_TO_WEZTERM),
    scheme_opts
  )
  -- register command
  CMD.setup({
    ShowSchemeMap = function()
      UI.open_float_buf(
        UI.table_to_lines(M.scheme_map),
        "Colorscheme map"
      )
    end,
  })

  -- auto groups
  local au_group = vim.api.nvim_create_augroup(M.AU_GROUP_NAME, { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = au_group,
    callback = function()
      -- runs after startup; colorscheme likely set
      local current_color_scheme_name = vim.g.colors_name
      local initial_state = check_setup()
      if initial_state == State.INIT_FILE_DOES_NOT_EXIST then
        M.notify("Your initial colorscheme file does not exist.", vim.log.levels.ERROR)
        local set_colorscheme = false
        if current_color_scheme == nil then
          current_color_scheme_name = "default"
          M.notify("Your initial colorscheme file does not exist.", vim.log.levels.INFO)
        else
          M.notify("Your initial colorscheme file does not exist.", vim.log.levels.DEBUG)
        end
        local ans = vim.fn.input("Should we set current color scheme:" ..
          current_color_scheme_name .. " ? (y/n): ")
        ans = ans:lower():gsub("^%s*(.-)%s*$", "%1") -- trim
        if ans == "y" then
          set_colorscheme = true
        else
          M.notify("Your initial colorscheme file does not exist.", vim.log.levels.DEBUG)
          return
        end
        if set_colorscheme then
          -- try resolve colorscheme
          local mapped_colorscheme = M.scheme_map[current_color_scheme_name]
          if not mapped_colorscheme then
            M.notify("Could not resolve colorscheme: " .. current_color_scheme_name, vim.log.levels.ERROR)
            return
          end
          local filename = vim.fn.stdpath("state") .. "/colorscheme"
          write_colorscheme_file(filename, current_color_scheme_name)
          write_colorscheme_file(M.WEZTERM_CONFIG_DIR, mapped_colorscheme)
          M.notify("Setting WezTerm color scheme to " .. mapped_colorscheme, vim.log.levels.INFO)
        end
      elseif initial_state == State.OK then
        local nvim_filename = vim.fn.stdpath("state") .. "/colorscheme"
        assert(type(nvim_filename) == "string")
        local file = io.open(nvim_filename, "r")
        assert(file)
        local colorscheme = file:read("*l")
        M.notify(colorscheme, vim.log.levels.INFO)
        file:close()
        vim.cmd("silent colorscheme " .. colorscheme)
      end
    end,
  })


  vim.api.nvim_create_autocmd("ColorScheme", {
    group = au_group,
    callback = function(args)
      local current_color_scheme = vim.g.colors_name
      M.notify("ColorScheme: current_color_scheme" .. current_color_scheme, vim.log.levels.DEBUG)
      local new_colorscheme = args.match
      local colorscheme = M.scheme_map[args.match]
      if not colorscheme then
        return
      end
      -- Write the colorscheme to a file
      local filename = vim.fn.stdpath("state") .. "/colorscheme"
      write_colorscheme_file(filename, new_colorscheme)
      -- Write the translated colorscheme to a file
      write_colorscheme_file(M.WEZTERM_CONFIG_DIR, colorscheme)
      M.notify("Setting WezTerm color scheme to " .. colorscheme, vim.log.levels.INFO)
    end,
  })
end

return M
