local Item = require "telescope-docker.core.item"

---@class Volume : Item
---@field Name string
---@field Group string
---@field Status string
---@field Driver string
---@field Scope string
---@field Size string
---@field Availability string
---@field Labels string
local Volume = Item:new()

---@param json string: A json string
---@return Volume
function Volume:new(json)
  local volume
  if vim.json.decode then
    volume = vim.json.decode(json)
  else
    vim.schedule(function()
      volume = vim.fn.json_decode(json)
    end)
  end
  volume = volume or {}
  setmetatable(volume, self)
  self.__index = self
  return volume
end

Volume.fields = {
  { name = "Name", key_hl = "Conditional", value_hl = "String" },
  { name = "Group", key_hl = "Conditional", value_hl = "String" },
  { name = "Status", key_hl = "Conditional", value_hl = "Function" },
  { name = "Scope", key_hl = "Conditional", value_hl = "Function" },
  { name = "Driver", key_hl = "Conditional", value_hl = "String" },
  { name = "Size", key_hl = "Conditional", value_hl = "Number" },
  { name = "Availability", key_hl = "Conditional", value_hl = "String" },
  { name = "Labels", key_hl = "Conditional", value_hl = "String" },
}

return Volume
