local util = require "telescope._extensions.docker.util"
local setup = require "telescope._extensions.docker.setup"
local Container = require "telescope._extensions.docker.containers.container"

local M = {}

---@param container Container
function M.attach(container)
  if container.State ~= "running" then
    util.warn "Container is not running"
    return
  end
  util.info("Attaching to container: " .. container.ID)

  local binary = setup.get_option "binary" or "docker"

  local init_term = setup.get_option "init_term"
  local ok, e =
    pcall(util.open_in_shell, binary .. " attach " .. container.ID, init_term)
  if not ok then
    util.warn(e)
    return
  end
end

---@param container Container
function M.logs(container)
  util.info("Fetching container's logs: " .. container.ID)
  local init_term = setup.get_option "init_term"

  local binary = setup.get_option "binary" or "docker"

  local ok, e =
    pcall(util.open_in_shell, binary .. " logs " .. container.ID, init_term)
  if not ok then
    util.warn(e)
    return
  end
end

---@param container Container
function M.stats(container)
  if container.State == "exited" then
    util.warn "Container is exited"
    return
  end
  util.info("Fetching container's stats: " .. container.ID)
  local init_term = setup.get_option "init_term"

  local binary = setup.get_option "binary" or "docker"

  local ok, e =
    pcall(util.open_in_shell, binary .. " stats " .. container.ID, init_term)
  if not ok then
    util.warn(e)
    return
  end
end

---@param container Container
---@param callback function?
function M.rename(container, callback)
  local binary = setup.get_option "binary" or "docker"

  local cmd = binary .. " rename " .. container.ID .. " "
  local rename = vim.fn.input(cmd)
  if not rename or rename:len() == 0 then
    util.info "Invalid container name"
    return
  end
  cmd = cmd .. rename
  local error = {}
  util.info("Renaming container: " .. container.ID)
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.warn(
            "Renaming container exited with code: " .. vim.inspect(code)
          )
        end
        return
      end
      util.info "Container renamed"
      if type(callback) == "function" then
        callback(container)
      end
    end,
  })
end

---@param container Container
---@param callback function?
function M.start(container, callback)
  if container.State ~= "exited" then
    util.warn "Container is already running"
    return
  end
  local cmd = { setup.get_option "binary" or "docker", "start", container.ID }
  util.info("Starting container: " .. container.ID)
  local error = {}
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.info(
            "Starting container exited with code: " .. vim.inspect(code)
          )
        end
        return
      end
      util.info "Container started"
      if type(callback) == "function" then
        callback(container)
      end
    end,
  })
end

---@param container Container
---@param callback function?
function M.stop(container, callback)
  if container.State == "exited" then
    util.warn "Container is exited"
    return
  end
  local cmd = { setup.get_option "binary" or "docker", "stop", container.ID }
  util.info("Stopping container: " .. container.ID)
  local error = {}
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.warn(
            "Stopping container exited with code: " .. vim.inspect(code)
          )
        end
        return
      end
      util.info "Container stopped"
      if type(callback) == "function" then
        callback(container)
      end
    end,
  })
end

---@param container Container
---@param callback function?
function M.kill(container, callback)
  if container.State == "exited" then
    util.warn "Container is exited"
    return
  end
  util.info("Killing container: " .. container.ID)
  local cmd = { setup.get_option "binary" or "docker", "kill", container.ID }
  local error = {}
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.warn(
            "Killing container exited with code: " .. vim.inspect(code)
          )
        end
        return
      end
      util.info "Container killed"
      if type(callback) == "function" then
        callback(container)
      end
    end,
  })
end

---@param container Container
---@param callback function?
function M.pause(container, callback)
  if container.State ~= "running" then
    util.warn "Container is not running"
    return
  end
  util.info("Pausing container: " .. container.ID)
  local cmd = { setup.get_option "binary" or "docker", "pause", container.ID }
  local error = {}
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.warn(
            "Pausing container exited with code: " .. vim.inspect(code)
          )
        end
        return
      end
      util.info "Container paused"
      if type(callback) == "function" then
        callback(container)
      end
    end,
  })
end

---@param container Container
---@param callback function?
function M.unpause(container, callback)
  if container.State ~= "paused" then
    util.warn "Container is not paused"
    return
  end
  util.info("Unpausing container: " .. container.ID)
  local cmd =
    { setup.get_option "binary" or "docker", "unpause", container.ID }
  local error = {}
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.warn(
            "Unpausing container exited with code: " .. vim.inspect(code)
          )
        end
        return
      end
      util.info "Container unpaused"
      if type(callback) == "function" then
        callback(container)
      end
    end,
  })
end

---@param container Container
---@param callback function?
function M.delete(container, callback)
  if container.State ~= "exited" then
    util.warn "Can only delete exited containers"
    return
  end
  util.info("Deleting container: " .. container.ID)
  local cmd =
    { setup.get_option "binary" or "docker", "container", "rm", container.ID }
  local error = {}
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.warn(
            "Removing container exited with code: " .. vim.inspect(code)
          )
        end
        return
      end
      util.info "Container removed"
      if type(callback) == "function" then
        callback(container)
      end
    end,
  })
end

---@param container Container
function M.exec(container)
  if container.State == "exited" then
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
  util.info("Executing '" .. exec .. "' to container: " .. container.ID)
  command = command .. exec

  local init_term = setup.get_option "init_term"
  local ok, e = pcall(util.open_in_shell, command, init_term)
  if not ok then
    util.warn(e)
    return
  end
end

---@param callback function?
---@return Container[]
function M.get_containers(callback)
  local cmd = {
    setup.get_option "binary" or "docker",
    "ps",
    "-a",
    "--format='{{json . }}'",
  }

  local containers = {}

  local job_id = vim.fn.jobstart(cmd, {
    detach = false,
    on_stdout = function(_, data)
      local ok, err = pcall(function()
        for _, json in ipairs(data) do
          if json:len() > 0 then
            json = string.sub(json, 2, #json - 1)
            local container = Container:new(json)
            table.insert(containers, container)
          end
        end
      end)
      if not ok then
        util.warn("Error when decoding container: ", err)
      end
    end,
    on_exit = function()
      if callback then
        callback(containers)
      end
    end,
  })
  if not callback then
    vim.fn.jobwait({ job_id }, 2000)
  end
  return containers
end

return M
