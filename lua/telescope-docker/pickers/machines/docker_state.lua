local State = require "telescope-docker.core.docker_state"
local Machine = require "telescope-docker.pickers.machines.machine"

---@class MachinesState : State
local MachinesState = State:new()
MachinesState.__index = MachinesState

function MachinesState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@param callback function?
---@return Machine[]
function MachinesState:fetch_items(callback)
  local total_json = ""
  local process_json = function(json)
    json = json:gsub("^.*{", "{")
    json = json:gsub("}.*$", "}")
    total_json = total_json .. json
    if total_json:sub(1, 1) ~= "{" or total_json:sub(-1) ~= "}" then
      return
    end
    local machine = Machine:new(total_json)
    local env = self:get_env()
    machine.env = env
    total_json = ""
    return machine, nil
  end

  local machines, _ = self:binary(function(binary, _)
    local cmd = {
      binary,
      "ls",
      [[--format='{]]
        .. [["Name":"{{.Name}}",]]
        .. [["DriverName": "{{.DriverName}}",]]
        .. [["Active":"{{.Active}}",]]
        .. [["ActiveHost":{{.ActiveHost}},]]
        .. [["ActiveSwarm":{{.ActiveSwarm}},]]
        .. [["State":"{{.State}}",]]
        .. [["URL":"{{.URL}}",]]
        .. [["Swarm":"{{.Swarm}}",]]
        .. [["Error":"{{.Error}}",]]
        .. [["DockerVersion":"{{.DockerVersion}}",]]
        .. [["ResponseTime":"{{.ResponseTime}}"]]
        .. [[}']],
    }
    return self:__fetch_docker_items(cmd, process_json, callback, false)
  end)
  return machines or {}
end

---Execute a docker command with the provided arguments in
---a new terminal window.
---
---@param opts DockerCommandOpts
function MachinesState:docker_command(opts)
  if type(opts.binary) == "string" then
    return self:__docker_command(opts.binary, opts)
  end
  return self:binary(function(binary, _)
    return self:__docker_command(binary, opts)
  end)
end

---Execute an async docker machine command with the provided arguments.
---
---@param opts DockerJobOpts
function MachinesState:docker_job(opts)
  return self:binary(function(binary, _)
    return self:__docker_job(binary, opts)
  end)
end

---@return any?: callback return values
---@return string?: Error
---@return string?: Warning
function MachinesState:binary(callback)
  local b, v, e = self:ext_command_binary("machine", "docker-machine")
  local r = nil
  if b ~= nil and type(callback) == "function" then
    r = callback(b, v)
  end
  return r, e
end

return MachinesState
