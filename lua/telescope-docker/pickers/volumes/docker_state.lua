local State = require "telescope-docker.core.docker_state"
local Volume = require "telescope-docker.pickers.volumes.volume"

---@class VolumesState : State
local VolumesState = State:new()
VolumesState.__index = VolumesState

function VolumesState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@param callback function?
---@return Volume[]
function VolumesState:fetch_items(callback)
  local proccess_json = function(json)
    local volume = Volume:new(json)
    local env = self:get_env()
    volume.env = env
    return volume
  end

  local volumes, _ = self:binary(function(binary, _)
    local cmd = {
      binary,
      "volume",
      "ls",
      "--format='{{json . }}'",
    }
    return self:__fetch_docker_items(cmd, proccess_json, callback)
  end)
  return volumes or {}
end

return VolumesState
