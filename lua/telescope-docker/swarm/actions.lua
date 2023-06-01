local enum = require "telescope-docker.enum"
local util = require "telescope-docker.util"
local popup = require "telescope-docker.util.popup"
local action_state = require "telescope.actions.state"
local finder = require "telescope-docker.swarm.finder"
local telescope_actions = require "telescope.actions"
local actions = {}

local select_node
local new_action

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
  new_action(prompt_bufnr, function(node, picker)
    picker.docker_state:docker_command {
      args = { "node", "inspect", node.ID },
      ask_for_input = ask_for_input,
    }
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.update_node(prompt_bufnr, ask_for_input)
  new_action(prompt_bufnr, function(node, picker)
    picker.docker_state:docker_job {
      item = node,
      args = { "node", "update", node.ID },
      ask_for_input = ask_for_input,
      start_msg = "Updating node: " .. node.ID,
      end_msg = "Node " .. node.ID .. " updated",
      callback = function()
        actions.refresh_picker(prompt_bufnr)
      end,
    }
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.promote_node(prompt_bufnr, ask_for_input)
  new_action(prompt_bufnr, function(node, picker)
    picker.docker_state:docker_job {
      item = node,
      args = { "node", "demote", node.ID },
      ask_for_input = ask_for_input,
      start_msg = "Promoting node: " .. node.ID,
      end_msg = "Node " .. node.ID .. " promoted",
      callback = function()
        actions.refresh_picker(prompt_bufnr)
      end,
    }
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.demote_node(prompt_bufnr, ask_for_input)
  new_action(prompt_bufnr, function(node, picker)
    picker.docker_state:docker_job {
      item = node,
      args = { "node", "demote", node.ID },
      ask_for_input = ask_for_input,
      start_msg = "Demoting node: " .. node.ID,
      end_msg = "Node " .. node.ID .. " demoted",
      callback = function()
        actions.refresh_picker(prompt_bufnr)
      end,
    }
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.list_tasks(prompt_bufnr, ask_for_input)
  new_action(prompt_bufnr, function(node, picker)
    picker.docker_state:docker_command {
      args = { "node", "ps", node.ID },
      ask_for_input = ask_for_input,
    }
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean: Whether or not to ask for input
function actions.remove(prompt_bufnr, ask_for_input)
  new_action(prompt_bufnr, function(node, picker)
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
        actions.refresh_picker(prompt_bufnr)
      end,
    }
  end)
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

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param callback fun(node: Node, picker: Picker)
function new_action(prompt_bufnr, callback)
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
  ---@type Node
  local node = selection.value
  return callback(node, picker)
end

function actions.get_picker(prompt_bufnr)
  if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
    prompt_bufnr = vim.api.nvim_get_current_buf()
  end
  local p = action_state.get_current_picker(prompt_bufnr)
  return p
end

---Asynchronously refresh the nodes picker.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.refresh_picker(prompt_bufnr)
  local picker = actions.get_picker(prompt_bufnr)
  if not picker or not picker.docker_state then
    return
  end
  picker.docker_state:fetch_nodes(function(nodes_tbl)
    if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
      prompt_bufnr = vim.api.nvim_get_current_buf()
    end
    local p = action_state.get_current_picker(prompt_bufnr)
    if p == nil then
      return
    end
    if not nodes_tbl or not next(nodes_tbl) then
      util.warn "No nodes were found"
      pcall(telescope_actions.close, prompt_bufnr)
      return
    end
    local ok, nodes_finder = pcall(finder.nodes_finder, nodes_tbl)
    if not ok then
      util.error(nodes_finder)
    end
    if not nodes_finder then
      return
    end
    local e
    ok, e = pcall(p.refresh, p, nodes_finder)
    if not ok and type(e) == "string" then
      util.error(e)
    end
  end)
end

return actions
