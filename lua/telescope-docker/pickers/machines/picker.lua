local finder = require "telescope-docker.pickers.machines.finder"
local State = require "telescope-docker.pickers.machines.docker_state"
local DockerPicker = require "telescope-docker.core.docker_picker"
local items_picker = require "telescope-docker.core.items_picker"
local actions = require "telescope-docker.pickers.containers.actions"

return items_picker {
  name = "machines",
  description = "Existing docker machines",
  item_name = "Machine",
  finder_fn = finder,
  docker_state = State,
  mappings_tbl = {
    ["<CR>"] = actions.select_machine,
    ["<C-a>"] = actions.select_machine,
    ["<C-q>"] = function() end,
  },
}
