local action_state = require "telescope.actions.state"

local telescope_utils = {}

---@param prompt_bufnr number
---@return table?
function telescope_utils.get_picker(prompt_bufnr)
  if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
    prompt_bufnr = vim.api.nvim_get_current_buf()
  end
  return action_state.get_current_picker(prompt_bufnr)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param callback fun(item: Container|Node|Image|{name: string, picker: function}, picker: table)
---@param check_docker_state boolean?: Whether to check the picker's docker state
function telescope_utils.new_action(prompt_bufnr, callback, check_docker_state)
  local selection = action_state.get_selected_entry()
  local picker = telescope_utils.get_picker(prompt_bufnr)
  if
    not picker
    or (check_docker_state ~= false and not picker.docker_state)
    or not selection
    or not selection.value
  then
    return
  end
  ---@type Container
  local container = selection.value
  return callback(container, picker)
end

return telescope_utils
