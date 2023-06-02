local actions = require "telescope-docker.pickers.compose.actions"
local telescope_utils = require "telescope-docker.core.telescope_util"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.select_compose_file,
  ["<C-a>"] = actions.select_compose_file,
  ["<C-e>"] = actions.edit_compose_file,
  ["e"] = actions.edit_compose_file,
}

return mappings
