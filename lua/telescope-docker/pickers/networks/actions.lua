local enum = require "telescope-docker.enum"
local popup = require "telescope-docker.util.popup"
local finder = require "telescope-docker.pickers.networks.finder"
local telescope_utils = require "telescope-docker.core.telescope_util"

local actions = {}

local select_network

---Open a popup through which a docker network action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_network(prompt_bufnr)
  return select_network(prompt_bufnr, {
    enum.NETWORKS.INSPECT,
    enum.NETWORKS.REMOVE,
    enum.NETWORKS.CONNECT,
    enum.NETWORKS.DISCONNECT,
  })
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.inspect(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param network Network
    ---@param picker table
    function(network, picker)
      picker.docker_state:docker_command {
        args = { "network", "inspect", network.ID },
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
    ---@param network Network
    ---@param picker table
    function(network, picker)
      local args = { "network", "rm", network.ID }
      picker.docker_state:docker_job {
        item = network,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Removing network: "
          .. network.Name
          .. " ("
          .. network.ID
          .. ")",
        end_msg = "Network " .. network.Name .. " removed",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.connect(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param network Network
    ---@param picker table
    function(network, picker)
      local input = vim.fn.input {
        prompt = "Connect container: ",
        default = "",
        cancelreturn = false,
      }
      if type(input) ~= "string" or input:len() == 0 then
        return
      end

      local args = { "network", "connect", network.ID, input }
      picker.docker_state:docker_job {
        item = network,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Connecting container '"
          .. input
          .. "' to network '"
          .. network.Name
          .. "'",
        end_msg = "Container connected",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.disconnect(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param network Network
    ---@param picker table
    function(network, picker)
      local input = vim.fn.input {
        prompt = "Disconnect container: ",
        default = "",
        cancelreturn = false,
      }
      if type(input) ~= "string" or input:len() == 0 then
        return
      end

      local args = { "network", "disconnect", network.ID, input }
      picker.docker_state:docker_job {
        item = network,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Disconnecting container '"
          .. input
          .. "' from network '"
          .. network.Name
          .. "'",
        end_msg = "Container disconnected",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number
---@param options string[]
function select_network(prompt_bufnr, options)
  popup.open(options, function(choice, ask_for_input)
    if choice == enum.NETWORKS.INSPECT then
      actions.inspect(prompt_bufnr, ask_for_input)
    elseif choice == enum.NETWORKS.CONNECT then
      actions.connect(prompt_bufnr, ask_for_input)
    elseif choice == enum.NETWORKS.DISCONNECT then
      actions.disconnect(prompt_bufnr, ask_for_input)
    elseif choice == enum.NETWORKS.REMOVE then
      actions.remove(prompt_bufnr, ask_for_input)
    end
  end)
end

return actions
