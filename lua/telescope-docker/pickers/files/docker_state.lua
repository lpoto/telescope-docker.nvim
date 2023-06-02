local State = require "telescope-docker.core.docker_state"

---@class DockerfilesState : State
local DockerfilesState = State:new()
DockerfilesState.__index = DockerfilesState

function DockerfilesState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

function DockerfilesState:binary(callback)
  local b, v, err, warn = self:plugin_binary(
    "buildx",
    "docker-buildx",
    "buildx",
    true,
    "version",
    "Install 'buildx' to build images with buildkit"
  )
  if type(b) == "string" and type(callback) == "function" then
    return callback(b, v), err, warn
  end
  return nil, err, warn
end

return DockerfilesState
