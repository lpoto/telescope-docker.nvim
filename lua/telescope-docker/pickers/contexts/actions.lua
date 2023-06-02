local enum = require "telescope-docker.enum"
local popup = require "telescope-docker.util.popup"
local finder = require "telescope-docker.pickers.contexts.finder"
local telescope_utils = require "telescope-docker.core.telescope_util"

local actions = {}

local select_context

---Open a popup through which a docker context action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_context(prompt_bufnr)
  return select_context(prompt_bufnr, {
    enum.CONTEXTS.INSPECT,
    enum.CONTEXTS.UPDATE,
    enum.CONTEXTS.USE,
    enum.CONTEXTS.REMOVE,
  })
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.inspect(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param context Context
    ---@param picker table
    function(context, picker)
      picker.docker_state:docker_command {
        args = { "context", "inspect", context.Name },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.use(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param context Context
    ---@param picker table
    function(context, picker)
      local args = { "context", "use", context.Name }
      picker.docker_state:docker_job {
        item = context,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Setting '" .. context.Name .. "' as current context",
        end_msg = "Context " .. context.Name .. " set as current",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.remove(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param context Context
    ---@param picker table
    function(context, picker)
      local args = { "context", "rm", context.Name }
      picker.docker_state:docker_job {
        item = context,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Removing context: "
          .. context.Name
          .. " ("
          .. context.Name
          .. ")",
        end_msg = "Context " .. context.Name .. " removed",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.update(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param context Context
    ---@param picker table
    function(context, picker)
      picker.docker_state:docker_job {
        item = context,
        args = { "context", "update", context.Name },
        ask_for_input = ask_for_input,
        start_msg = "Updating context: " .. context.Name,
        end_msg = "Context " .. context.Name .. " updated",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number
---@param options string[]
function select_context(prompt_bufnr, options)
  popup.open(options, function(choice, ask_for_input)
    if choice == enum.CONTEXTS.INSPECT then
      actions.inspect(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTEXTS.REMOVE then
      actions.remove(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTEXTS.USE then
      actions.use(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTEXTS.UPDATE then
      actions.update(prompt_bufnr, true)
    end
  end)
end

return actions
