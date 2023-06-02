local finder = require "telescope-docker.pickers.networks.finder"
local State = require "telescope-docker.pickers.networks.docker_state"
local items_picker = require "telescope-docker.core.items_picker"
local actions = require "telescope-docker.pickers.networks.actions"

return items_picker {
  name = "networks",
  description = "Existing docker networks",
  item_name = "Network",
  finder_fn = finder,
  docker_state = State,
  mappings_tbl = {
    ["<CR>"] = actions.select_network,
    ["<C-a>"] = actions.select_network,
    ["<C-q>"] = function() end,
  },
}
