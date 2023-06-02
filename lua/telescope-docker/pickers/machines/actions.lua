local enum = require "telescope-docker.enum"
local util = require "telescope-docker.util"
local popup = require "telescope-docker.util.popup"
local finder = require "telescope-docker.pickers.machines.finder"
local action_state = require "telescope.actions.state"
local telescope_utils = require "telescope-docker.util.telescope"

local actions = {}

local select_machine

---Open a popup through which a docker machine action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_machine(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if not selection or not selection.value then
    return
  end
  ---@type Machine
  local machine = selection.value
  if machine.State == "Running" then
    return select_machine(prompt_bufnr, {
      enum.MACHINES.INSPECT,
      enum.MACHINES.SSH,
      enum.MACHINES.RESTART,
      enum.MACHINES.STOP,
      enum.MACHINES.KILL,
      enum.MACHINES.UPGRADE,
      enum.MACHINES.REGENERATE_CERTS,
    })
  elseif machine.State == "Stopped" then
    return select_machine(prompt_bufnr, {
      enum.MACHINES.INSPECT,
      enum.MACHINES.START,
      enum.MACHINES.REMOVE,
      enum.MACHINES.REGENERATE_CERTS,
    })
  else
    return select_machine(prompt_bufnr, {
      enum.MACHINES.INSPECT,
      enum.MACHINES.START,
      enum.MACHINES.REMOVE,
    })
  end
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.inspect(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      picker.docker_state:docker_command {
        args = { "inspect", machine.Name },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.ssh(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State ~= "Running" then
        util.warn("Machine", machine.Name, "is not running")
        return
      end
      picker.docker_state:docker_command {
        args = { "ssh", machine.Name },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.start(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State == "Running" then
        util.warn("Machine", machine.Name, "is already running")
        return
      end
      picker.docker_state:docker_command {
        args = { "start", machine.Name },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.restart(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State ~= "Running" then
        util.warn("Machine", machine.Name, "is not running")
        return
      end

      picker.docker_state:docker_command {
        args = { "restart", machine.Name },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.stop(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State ~= "Running" then
        util.warn("Machine", machine.Name, "is not running")
        return
      end

      local args = { "stop", machine.Name }
      picker.docker_state:docker_job {
        item = machine,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Stopping machine: " .. machine.Name,
        end_msg = "Machine " .. machine.Name .. " stopped",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder.machines_finder)
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
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State ~= "Running" then
        util.warn("Machine", machine.Name, "is not running")
        return
      end

      local args = { "kill", machine.Name }
      picker.docker_state:docker_job {
        item = machine,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Killing machine: " .. machine.Name,
        end_msg = "Machine " .. machine.Name .. " killed",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder.machines_finder)
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
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State == "Running" then
        util.warn("Machine", machine.Name, "is still running")
        return
      end

      local choice = vim.fn.confirm(
        "Are you sure you want to remove " .. vim.inspect(machine.Name) .. "?",
        "&Yes\n&No"
      )
      if choice ~= 1 then
        return
      end
      local args = { "rm", machine.Name, "-y" }
      picker.docker_state:docker_job {
        item = machine,
        args = args,
        ask_for_input = ask_for_input,
        start_msg = "Removing machine: " .. machine.Name,
        end_msg = "Machine " .. machine.Name .. " removed",
        callback = function()
          telescope_utils.refresh_picker(prompt_bufnr, finder.machines_finder)
        end,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.upgrade(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State ~= "Running" then
        util.warn("Machine", machine.Name, "is not running")
        return
      end

      picker.docker_state:docker_command {
        args = { "upgrade", machine.Name },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param ask_for_input boolean?: Whether to ask for input
function actions.regenerate_certs(prompt_bufnr, ask_for_input)
  telescope_utils.new_action(
    prompt_bufnr,
    ---@param machine Machine
    ---@param picker table
    function(machine, picker)
      if machine.State == "Error" then
        util.warn("Machine", machine.Name, "has an error status")
        return
      end

      if
        vim.fn.confirm(
          "Are you sure you want to regenerate TLS machine certs? This is irreversible.",
          "&Yes\n&No",
          2
        ) ~= 1
      then
        return
      end

      picker.docker_state:docker_command {
        args = { "regenerate-certs", machine.Name, "-y" },
        ask_for_input = ask_for_input,
      }
    end
  )
end

---@param prompt_bufnr number
---@param options string[]
function select_machine(prompt_bufnr, options)
  popup.open(options, function(choice, ask_for_input)
    if choice == enum.MACHINES.INSPECT then
      actions.inspect(prompt_bufnr, ask_for_input)
    elseif choice == enum.MACHINES.SSH then
      actions.ssh(prompt_bufnr, ask_for_input)
    elseif choice == enum.MACHINES.RESTART then
      actions.restart(prompt_bufnr, ask_for_input)
    elseif choice == enum.MACHINES.REGENERATE_CERTS then
      actions.regenerate_certs(prompt_bufnr, ask_for_input)
    elseif choice == enum.MACHINES.START then
      actions.start(prompt_bufnr, ask_for_input)
    elseif choice == enum.MACHINES.STOP then
      actions.stop(prompt_bufnr, ask_for_input)
    elseif choice == enum.MACHINES.REMOVE then
      actions.remove(prompt_bufnr, ask_for_input)
    elseif choice == enum.MACHINES.UPGRADE then
      actions.upgrade(prompt_bufnr, ask_for_input)
    end
  end)
end

return actions
