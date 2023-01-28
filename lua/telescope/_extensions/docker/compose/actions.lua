local action_state = require "telescope.actions.state"
local compose = require "telescope._extensions.docker.compose"

local actions = {}

---Open a popup through which a docker compose file
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_compose_file(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local file = selection.value
  compose.select_compose_file(file)
end

return actions
