local enum = require "telescope-docker.enum"
local util = require "telescope-docker.util"
local popup = require "telescope-docker.util.popup"
local action_state = require "telescope.actions.state"
local finder = require "telescope-docker.pickers.containers.finder"
local telescope_utils = require "telescope-docker.util.telescope"

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
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
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
          telescope_utils.refresh_picker(
            prompt_bufnr,
            finder.containers_finder
          )
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.pause(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
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
          telescope_utils.refresh_picker(
            prompt_bufnr,
            finder.containers_finder
          )
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.unpause(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
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
          telescope_utils.refresh_picker(
            prompt_bufnr,
            finder.containers_finder
          )
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.stop(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
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
          telescope_utils.refresh_picker(
            prompt_bufnr,
            finder.containers_finder
          )
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.kill(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
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
          telescope_utils.refresh_picker(
            prompt_bufnr,
            finder.containers_finder
          )
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.delete(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
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
          telescope_utils.refresh_picker(
            prompt_bufnr,
            finder.containers_finder
          )
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.rename(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
      picker.docker_state:binary(function(binary)
        local rename = vim.fn.input {
          prompt = binary .. " rename " .. container.ID .. " ",
          default = "",
          cancelreturn = "",
        }
        if type(rename) ~= "string" or rename == "" then
          return
        end
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
            telescope_utils.refresh_picker(
              prompt_bufnr,
              finder.containers_finder
            )
          end,
        }
      end)
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.attach(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
      if container.State ~= "running" then
        util.warn "Container is not running"
        return
      end
      picker.docker_state:docker_command {
        args = { "attach", container.ID },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.logs(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
      picker.docker_state:docker_command {
        args = { "logs", "--follow", container.ID },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.stats(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
      if container.State == "exited" then
        util.warn "Container is exited"
        return
      end
      picker.docker_state:docker_command {
        args = { "stats", container.ID },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.exec(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param container Container
    ---@param picker table
    function(container, picker)
      if container.State ~= "running" then
        util.warn "Container is not running"
        return
      end

      picker.docker_state:binary(function(binary)
        local exec = vim.fn.input {
          prompt = binary .. " exec -it " .. container.ID .. " ",
          default = "",
          cancelreturn = "",
        }
        if type(exec) ~= "string" or exec:len() == 0 then
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
      end)
    end
  )
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
