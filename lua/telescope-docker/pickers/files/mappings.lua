local actions = require "telescope-docker.pickers.files.actions"
local telescope_utils = require "telescope-docker.util.telescope"

local mappings = {}

mappings.attach_mappings = telescope_utils.get_attach_mappings_fn {
  ["<CR>"] = actions.build_from_input,
  ["<C-a>"] = function(pb)
    actions.build_from_input(pb, true)
  end,
  ["<C-e>"] = actions.edit_dockerfile,
  ["e"] = actions.edit_dockerfile,
}

return mappings
