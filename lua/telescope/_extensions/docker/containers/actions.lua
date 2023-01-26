local enum = require "telescope._extensions.docker.enum"
local util = require "telescope._extensions.docker.util"
local popup = require "telescope._extensions.docker.util.popup"
local containers = require "telescope._extensions.docker.containers"
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
  local selection = action_state.get_selected_entry(prompt_bufnr)
  ---@type Container
  local container = selection.value
  if container.State == "exited" then
    return select_container(container, prompt_bufnr, {
      enum.CONTAINERS.START,
      enum.CONTAINERS.DELETE,
      enum.CONTAINERS.LOGS,
      enum.CONTAINERS.RENAME,
    })
  elseif container.State == "running" then
    return select_container(container, prompt_bufnr, {
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
    return select_container(container, prompt_bufnr, {
      enum.CONTAINERS.UNPAUSE,
      enum.CONTAINERS.STOP,
      enum.CONTAINERS.KILL,
      enum.CONTAINERS.LOGS,
      enum.CONTAINERS.STATS,
      enum.CONTAINERS.RENAME,
    })
  end
end

---Asynchronously refresh the containers picker.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.refresh_picker(prompt_bufnr)
  containers.get_containers(function(containers_tbl)
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

---@param container Container
---@param prompt_bufnr number
---@param options string[]
function select_container(container, prompt_bufnr, options)
  popup.open(options, function(choice)
    if choice == enum.CONTAINERS.START then
      containers.start(container, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    elseif choice == enum.CONTAINERS.STOP then
      containers.stop(container, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    elseif choice == enum.CONTAINERS.KILL then
      containers.kill(container, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    elseif choice == enum.CONTAINERS.DELETE then
      containers.delete(container, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    elseif choice == enum.CONTAINERS.ATTACH then
      containers.attach(container)
    elseif choice == enum.CONTAINERS.EXEC then
      containers.exec(container)
    elseif choice == enum.CONTAINERS.LOGS then
      containers.logs(container)
    elseif choice == enum.CONTAINERS.STATS then
      containers.stats(container)
    elseif choice == enum.CONTAINERS.RENAME then
      containers.rename(container, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    elseif choice == enum.CONTAINERS.PAUSE then
      containers.pause(container, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    elseif choice == enum.CONTAINERS.UNPAUSE then
      containers.unpause(container, function()
        actions.refresh_picker(prompt_bufnr)
      end)
    end
  end)
end

return actions
