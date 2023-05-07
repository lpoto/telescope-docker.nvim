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
---@param ask_for_input boolean?: Whether to ask for input
function actions.start(prompt_bufnr, ask_for_input)
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
  local args = { "start", container.ID }
  picker.docker_state:docker_job {
    item = container,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = "Starting container: " .. container.ID,
    end_msg = "Container " .. container.ID .. " started",
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.pause(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_job {
    item = container,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = "Pausing container: " .. container.ID,
    end_msg = "Container " .. container.ID .. " paused",
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.unpause(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_job {
    item = container,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = "Unpausing container: " .. container.ID,
    end_msg = "Container " .. container.ID .. " unpaused",
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.stop(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_job {
    item = container,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = "Stopping container: " .. container.ID,
    end_msg = "Container " .. container.ID .. " stopped",
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.kill(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_job {
    item = container,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = "Killing container: " .. container.ID,
    end_msg = "Container " .. container.ID .. " killed",
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
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
  local container = selection.value
  if container.State ~= "exited" then
    util.warn "Container is not exited"
    return
  end
  local args = { "rm", container.ID }
  picker.docker_state:docker_job {
    item = container,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = "Removing container: " .. container.ID,
    end_msg = "Container " .. container.ID .. " removed",
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.rename(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_job {
    item = container,
    args = args,
    ask_for_input = ask_for_input,
    start_msg = "Renaming container: " .. container.ID,
    end_msg = "Container " .. container.ID .. " renamed",
    callback = function()
      actions.refresh_picker(prompt_bufnr)
    end,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.attach(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_command {
    args = { "attach", container.ID },
    ask_for_input = ask_for_input,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.logs(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_command {
    args = { "logs", container.ID },
    ask_for_input = ask_for_input,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.stats(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_command {
    args = { "stats", container.ID },
    ask_for_input = ask_for_input,
  }
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.exec(prompt_bufnr, ask_for_input)
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
  picker.docker_state:docker_command {
    args = args,
    ask_for_input = ask_for_input,
  }
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
  popup.open(options, function(choice, ask_for_input)
    if choice == enum.CONTAINERS.START then
      actions.start(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.STOP then
      actions.stop(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.KILL then
      actions.kill(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.DELETE then
      actions.delete(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.ATTACH then
      actions.attach(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.EXEC then
      actions.exec(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.LOGS then
      actions.logs(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.STATS then
      actions.stats(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.RENAME then
      actions.rename(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.PAUSE then
      actions.pause(prompt_bufnr, ask_for_input)
    elseif choice == enum.CONTAINERS.UNPAUSE then
      actions.unpause(prompt_bufnr, ask_for_input)
    end
  end)
end

return actions
