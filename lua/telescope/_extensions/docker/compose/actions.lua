local action_state = require "telescope.actions.state"
local compose = require "telescope._extensions.docker.compose"
local telescope_actions = require "telescope.actions"

local actions = {}

---Open a popup through which a docker compose file
---may be selected.
function actions.select_compose_file()
  local selection = action_state.get_selected_entry()
  local file = selection.value
  compose.select_compose_file(file)
end

---Edit the selected compose file
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.edit_compose_file(prompt_bufnr)
  telescope_actions.file_edit(prompt_bufnr)
end

return actions
