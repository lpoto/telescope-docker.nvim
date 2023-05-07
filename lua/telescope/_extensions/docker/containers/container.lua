local util = require "telescope._extensions.docker.util"
---@class Container
---@field ID string
---@field Command string
---@field Names string
---@field State string
---@field CreatedAt string
---@field Image string
---@field Mounts string
---@field RunningFor string
---@field Labels string
---@field Networks string
---@field Size string
---@field Ports string
---@field LocalVolumes string
---@field env table?
local Container = {}
Container.__index = Container

---@param json string: A json string
---@return Container
function Container:new(json)
  json = util.preprocess_json(json)
  vim.notify(vim.inspect(json))
  local container
  if vim.json.decode then
    container = vim.json.decode(json)
  else
    vim.schedule(function()
      container = vim.fn.json_decode(json)
    end)
  end
  return setmetatable(container or {}, Container)
end

---@return string[]
function Container:represent()
  local lines = {}
  table.insert(lines, "ID: " .. self.ID)
  table.insert(lines, "Names: " .. self.Names)
  table.insert(lines, "State: " .. self.State)
  table.insert(lines, "Command: " .. self.Command)
  table.insert(lines, "CreatedAt: " .. self.CreatedAt)
  table.insert(lines, "RunningFor: " .. self.RunningFor)
  table.insert(lines, "Image: " .. self.Image)
  table.insert(lines, "Size: " .. self.Size)
  table.insert(lines, "Ports: " .. self.Ports)
  table.insert(lines, "Networks: " .. self.Networks)
  table.insert(lines, "LocalVolumes: " .. self.LocalVolumes)
  table.insert(lines, "Labels: " .. self.Labels)

  if self.env then
    table.insert(lines, "")
    for k, v in pairs(self.env) do
      table.insert(lines, "# " .. k .. ": " .. v)
    end
  end
  return lines
end

return Container
