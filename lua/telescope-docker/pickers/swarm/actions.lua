local enum = require "telescope-docker.enum"
local popup = require "telescope-docker.util.popup"
local finder = require "telescope-docker.pickers.swarm.finder"
local telescope_utils = require "telescope-docker.util.telescope"

local actions = {}

local select_node

---Open a popup through which a docker node action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_node(prompt_bufnr)
  return select_node(prompt_bufnr, {
    enum.NODES.INSPECT,
    enum.NODES.LIST_TASKS,
    enum.NODES.UPDATE,
    enum.NODES.PROMOTE,
    enum.NODES.DEMOTE,
    enum.NODES.REMOVE,
  })
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.inspect_node(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param node Node
    ---@param picker table
    function(node, picker)
      picker.docker_state:docker_command {
        args = { "node", "inspect", node.ID },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.update_node(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param node Node
    ---@param picker table
    function(node, picker)
      picker.docker_state:docker_job {
        item = node,
        args = { "node", "update", node.ID },
        ask_for_input = ask_for_input,
        start_msg = "Updating node: " .. node.ID,
        end_msg = "Node " .. node.ID .. " updated",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder.nodes_finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.promote_node(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param node Node
    ---@param picker table
    function(node, picker)
      picker.docker_state:docker_job {
        item = node,
        args = { "node", "demote", node.ID },
        ask_for_input = ask_for_input,
        start_msg = "Promoting node: " .. node.ID,
        end_msg = "Node " .. node.ID .. " promoted",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder.nodes_finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.demote_node(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param node Node
    ---@param picker table
    function(node, picker)
      picker.docker_state:docker_job {
        item = node,
        args = { "node", "demote", node.ID },
        ask_for_input = ask_for_input,
        start_msg = "Demoting node: " .. node.ID,
        end_msg = "Node " .. node.ID .. " demoted",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder.nodes_finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.list_tasks(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param node Node
    ---@param picker table
    function(node, picker)
      picker.docker_state:docker_command {
        args = { "node", "ps", node.ID },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.remove(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param node Node
    ---@param picker table
    function(node, picker)
      local choice = vim.fn.confirm(
        "Are you sure you want to remove " .. vim.inspect(node.ID) .. "?",
        "&Yes\n&No"
      )
      if choice ~= 1 then
        return
      end

      local args = { "node", "rm", node.ID }

      picker.docker_state:docker_job {
        item = node,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Removing node: " .. node.ID,
        end_msg = "Node " .. node.ID .. " removed",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder.nodes_finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number
---@param options string[]
function select_node(prompt_bufnr, options)
  popup.open(options, function(choice, ask_for_input)
    if choice == enum.NODES.INSPECT then
      actions.inspect_node(prompt_bufnr, ask_for_input)
    elseif choice == enum.NODES.PROMOTE then
      actions.promote_node(prompt_bufnr, ask_for_input)
    elseif choice == enum.NODES.DEMOTE then
      actions.demote_node(prompt_bufnr, ask_for_input)
    elseif choice == enum.NODES.UPDATE then
      actions.update_node(prompt_bufnr, true)
    elseif choice == enum.NODES.LIST_TASKS then
      actions.list_tasks(prompt_bufnr, ask_for_input)
    elseif choice == enum.NODES.REMOVE then
      actions.remove(prompt_bufnr, ask_for_input)
    end
  end)
end

return actions
