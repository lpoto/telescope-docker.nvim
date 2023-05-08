local actions = require "telescope._extensions.docker.files.actions"
local telescope_actions = require "telescope.actions"

local mappings = {}

mappings.keys = {
  ["<CR>"] = actions.build_from_input,
  ["<C-e>"] = actions.edit_dockerfile,
  ["e"] = actions.edit_dockerfile,
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
