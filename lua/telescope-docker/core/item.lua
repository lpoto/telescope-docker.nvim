local util = require "telescope-docker.util"

---@class HighlightField
---@field name string
---@field key_hl string
---@field value_hl string

---@class Item
---@field fields HighlightField[]
---@field env table?
---@field name string
local Item = {
  fields = {},
  env = {},
}

function Item:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---@return string[]
function Item:represent()
  local lines = {}
  for _, field in pairs(self.fields or {}) do
    table.insert(lines, string.format("%s: %s", field.name, self[field.name]))
  end

  if type(self.env) == "table" and next(self.env) then
    table.insert(lines, "")
    for k, v in pairs(self.env) do
      table.insert(lines, "# " .. k .. ": " .. v)
    end
  end
  return lines
end

function Item:create_preview_buffer()
  local ok, b = pcall(function()
    local lines = self:represent()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    pcall(vim.api.nvim_buf_set_option, buf, "buftype", "nofile")
    pcall(vim.api.nvim_buf_set_option, buf, "bufhidden", "wipe")
    local i = 0
    for _, field in pairs(self.fields) do
      local name = field.name
      local n = vim.fn.strchars(name)
      vim.api.nvim_buf_add_highlight(buf, 0, field.key_hl, i, 0, n)
      vim.api.nvim_buf_add_highlight(buf, 0, field.value_hl, i, n, -1)
      i = i + 1
    end
    i = i + 1
    if self.env then
      for _, _ in pairs(self.env) do
        vim.api.nvim_buf_add_highlight(buf, 0, "Comment", i, 0, -1)
        i = i + 1
      end
    end
    return buf
  end)
  if not ok then
    util.warn(b)
    return -1
  end
  return b
end

---@param status table
function Item:display(status)
  local buf = self:create_preview_buffer()
  if buf == nil or buf == -1 then
    return
  end
  local ok, e = pcall(vim.api.nvim_win_set_buf, status.preview_win, buf)
  if ok == false then
    util.error(e)
  end
end

return Item
