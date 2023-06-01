local enum = require "telescope._extensions.docker.enum"
local util = require "telescope._extensions.docker.util"
local popup = require "telescope._extensions.docker.util.popup"
local setup = require "telescope._extensions.docker.setup"
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
    enum.IMAGES.RETAG,
    enum.IMAGES.PUSH,
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
---@param ask_for_input boolean?: Whether to ask for input
function actions.delete(prompt_bufnr, ask_for_input)
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
  local args = { "image", "rm" }
  local name = image:name()
  local start_msg = "Removing image: " .. name
  local end_msg = "Image " .. name .. " removed"
  if name == "<none>:<none>" then
    table.insert(args, image.ID)
    start_msg = "Removing image: " .. image.ID
    end_msg = "Image " .. image.ID .. " removed"
  else
    table.insert(args, name)
  end
  picker.docker_state:docker_job {
    item = image,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = start_msg,
    end_msg = end_msg,
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.history(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_command {
    args = args,
    ask_for_input = ask_for_input,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.retag(prompt_bufnr, ask_for_input)
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

  picker.docker_state:binary(function(binary)
    local retag = vim.fn.input {
      prompt = binary .. " image tag " .. image:name() .. " ",
      default = "",
      cancelreturn = "",
    }
    if type(retag) ~= "string" or retag:len() == 0 then
      return
    end
    local args = {
      "image",
      "tag",
      image:name(),
      unpack(vim.split(retag, " ")),
    }
    picker.docker_state:docker_job {
      item = image,
      args = args,
      ask_for_input = ask_for_input,
      start_msg = "Retagging image: " .. image.ID,
      end_msg = "Image " .. image.ID .. " retagged",
      callback = function()
        actions.refresh_picker(prompt_bufnr)
      end,
    }
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.push(prompt_bufnr, ask_for_input)
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
  local args = { "push", image:name() }
  picker.docker_state:docker_command {
    args = args,
    ask_for_input = ask_for_input,
  }
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
  popup.open(options, function(choice, ask_for_input)
    if choice == enum.IMAGES.DELETE then
      actions.delete(prompt_bufnr, ask_for_input)
    elseif choice == enum.IMAGES.HISTORY then
      actions.history(prompt_bufnr, ask_for_input)
    elseif choice == enum.IMAGES.RETAG then
      actions.retag(prompt_bufnr, ask_for_input)
    elseif choice == enum.IMAGES.PUSH then
      actions.push(prompt_bufnr, ask_for_input)
    end
  end)
end

return actions
