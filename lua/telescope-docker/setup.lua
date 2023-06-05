local util = require "telescope-docker.util"

local setup = {}

local called = false
local errors = {}
local opts = {}

---Creates the default picker options from the provided
---options. If the `theme` field with a string value is added,
---the telescope theme identified by that value is added to the options.
---@param o table
function setup.setup(o)
  called = true
  if type(o) ~= "table" then
    local msg = "Telescope docker config should be a table!"
    table.insert(errors, msg)
    util.warn(msg)
    return
  end

  if
      o.init_term ~= nil
      and type(o.init_term) ~= "function"
      and type(o.init_term) ~= "string"
  then
    util.warn "'init_term' should be a string or a function"
    o.init_term = nil
  end
  if o.log_level ~= nil and type(o.log_level) ~= "number" then
    local msg = "'log_level' should be number"
    table.insert(errors, msg)
    util.warn(msg)
  else
    util.set_log_level(o.log_level)
  end
  if o.binary ~= nil and type(o.binary) ~= "string" then
    local msg = "'binary' should be string"
    table.insert(errors, msg)
    util.warn(msg)
    o.binary = nil
  end

  if o.compose_binary ~= nil and type(o.compose_binary) ~= "string" then
    local msg = "'compose_binary' should be string"
    table.insert(errors, msg)
    util.warn(msg)
    o.compose_binary = nil
  end

  if o.buildx_binary ~= nil and type(o.buildx_binary) ~= "string" then
    local msg = "'buildx_binary' should be string"
    table.insert(errors, msg)
    util.warn(msg)
    o.buildx_binary = nil
  end

  if o.machine_binary ~= nil and type(o.machine_binary) ~= "string" then
    local msg = "'machine_binary' should be string"
    table.insert(errors, msg)
    util.warn(msg)
    o.machine_binary = nil
  end

  if type(o.theme) == "string" then
    local theme = require("telescope.themes")["get_" .. o.theme]
    if theme == nil then
      local msg = "No such telescope theme: " .. o.theme
      table.insert(errors, msg)
      util.warn(msg)
    else
      o = theme(o)
    end
  end
  opts = vim.tbl_extend("force", opts, o)
end

function setup.get_option(...)
  local v = opts
  for _, k in ipairs { select(1, ...) } do
    if type(k) ~= "string" then
      return nil
    end
    v = opts[k]
    if not v then
      return v
    end
  end
  return v
end

---@param callback function
---@param o table?
function setup.call_with_opts(callback, o)
  return callback(vim.tbl_extend("force", opts, o or {}))
end

---@return string[]
function setup.get_errors()
  return errors
end

---@return boolean
function setup.called()
  return called
end

return setup
