local Item = require "telescope-docker.util.item"

---@class Image : Item
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
local Image = Item:new()

---@param json string: A json string
---@return Image
function Image:new(json)
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

function Image:name()
  return self.Repository .. ":" .. self.Tag
end

Image.fields = {
  { name = "ID", key_hl = "Conditional", value_hl = "Number" },
  { name = "Tag", key_hl = "Conditional", value_hl = "String" },
  { name = "Repository", key_hl = "Conditional", value_hl = "String" },
  { name = "CreatedAt", key_hl = "Conditional", value_hl = "String" },
  { name = "CreatedSince", key_hl = "Conditional", value_hl = "String" },
  { name = "Containers", key_hl = "Conditional", value_hl = "Number" },
  { name = "Digest", key_hl = "Conditional", value_hl = "String" },
  { name = "VirtualSize", key_hl = "Conditional", value_hl = "Number" },
  { name = "UniqueSize", key_hl = "Conditional", value_hl = "Number" },
  { name = "SharedSize", key_hl = "Conditional", value_hl = "Number" },
}

return Image
