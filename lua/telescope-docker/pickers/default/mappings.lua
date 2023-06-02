local actions = require "telescope-docker.pickers.default.actions"
local telescope_actions = require "telescope.actions"

local mappings = {}

---@param prompt_bufnr number
---@return boolean
function mappings.attach_mappings(prompt_bufnr, _)
  telescope_actions.select_default:replace(function()
    actions.select_picker(prompt_bufnr)
  end)
  return true
end

return mappings
