local actions = require "telescope-docker.pickers.swarm.actions"
local telescope_utils = require "telescope-docker.util.telescope"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.select_node,
  ["<C-a>"] = actions.select_node,
  ["<C-q>"] = function() end,
}

return mappings
