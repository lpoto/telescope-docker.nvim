local State = require "telescope-docker.core.docker_state"
local Image = require "telescope-docker.pickers.images.image"

---@class ImagesState : State
local ImagesState = State:new()
ImagesState.__index = ImagesState

function ImagesState:new(env)
  local o = State:new(env)
  o = setmetatable(o, self)
  return o
end

---@param callback function?
---@return Image[]
function ImagesState:fetch_items(callback)
  local process_json = function(json)
    local image = Image:new(json)
    local env = self:get_env()
    image.env = env
    if image:name() == "<none>:<none>" then
      return nil, image
    end
    return image
  end

  local images, _ = self:binary(function(binary, _)
    local cmd = {
      binary,
      "image",
      "ls",
      "-a",
      "--format='{{json . }}'",
    }
    return self:__fetch_docker_items(cmd, process_json, callback)
  end)
  return images or {}
end

return ImagesState
