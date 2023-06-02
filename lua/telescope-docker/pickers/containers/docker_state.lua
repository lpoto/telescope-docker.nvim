local State = require "telescope-docker.core.docker_state"
local Container = require "telescope-docker.pickers.containers.container"

---@class ContainersState : State
local ContainersState = State:new()
ContainersState.__index = ContainersState

function ContainersState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@param callback function?
---@return Container[]
function ContainersState:fetch_items(callback)
  local proccess_json = function(json)
    local container = Container:new(json)
    local env = self:get_env()
    container.env = env
    return container
  end

  local containers, _ = self:binary(function(binary, _)
    local cmd = {
      binary,
      "ps",
      "-a",
      "--format='{{json . }}'",
    }
    return self:__fetch_docker_items(cmd, proccess_json, callback)
  end)
  return containers or {}
end


return ContainersState
