local Item = require "telescope-docker.core.item"

---@class Node : Item
---@field ID string
---@field Self string
---@field Hostname string
---@field Status string
---@field TLSStatus string
---@field ManagerStatus string
---@field EngineVersion string
---@field Availability string
local Node = Item:new()

---@param json string: A json string
---@return Node
function Node:new(json)
  local node
  if vim.json.decode then
    node = vim.json.decode(json)
  else
    vim.schedule(function()
      node = vim.fn.json_decode(json)
    end)
  end
  node = node or {}
  setmetatable(node, self)
  self.__index = self
  return node
end

Node.fields = {
  { name = "ID", key_hl = "Conditional", value_hl = "Number" },
  { name = "Self", key_hl = "Conditional", value_hl = "Boolean" },
  { name = "Hostname", key_hl = "Conditional", value_hl = "String" },
  { name = "Status", key_hl = "Conditional", value_hl = "Function" },
  { name = "TLSStatus", key_hl = "Conditional", value_hl = "Function" },
  { name = "ManagerStatus", key_hl = "Conditional", value_hl = "Function" },
  { name = "EngineVersion", key_hl = "Conditional", value_hl = "String" },
  { name = "Availability", key_hl = "Conditional", value_hl = "Number" },
}

return Node
