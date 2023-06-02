local Item = require "telescope-docker.core.item"

---@class Context : Item
---@field Name string
---@field Current boolean
---@field Description string
---@field DockerEndpoint string
---@field KubernetesEndpoint string
---@field Error string
local Context = Item:new()

---@param json string: A json string
---@return Context
function Context:new(json)
  local image
  if vim.json.decode then
    image = vim.json.decode(json)
  else
    vim.schedule(function()
      image = vim.fn.json_decode(json)
    end)
  end
  image = image or {}
  setmetatable(image, self)
  self.__index = self
  return image
end

Context.fields = {
  { name = "Name", key_hl = "Conditional", value_hl = "String" },
  { name = "Description", key_hl = "Conditional", value_hl = "String" },
  {
    name = "Current",
    key_hl = "Conditional",
    value_hl = "Boolean",
  },
  { name = "DockerEndpoint", key_hl = "Conditional", value_hl = "String" },
  { name = "KubernetesEndpoint", key_hl = "Conditional", value_hl = "String" },
  { name = "Error", key_hl = "Conditional", value_hl = "Error" },
}

return Context
