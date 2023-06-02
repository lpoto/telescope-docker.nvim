local setup = require "telescope-docker.setup"
local util = require "telescope-docker.util"

---@class DockerPicker
---@field picker_fn function
---@field name string
---@field description string
---@field condition function?
local DockerPicker = {}
DockerPicker.__index = DockerPicker

---@param opts table
---@return DockerPicker
function DockerPicker:new(opts)
  return setmetatable(opts, self)
end

---@param opts table
function DockerPicker:run(opts)
  if type(self.picker_fn) ~= "function" then
    return
  end
  if type(self.condition) == "function" then
    local err, warn = self.condition()
    if err ~= nil then
      util.error(err)
      return
    elseif warn ~= nil then
      util.warn(warn)
    end
  end
  setup.call_with_opts(self.picker_fn, opts)
end

return DockerPicker
