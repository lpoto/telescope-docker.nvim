local enum = require "telescope-docker.enum"
local popup = require "telescope-docker.util.popup"
local finder = require "telescope-docker.pickers.volumes.finder"
local telescope_utils = require "telescope-docker.core.telescope_util"

local actions = {}

local select_volume

---Open a popup through which a docker volume action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_volume(prompt_bufnr)
  return select_volume(prompt_bufnr, {
    enum.VOLUMES.INSPECT,
    enum.VOLUMES.REMOVE,
  })
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.inspect(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param volume Volume
    ---@param picker table
    function(volume, picker)
      picker.docker_state:docker_command {
        args = { "volume", "inspect", volume.Name },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.remove(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param volume Volume
    ---@param picker table
    function(volume, picker)
      local args = { "volume", "rm", volume.Name }
      picker.docker_state:docker_job {
        item = volume,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Removing volume: "
          .. volume.Name
          .. " ("
          .. volume.Name
          .. ")",
        end_msg = "Volume " .. volume.Name .. " removed",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number
---@param options string[]
function select_volume(prompt_bufnr, options)
  popup.open(options, function(choice, ask_for_input)
    if choice == enum.VOLUMES.INSPECT then
      actions.inspect(prompt_bufnr, ask_for_input)
    elseif choice == enum.VOLUMES.REMOVE then
      actions.remove(prompt_bufnr, ask_for_input)
    end
  end)
end

return actions
