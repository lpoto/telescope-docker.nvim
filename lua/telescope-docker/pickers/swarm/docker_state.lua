local State = require "telescope-docker.core.docker_state"
local Node = require "telescope-docker.pickers.swarm.node"

---@class SwarmState : State
local SwarmState = State:new()
SwarmState.__index = SwarmState

function SwarmState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@param callback function?
---@return Node[]
function SwarmState:fetch_items(callback)
  local proccess_json = function(json)
    local node = Node:new(json)
    local env = self:get_env()
    node.env = env
    return node
  end

  local nodes, _ = self:binary(function(binary, _)
    local cmd = {
      binary,
      "node",
      "ls",
      "--format='{{json . }}'",
    }
    return self:__fetch_docker_items(cmd, proccess_json, callback)
  end)
  return nodes or {}
end

return SwarmState
