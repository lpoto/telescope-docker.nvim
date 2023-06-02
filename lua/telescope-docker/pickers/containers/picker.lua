local finder = require "telescope-docker.pickers.containers.finder"
local actions = require "telescope-docker.pickers.containers.actions"
local State = require "telescope-docker.pickers.containers.docker_state"
local items_picker = require "telescope-docker.core.items_picker"

return items_picker {
  name = "containers",
  description = "Existing docker containers",
  item_name = "Container",
  finder_fn = finder,
  docker_state = State,
  mappings_tbl = {
    ["<CR>"] = actions.select_container,
    ["<C-a>"] = actions.select_container,
    ["<C-q>"] = function() end,
  },
}
