local actions = require "telescope-docker.pickers.default.actions"
local telescope_utils = require "telescope-docker.core.telescope_util"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.select_picker,
  ["<C-q>"] = function() end,
}

return mappings
