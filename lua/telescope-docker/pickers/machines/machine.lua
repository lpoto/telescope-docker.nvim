local Item = require "telescope-docker.core.item"

---@class Machine : Item
---@field Name string
---@field DriverName string
---@field State string
---@field Swarm string
---@field URL string
---@field Active string|boolean
---@field ActiveHost string|boolean
---@field ActiveSwarm string|boolean
---@field DockerVersion string
---@field ResponseTime string
---@field Error string
local Machine = Item:new()

---@param json string: A json string
---@return Machine
function Machine:new(json)
  local machine
  if vim.json.decode then
    machine = vim.json.decode(json)
  else
    vim.schedule(function()
      machine = vim.fn.json_decode(json)
    end)
  end
  machine = machine or {}
  setmetatable(machine, self)
  self.__index = self
  return machine
end

Machine.fields = {
  { name = "Name", key_hl = "Conditional", value_hl = "String" },
  { name = "DriverName", key_hl = "Conditional", value_hl = "String" },
  { name = "State", key_hl = "Conditional", value_hl = "Function" },
  { name = "Swarm", key_hl = "Conditional", value_hl = "String" },
  { name = "URL", key_hl = "Conditional", value_hl = "String" },
  { name = "Active", key_hl = "Conditional", value_hl = "String" },
  { name = "ActiveHost", key_hl = "Conditional", value_hl = "String" },
  { name = "ActiveSwarm", key_hl = "Conditional", value_hl = "String" },
  { name = "DockerVersion", key_hl = "Conditional", value_hl = "String" },
  { name = "ResponseTime", key_hl = "Conditional", value_hl = "String" },
  { name = "Error", key_hl = "Conditional", value_hl = "String" },
}

return Machine
