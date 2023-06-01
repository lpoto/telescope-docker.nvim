local previewers = require "telescope.previewers"

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

preview_fn = function(self, entry, status)
  entry.value:display(status)

  self.status = status
  self.state = self.state or {}
  self.state.winid = status.preview_win
  self.state.bufnr = vim.api.nvim_win_get_buf(status.preview_win)
end

return previewer
