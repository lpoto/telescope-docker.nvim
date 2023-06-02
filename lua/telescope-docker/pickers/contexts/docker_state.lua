local State = require "telescope-docker.core.docker_state"
local Context = require "telescope-docker.pickers.contexts.context"

---@class ContextsState : State
local ContextsState = State:new()
ContextsState.__index = ContextsState

function ContextsState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@param callback function?
---@return Context[]
function ContextsState:fetch_items(callback)
  local proccess_json = function(json)
    local context = Context:new(json)
    local env = self:get_env()
    context.env = env
    return context
  end

  local contexts, _ = self:binary(function(binary, _)
    local cmd = {
      binary,
      "context",
      "ls",
      "--format='{{json . }}'",
    }
    return self:__fetch_docker_items(cmd, proccess_json, callback)
  end)
  return contexts or {}
end

return ContextsState
