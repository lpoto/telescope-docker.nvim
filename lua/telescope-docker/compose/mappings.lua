local actions = require "telescope-docker.compose.actions"
local telescope_actions = require "telescope.actions"

local mappings = {}

mappings.keys = {
  ["<CR>"] = actions.select_compose_file,
  ["<C-a>"] = actions.select_compose_file,
  ["<C-e>"] = actions.edit_compose_file,
  ["e"] = actions.edit_compose_file,
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
      local modes = { "n" }
      if key:sub(1, 1) == "<" then
        table.insert(modes, "i")
      end
      for _, mode in ipairs(modes) do
        map(mode, key, function()
          f(prompt_bufnr)
        end)
      end
    end
  end
  return true
end

return mappings
