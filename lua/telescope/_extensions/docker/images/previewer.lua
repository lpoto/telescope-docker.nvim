local previewers = require "telescope.previewers"
local util = require "telescope._extensions.docker.util"

local previewer = {}

local preview_fn

---Creates a new telescope previewer for the images.
---@return table: a telescope previewer
function previewer.image_previewer()
  return previewers.new {
    title = "Image Info",
    preview_fn = function(self, entry, status)
      preview_fn(self, entry, status)
    end,
  }
end

---@param status table
---@param image Image
local function display_image(status, image)
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = image:represent()
  pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
  pcall(vim.api.nvim_buf_set_option, buf, "syntax", "yaml")
  local ok, e = pcall(vim.api.nvim_win_set_buf, status.preview_win, buf)
  if ok == false then
    util.error(e)
  end
end

preview_fn = function(self, entry, status)
  display_image(status, entry.value)

  self.status = status
  self.state = self.state or {}
  self.state.winid = status.preview_win
  self.state.bufnr = vim.api.nvim_win_get_buf(status.preview_win)
end

return previewer
