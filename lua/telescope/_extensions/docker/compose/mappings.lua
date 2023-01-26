local actions = require "telescope._extensions.docker.compose.actions"
local telescope_actions = require "telescope.actions"

local mappings = {}

mappings.keys = {
  ["<CR>"] = actions.select_compose_file,
  ["<C-q>"] = function() end,
}

---@param prompt_bufnr number
---@param map function
---@return boolean
function mappings.attach_mappings(prompt_bufnr, map)
  for key, f in pairs(mappings.keys or {}) do
    if key == "<CR>" then
      telescope_actions.select_default:replace(function()
        f(prompt_bufnr)
      end)
    else
      for _, mode in ipairs { "n", "i" } do
        map(mode, key, function()
          f(prompt_bufnr)
        end)
      end
    end
  end
  return true
end

return mappings
