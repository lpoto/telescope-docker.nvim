local finder = require "telescope-docker.pickers.swarm.finder"
local State = require "telescope-docker.pickers.swarm.docker_state"
local items_picker = require "telescope-docker.core.items_picker"
local actions = require "telescope-docker.pickers.swarm.actions"

return items_picker {
  name = "nodes",
  description = "Docker nodes in the current swarm",
  item_name = "Node",
  finder_fn = finder,
  docker_state = State,
  mappings_tbl = {
    ["<CR>"] = actions.select_node,
    ["<C-a>"] = actions.select_node,
    ["<C-q>"] = function() end,
  },
}
