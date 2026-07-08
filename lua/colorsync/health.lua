--- Ref: https://neo.vimhelp.org/health.txt.html#health-dev
local M = {}

--- utilities

--- Check if a file exists
--- @param path string
--- @return boolean exists
local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

--- Check if a file exists and provide vim.health logging
---
--- @param filename string Pretty filename
--- @param filepath string Full path of the file with filename
--- @return nill
local function check_file(filename, filepath)
  vim.health.start("colorsync." .. filename)
  if file_exists(filepath) then
    vim.health.ok(filename .. " -> " .. filepath)
  else
    vim.health.error(filename .. " file was not found: " .. filepath)
  end
end

--- Check if autocommand exists
local function has_autocmd(event, group)
  local res = vim.api.nvim_get_autocmds({
    event = event,
    group = group,
  })
  return res ~= nil and #res > 0, res
end

--- Health checks

--- Check statefile
local function check_statefile()
  local filepath = vim.fn.stdpath("state") .. "/colorscheme"
  check_file("statefile", filepath)
end

--- Check wezterm file
local function check_wezterm_statefile()
  local colorsync = require("colorsync")
  check_file("wezterm_file", colorsync.WEZTERM_CONFIG_DIR)
end

--- Check autocmd
local function check_autocmd()
  colorsync = require("colorsync")
  vim.health.start("colorsync.autocmd")
  local msg = ""

  if not has_autocmd("ColorScheme", colorsync.AU_GROUP_NAME) then
    msg = msg .. "ColorScheme autocmd is missing\n"
  end
  if not has_autocmd("VimEnter", colorsync.AU_GROUP_NAME) then
    msg = msg .. "ColorScheme autocmd is missing\n"
  end
  if msg == "" then
    vim.health.ok("autocmd")
  else
    vim.health.error(msg)
  end
end


function M.check()
  check_statefile()
  check_wezterm_statefile()
  check_autocmd()
end

return M
