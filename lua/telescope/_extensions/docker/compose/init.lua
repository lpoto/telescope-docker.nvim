local util = require "telescope._extensions.docker.util"
local setup = require "telescope._extensions.docker.setup"

local M = {}

function M.select_compose_file(file)
  local cmd = "docker-compose -f " .. file .. " "

  local suffix = vim.fn.input(cmd)
  if not suffix or suffix:len() == 0 then
    util.info "Invalid docker compose command"
    return
  end

  cmd = cmd .. suffix

  local init_term = setup.get_option "init_term"
  local ok, e = pcall(util.open_in_shell, cmd, init_term)
  if not ok then
    util.warn(e)
    return
  end
end

return M
