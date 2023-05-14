local Item = require "telescope._extensions.docker.util.item"

---@class Container : Item
---@field ID string
---@field Command string
---@field Names string
---@field State string
---@field Status string
---@field CreatedAt string
---@field Image string
---@field Mounts string
---@field RunningFor string
---@field Labels string
---@field Networks string
---@field Size string
---@field Ports string
---@field LocalVolumes string
local Container = Item:new()

---@param json string: A json string
---@return Container
function Container:new(json)
  local container
  if vim.json.decode then
    container = vim.json.decode(json)
  else
    vim.schedule(function()
      container = vim.fn.json_decode(json)
    end)
  end
  container = container or {}
  setmetatable(container, self)
  self.__index = self
  return container
end

Container.fields = {
  { name = "ID", key_hl = "Conditional", value_hl = "Number" },
  { name = "Names", key_hl = "Conditional", value_hl = "String" },
  { name = "State", key_hl = "Conditional", value_hl = "Function" },
  { name = "Status", key_hl = "Conditional", value_hl = "Function" },
  { name = "Command", key_hl = "Conditional", value_hl = "String" },
  { name = "CreatedAt", key_hl = "Conditional", value_hl = "String" },
  { name = "RunningFor", key_hl = "Conditional", value_hl = "String" },
  { name = "Image", key_hl = "Conditional", value_hl = "Number" },
  { name = "Size", key_hl = "Conditional", value_hl = "String" },
  { name = "Ports", key_hl = "Conditional", value_hl = "Number" },
  { name = "Networks", key_hl = "Conditional", value_hl = "String" },
  { name = "LocalVolumes", key_hl = "Conditional", value_hl = "Number" },
  { name = "Labels", key_hl = "Conditional", value_hl = "String" },
}

---@return string[]
function Container:represent()
  local lines = {}
  for _, field in pairs(self.fields) do
    table.insert(lines, string.format("%s: %s", field.name, self[field.name]))
  end

  if self.env then
    table.insert(lines, "")
    for k, v in pairs(self.env) do
      table.insert(lines, "# " .. k .. ": " .. v)
    end
  end
  return lines
end

return Container
