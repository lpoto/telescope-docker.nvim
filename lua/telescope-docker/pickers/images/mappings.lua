local actions = require "telescope-docker.pickers.images.actions"
local telescope_utils = require "telescope-docker.util.telescope"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.select_image,
  ["<C-a>"] = actions.select_image,
  ["<C-q>"] = function() end,
}

return mappings
