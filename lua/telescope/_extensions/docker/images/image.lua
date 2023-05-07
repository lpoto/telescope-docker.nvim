local util = require "telescope._extensions.docker.util"

---@class Image
---@field ID string
---@field Tag string
---@field Repository string
---@field CreatedAt string
---@field CreatedSince string
---@field Containers string
---@field Digest string
---@field VirtualSize string
---@field UniqueSize string
---@field SharedSize string
local Image = {}
Image.__index = Image

---@param json string: A json string
---@return Image
function Image:new(json)
  json = util.preprocess_json(json)
  local container
  if vim.json.decode then
    container = vim.json.decode(json)
  else
    vim.schedule(function()
      container = vim.fn.json_decode(json)
    end)
  end
  return setmetatable(container or {}, Image)
end

---@return string[]
function Image:represent()
  local lines = {}
  table.insert(lines, "ID: " .. self.ID)
  table.insert(lines, "Tag: " .. self.Tag)
  table.insert(lines, "Repository: " .. self.Repository)
  table.insert(lines, "CreatedAt: " .. self.CreatedAt)
  table.insert(lines, "CreatedSince: " .. self.CreatedSince)
  table.insert(lines, "Containers: " .. self.Containers)
  table.insert(lines, "Digest: " .. self.Digest)
  table.insert(lines, "VirtualSize: " .. self.VirtualSize)
  table.insert(lines, "UniqueSize: " .. self.UniqueSize)
  table.insert(lines, "SharedSize: " .. self.SharedSize)
  return lines
end

function Image:name()
  return self.Repository .. ":" .. self.Tag
end

return Image
