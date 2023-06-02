local Item = require "telescope-docker.core.item"

---@class Network : Item
---@field ID string
---@field Name string
---@field Driver string
---@field Scope string
---@field Internal string
---@field IPv6 string
---@field CreatedAt string
---@field Labels string
local Network = Item:new()

---@param json string: A json string
---@return Network
function Network:new(json)
  local network
  if vim.json.decode then
    network = vim.json.decode(json)
  else
    vim.schedule(function()
      network = vim.fn.json_decode(json)
    end)
  end
  network = network or {}
  setmetatable(network, self)
  self.__index = self
  return network
end

Network.fields = {
  { name = "ID", key_hl = "Conditional", value_hl = "Number" },
  { name = "Name", key_hl = "Conditional", value_hl = "String" },
  { name = "Driver", key_hl = "Conditional", value_hl = "String" },
  { name = "Scope", key_hl = "Conditional", value_hl = "Function" },
  { name = "Internal", key_hl = "Conditional", value_hl = "Function" },
  { name = "IPv6", key_hl = "Conditional", value_hl = "Function" },
  { name = "CreatedAt", key_hl = "Conditional", value_hl = "String" },
  { name = "Labels", key_hl = "Conditional", value_hl = "String" },
}

return Network
