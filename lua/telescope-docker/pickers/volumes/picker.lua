local finder = require "telescope-docker.pickers.volumes.finder"
local actions = require "telescope-docker.pickers.volumes.actions"
local State = require "telescope-docker.pickers.volumes.docker_state"
local items_picker = require "telescope-docker.core.items_picker"

return items_picker {
  name = "volumes",
  description = "Existing docker volumes",
  item_name = "Volume",
  priority = 97,
  finder_fn = finder,
  docker_state = State,
  mappings_tbl = {
    ["<CR>"] = actions.select_volume,
    ["<C-a>"] = actions.select_volume,
    ["<C-q>"] = function() end,
  },
}
