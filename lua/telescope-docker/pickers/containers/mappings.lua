local actions = require "telescope-docker.pickers.containers.actions"
local telescope_utils = require "telescope-docker.util.telescope"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.select_container,
  ["<C-a>"] = actions.select_container,
  ["<C-q>"] = function() end,
}

return mappings
