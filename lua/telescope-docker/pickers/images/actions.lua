local enum = require "telescope-docker.enum"
local popup = require "telescope-docker.util.popup"
local finder = require "telescope-docker.pickers.images.finder"
local telescope_utils = require "telescope-docker.core.telescope_util"

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

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.delete(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param image Image
    ---@param picker table
    function(image, picker)
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
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.history(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param image Image
    ---@param picker table
    function(image, picker)
      local args = { "image", "history", image.ID }
      picker.docker_state:docker_command {
        args = args,
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.retag(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param image Image
    ---@param picker table
    function(image, picker)
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
            telescope_utils.refresh_picker(prompt_bufnr, finder)
          end,
        }
      end)
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.push(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param image Image
    ---@param picker table
    function(image, picker)
      local args = { "push", image:name() }
      picker.docker_state:docker_command {
        args = args,
        ask_for_input = ask_for_input,
      }
    end
  )
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
