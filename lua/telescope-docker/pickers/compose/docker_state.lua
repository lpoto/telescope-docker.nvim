local State = require "telescope-docker.core.docker_state"

---@class ComposeState : State
local ComposeState = State:new()
ComposeState.__index = ComposeState

function ComposeState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@return any? callback return values
---@return string? Error
---@return string? Warning
function ComposeState:binary(callback)
  local b, v, e, w = self:plugin_binary(
    "compose",
    false,
    "Install 'docker-compose' to manage docker compose files"
  )
  local r = nil
  if b ~= nil and type(callback) == "function" then
    r = callback(b, v)
  end
  return r, e, w
end

return ComposeState
