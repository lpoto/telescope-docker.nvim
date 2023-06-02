local actions = require "telescope-docker.pickers.machines.actions"
local telescope_utils = require "telescope-docker.util.telescope"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.select_machine,
  ["<C-a>"] = actions.select_machine,
  ["<C-q>"] = function() end,
}

return mappings
