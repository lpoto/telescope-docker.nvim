local finder = require "telescope-docker.pickers.contexts.finder"
local actions = require "telescope-docker.pickers.contexts.actions"
local State = require "telescope-docker.pickers.contexts.docker_state"
local items_picker = require "telescope-docker.core.items_picker"

return items_picker {
  name = "contexts",
  description = "Existing docker contexts",
  priority = 2,
  item_name = "Context",
  finder_fn = finder,
  docker_state = State,
  mappings_tbl = {
    ["<CR>"] = actions.select_context,
    ["<C-a>"] = actions.select_context,
    ["<C-q>"] = function() end,
  },
}
