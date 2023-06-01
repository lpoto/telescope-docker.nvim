local action_state = require "telescope.actions.state"
local util = require "telescope-docker.util"
local setup = require "telescope-docker.setup"
local telescope_actions = require "telescope.actions"

local actions = {}

---Edit the selected compose file
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.edit_compose_file(prompt_bufnr)
  telescope_actions.file_edit(prompt_bufnr)
end

---Open a popup through which a docker compose file
---may be selected.
function actions.select_compose_file(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local picker = actions.get_picker(prompt_bufnr)
  if
    not picker
    or not picker.docker_state
    or not selection
    or not selection.value
  then
    return
  end
  local file = selection.value

  picker.docker_state:compose_binary(function(binary, _)
    local cmd = binary .. " -f " .. file .. " "

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
  end)
end

function actions.get_picker(prompt_bufnr)
  if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
    prompt_bufnr = vim.api.nvim_get_current_buf()
  end
  local p = action_state.get_current_picker(prompt_bufnr)
  return p
end

return actions
