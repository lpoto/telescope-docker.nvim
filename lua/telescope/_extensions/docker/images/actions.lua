local enum = require "telescope._extensions.docker.enum"
local util = require "telescope._extensions.docker.util"
local popup = require "telescope._extensions.docker.util.popup"
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
  return select_image(prompt_bufnr, {
    enum.IMAGES.DELETE,
    enum.IMAGES.HISTORY,
  })
end

---Asynchronously refresh the images picker.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.refresh_picker(prompt_bufnr)
  local picker = actions.get_picker(prompt_bufnr)
  if not picker or not picker.docker_state then
    return
  end
  picker.docker_state:fetch_images(function(images_tbl)
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

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.delete(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local picker = actions.get_picker(prompt_bufnr)
  if
    not picker
    or not picker.docker_state
    or not selection
    or not selection.value
  then
    return
  end
  local image = selection.value
  local args = { "image", "rm", image.ID }
  util.info("Deleting image:", image.ID)
  picker.docker_state:docker_job(image, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Image", image.ID, "deleted")
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.history(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local picker = actions.get_picker(prompt_bufnr)
  if
    not picker
    or not picker.docker_state
    or not selection
    or not selection.value
  then
    return
  end
  local image = selection.value
  local args = { "image", "history", image.ID }
  util.info("Fetching history for image:", image.ID)
  picker.docker_state:docker_command(args)
end

function actions.get_picker(prompt_bufnr)
  if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
    prompt_bufnr = vim.api.nvim_get_current_buf()
  end
  local p = action_state.get_current_picker(prompt_bufnr)
  return p
end

---@param prompt_bufnr number
---@param options string[]
function select_image(prompt_bufnr, options)
  popup.open(options, function(choice)
    if choice == enum.IMAGES.DELETE then
      actions.delete(prompt_bufnr)
    elseif choice == enum.IMAGES.HISTORY then
      actions.history(prompt_bufnr)
    end
  end)
end

return actions
