local State = require "telescope-docker.core.docker_state"
local Network = require "telescope-docker.pickers.networks.network"

---@class NetworksState : State
local NetworksState = State:new()
NetworksState.__index = NetworksState

function NetworksState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@param callback function?
---@return Network[]
function NetworksState:fetch_items(callback)
  local proccess_json = function(json)
    local network = Network:new(json)
    local env = self:get_env()
    network.env = env
    return network
  end

  local networks, _ = self:binary(function(binary, _)
    local cmd = {
      binary,
      "network",
      "ls",
      "--format='{{json . }}'",
    }
    return self:__fetch_docker_items(cmd, proccess_json, callback)
  end)
  return networks or {}
end

return NetworksState
