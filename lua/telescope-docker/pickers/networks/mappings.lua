local actions = require "telescope-docker.pickers.networks.actions"
local telescope_utils = require "telescope-docker.util.telescope"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.select_network,
  ["<C-a>"] = actions.select_network,
  ["<C-q>"] = function() end,
}

return mappings
