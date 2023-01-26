local enum = require "telescope._extensions.docker.enum"
local util = require "telescope._extensions.docker.util"
local popup = require "telescope._extensions.docker.util.popup"
local images = require "telescope._extensions.docker.images"
local action_state = require "telescope.actions.state"
local finder = require "telescope._extensions.docker.images.finder"
local telescope_actions = require "telescope.actions"

local actions = {}

local select_image

---Open a popup through which a docker image action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_image(prompt_bufnr)
  local selection = action_state.get_selected_entry(prompt_bufnr)
  ---@type Image
  local image = selection.value
  return select_image(image, prompt_bufnr, {
    enum.IMAGES.DELETE,
    enum.IMAGES.HISTORY,
  })
end

---Asynchronously refresh the images picker.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.refresh_picker(prompt_bufnr)
  images.get_images(function(images_tbl)
    if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
      prompt_bufnr = vim.api.nvim_get_current_buf()
    end
    local p = action_state.get_current_picker(prompt_bufnr)
    if p == nil then
      return
    end
    if not images_tbl or not next(images_tbl) then
      util.warn "No images were found"
      pcall(telescope_actions.close, prompt_bufnr)
      return
    end
    local ok, images_finder = pcall(finder.images_finder, images_tbl)
    if not ok then
      util.error(images_finder)
    end
    if not images_finder then
      return
    end
    local e
    ok, e = pcall(p.refresh, p, images_finder)
    if not ok and type(e) == "string" then
      util.error(e)
    end
  end)
end

---Close the telescope images picker.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.close_picker(prompt_bufnr)
  vim.schedule(function()
    if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
      prompt_bufnr = vim.api.nvim_get_current_buf()
    end
    pcall(telescope_actions.close, prompt_bufnr)
  end)
end

---@param image Image
---@param prompt_bufnr number
---@param options string[]
function select_image(image, prompt_bufnr, options)
  popup.open(options, function(choice)
    if choice == enum.IMAGES.DELETE then
      images.delete(image, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    elseif choice == enum.IMAGES.HISTORY then
      images.history(image)
    end
  end)
end

return actions
