local enum = require "telescope._extensions.docker.enum"
local util = require "telescope._extensions.docker.util"
local setup = require "telescope._extensions.docker.setup"
local popup = require "telescope._extensions.docker.util.popup"
local action_state = require "telescope.actions.state"
local finder = require "telescope._extensions.docker.containers.finder"
local telescope_actions = require "telescope.actions"

local actions = {}

local select_container

---Open a popup through which a docker container action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_container(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if not selection or not selection.value then
    return
  end
  ---@type Container
  local container = selection.value
  if container.State == "exited" then
    return select_container(prompt_bufnr, {
      enum.CONTAINERS.START,
      enum.CONTAINERS.DELETE,
      enum.CONTAINERS.LOGS,
      enum.CONTAINERS.RENAME,
    })
  elseif container.State == "running" then
    return select_container(prompt_bufnr, {
      enum.CONTAINERS.ATTACH,
      enum.CONTAINERS.EXEC,
      enum.CONTAINERS.STOP,
      enum.CONTAINERS.KILL,
      enum.CONTAINERS.PAUSE,
      enum.CONTAINERS.LOGS,
      enum.CONTAINERS.STATS,
      enum.CONTAINERS.RENAME,
    })
  elseif container.State == "paused" then
    return select_container(prompt_bufnr, {
      enum.CONTAINERS.UNPAUSE,
      enum.CONTAINERS.STOP,
      enum.CONTAINERS.KILL,
      enum.CONTAINERS.LOGS,
      enum.CONTAINERS.STATS,
      enum.CONTAINERS.RENAME,
    })
  end
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.start(prompt_bufnr)
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
  local container = selection.value
  if container.State ~= "exited" then
    util.warn "Container is already running"
    return
  end
  util.info("Starting container:", container.ID)
  local args = { "start", container.ID }
  picker.docker_state:docker_job(container, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Container", container.ID, "started")
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.pause(prompt_bufnr)
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
  local container = selection.value
  if container.State ~= "running" then
    util.warn "Container is not running"
    return
  end
  local args = { "pause", container.ID }
  util.info("Pausing container:", container.ID)
  picker.docker_state:docker_job(container, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Container", container.ID, "paused")
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.unpause(prompt_bufnr)
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
  local container = selection.value
  if container.State ~= "paused" then
    util.warn "Container is not paused"
    return
  end
  local args = { "unpause", container.ID }
  util.info("Unpausing container:", container.ID)
  picker.docker_state:docker_job(container, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Container", container.ID, "unpaused")
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.stop(prompt_bufnr)
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
  local container = selection.value
  if container.State == "exited" then
    util.warn "Container is not running"
    return
  end
  local args = { "stop", container.ID }
  util.info("Stopping container:", container.ID)
  picker.docker_state:docker_job(container, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Container", container.ID, "stopped")
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.kill(prompt_bufnr)
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
  local container = selection.value
  if container.State == "exited" then
    util.warn "Container is not running"
    return
  end
  local args = { "kill", container.ID }
  util.info("Killing container:", container.ID)
  picker.docker_state:docker_job(container, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Container", container.ID, "killed")
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
  local container = selection.value
  if container.State ~= "exited" then
    util.warn "Container is not exited"
    return
  end
  local args = { "rm", container.ID }
  util.info("Deleting container:", container.ID)
  picker.docker_state:docker_job(container, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Container", container.ID, "deleted")
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.rename(prompt_bufnr)
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
  local container = selection.value
  local binary = setup.get_option "binary" or "docker"
  local cmd = binary .. " rename " .. container.ID .. " "
  local rename = vim.fn.input(cmd)
  local args = {
    "rename",
    container.ID,
    unpack(vim.split(rename, " ")),
  }
  util.info("Renaming container:", container.ID)
  picker.docker_state:docker_job(container, args, function()
    actions.refresh_picker(prompt_bufnr)
    util.info("Container", container.ID, "renamed")
  end)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.attach(prompt_bufnr)
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
  local container = selection.value
  if container.State ~= "running" then
    util.warn "Container is not running"
    return
  end
  picker.docker_state:docker_command { "attach", container.ID }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.logs(prompt_bufnr)
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
  local container = selection.value
  picker.docker_state:docker_command { "logs", container.ID }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.stats(prompt_bufnr)
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
  local container = selection.value
  if container.State == "exited" then
    util.warn "Container is exited"
    return
  end
  picker.docker_state:docker_command { "stats", container.ID }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.exec(prompt_bufnr)
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
  local container = selection.value
  if container.State ~= "running" then
    util.warn "Container is not running"
    return
  end
  local binary = setup.get_option "binary" or "docker"
  local command = binary .. " exec -it " .. container.ID .. " "
  local exec = vim.fn.input(command)
  if not exec or exec:len() == 0 then
    util.warn "Invalid command"
    return
  end
  local args = {
    "exec",
    "-it",
    container.ID,
    unpack(vim.split(exec, " ")),
  }
  picker.docker_state:docker_command(args)
end

---Asynchronously refresh the containers picker.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.refresh_picker(prompt_bufnr)
  local picker = actions.get_picker(prompt_bufnr)
  if not picker or not picker.docker_state then
    return
  end
  picker.docker_state:fetch_containers(function(containers_tbl)
    if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
      prompt_bufnr = vim.api.nvim_get_current_buf()
    end
    local p = action_state.get_current_picker(prompt_bufnr)
    if p == nil then
      return
    end
    if not containers_tbl or not next(containers_tbl) then
      util.warn "No containers were found"
      pcall(telescope_actions.close, prompt_bufnr)
      return
    end
    local ok, containers_finder =
      pcall(finder.containers_finder, containers_tbl)
    if not ok then
      util.error(containers_finder)
    end
    if not containers_finder then
      return
    end
    local e
    ok, e = pcall(p.refresh, p, containers_finder)
    if not ok and type(e) == "string" then
      util.error(e)
    end
  end)
end

---Close the telescope containers picker.
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

function actions.get_picker(prompt_bufnr)
  if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
    prompt_bufnr = vim.api.nvim_get_current_buf()
  end
  local p = action_state.get_current_picker(prompt_bufnr)
  return p
end

---@param prompt_bufnr number
---@param options string[]
function select_container(prompt_bufnr, options)
  popup.open(options, function(choice)
    if choice == enum.CONTAINERS.START then
      actions.start(prompt_bufnr)
    elseif choice == enum.CONTAINERS.STOP then
      actions.stop(prompt_bufnr)
    elseif choice == enum.CONTAINERS.KILL then
      actions.kill(prompt_bufnr)
    elseif choice == enum.CONTAINERS.DELETE then
      actions.delete(prompt_bufnr)
    elseif choice == enum.CONTAINERS.ATTACH then
      actions.attach(prompt_bufnr)
    elseif choice == enum.CONTAINERS.EXEC then
      actions.exec(prompt_bufnr)
    elseif choice == enum.CONTAINERS.LOGS then
      actions.logs(prompt_bufnr)
    elseif choice == enum.CONTAINERS.STATS then
      actions.stats(prompt_bufnr)
    elseif choice == enum.CONTAINERS.RENAME then
      actions.rename(prompt_bufnr)
    elseif choice == enum.CONTAINERS.PAUSE then
      actions.pause(prompt_bufnr)
    elseif choice == enum.CONTAINERS.UNPAUSE then
      actions.unpause(prompt_bufnr)
    end
  end)
end

return actions
