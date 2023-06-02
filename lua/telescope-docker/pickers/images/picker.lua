local finder = require "telescope-docker.pickers.images.finder"
local actions = require "telescope-docker.pickers.images.actions"
local State = require "telescope-docker.pickers.images.docker_state"
local items_picker = require "telescope-docker.core.items_picker"

return items_picker {
  name = "images",
  description = "Existing docker images",
  item_name = "Image",
  finder_fn = finder,
  docker_state = State,
  mappings_tbl = {
    ["<CR>"] = actions.select_image,
    ["<C-a>"] = actions.select_image,
    ["<C-q>"] = function() end,
  },
}
