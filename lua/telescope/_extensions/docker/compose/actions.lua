local action_state = require "telescope.actions.state"
local util = require "telescope._extensions.docker.util"
local setup = require "telescope._extensions.docker.setup"
local telescope_actions = require "telescope.actions"

local actions = {}

local __select_compose_file

---Open a popup through which a docker compose file
---may be selected.
function actions.select_compose_file()
  local selection = action_state.get_selected_entry()
  local file = selection.value
  __select_compose_file(file)
end

---Edit the selected compose file
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.edit_compose_file(prompt_bufnr)
  telescope_actions.file_edit(prompt_bufnr)
end

function __select_compose_file(file)
  local cmd = "docker-compose -f " .. file .. " "

  local suffix = vim.fn.input {
    prompt = cmd,
    default = "",
    cancelreturn = "",
  }
  if type(suffix) ~= "string" or suffix:len() == 0 then
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

return actions
